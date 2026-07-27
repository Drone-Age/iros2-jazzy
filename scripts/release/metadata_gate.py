#!/usr/bin/env python3
"""Fail-closed validation for an iros2j release manifest."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SHA = re.compile(r"^[0-9a-f]{40}$")
REQUIRED_EXCLUSIONS = {
    "amd64",
    "docker",
    "qemu",
    "vins-neo-validation",
    "monolithic-packages",
}
REQUIRED_METAPACKAGES = {
    "iros2j-ros-core",
    "iros2j-ros-base",
    "iros2j-common-interfaces",
    "iros2j-vision-opencv",
    "iros2j-rviz2",
}


def sha256(path: Path) -> str:
    # Git stores normative text with LF even when a Windows worktree presents
    # CRLF. Hash the canonical repository representation.
    return hashlib.sha256(path.read_bytes().replace(b"\r\n", b"\n")).hexdigest()


def load_lock(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    versions = re.findall(r"^\s+version:\s+([0-9a-f]+)\s*$", text, re.MULTILINE)
    if not versions or any(not SHA.fullmatch(version) for version in versions):
        raise ValueError("source lock must contain only exact 40-character commit SHAs")
    return text


def validate(manifest_path: Path, root: Path = ROOT) -> dict:
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    release = manifest["release"]
    package_version = (root / "VERSION").read_text(encoding="utf-8").strip()
    process_version = (root / "PROCESS_VERSION").read_text(encoding="utf-8").strip()

    assert release["name"] == "iros2j"
    assert release["package_version"] == package_version
    assert release["debian_version"] == f"{package_version}-1+deb13"
    assert release["tag"] == f"v2.{package_version}"
    assert release["process_version"] == process_version

    build = manifest["build"]
    assert build == {
        "operating_system": "debian",
        "release": "13",
        "codename": "trixie",
        "architecture": "arm64",
        "native": True,
        "install_prefix": "/opt/iros2j",
        "build_type": "Release",
    }
    assert REQUIRED_EXCLUSIONS <= set(manifest["excluded"])
    assert REQUIRED_METAPACKAGES <= set(manifest["packages"]["required_metapackages"])

    lock_path = root / manifest["sources"]["lock_file"]
    load_lock(lock_path)
    assert sha256(lock_path) == manifest["sources"]["lock_sha256"]

    if release["status"] == "released":
        assert manifest["packages"]["inventory_sha256"]
        assert all(manifest["artifacts"].values())
        assert re.fullmatch(r"[0-9a-f]{40}", manifest["provenance"]["build_commit"])
    return manifest


def git_file(specifier: str, path: str) -> bytes:
    return subprocess.check_output(["git", "-C", str(ROOT), "show", f"{specifier}:{path}"])


def materialize_snapshot(specifier: str) -> tuple[tempfile.TemporaryDirectory, Path]:
    temporary = tempfile.TemporaryDirectory()
    root = Path(temporary.name)
    version = git_file(specifier, "VERSION").decode("utf-8").strip()
    manifest_name = f"manifests/iros2j-{version}.json"
    manifest = json.loads(git_file(specifier, manifest_name).decode("utf-8"))
    required = [
        "VERSION",
        "PROCESS_VERSION",
        manifest_name,
        manifest["sources"]["lock_file"],
    ]
    for relative in required:
        destination = root / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(git_file(specifier, relative))
    return temporary, root / manifest_name


def main() -> int:
    parser = argparse.ArgumentParser()
    source = parser.add_mutually_exclusive_group()
    source.add_argument("--index", action="store_true")
    source.add_argument("--commit")
    parser.add_argument(
        "manifest",
        type=Path,
        nargs="?",
    )
    args = parser.parse_args()
    if args.index or args.commit:
        if args.manifest:
            parser.error("manifest path cannot be combined with --index or --commit")
        temporary, manifest = materialize_snapshot("" if args.index else args.commit)
        try:
            validate(manifest, manifest.parents[1])
        finally:
            temporary.cleanup()
        label = "Git index" if args.index else args.commit
    else:
        manifest = args.manifest or (
            ROOT / f"manifests/iros2j-{(ROOT / 'VERSION').read_text().strip()}.json"
        )
        validate(manifest.resolve())
        label = manifest.name
    print(f"Release metadata valid: {label}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
