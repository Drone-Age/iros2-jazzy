#!/usr/bin/env python3
"""Bind native release evidence to one commit and artifact snapshot."""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def text_sha256(path: Path) -> str:
    """Hash UTF-8 text with Git-compatible LF line endings."""
    content = path.read_text(encoding="utf-8").replace("\r\n", "\n").replace("\r", "\n")
    return hashlib.sha256(content.encode("utf-8")).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--commit", default="HEAD")
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--repository", type=Path, required=True)
    parser.add_argument("--inventory", type=Path, required=True)
    parser.add_argument("--sbom", type=Path, required=True)
    parser.add_argument("--status", type=Path, required=True)
    parser.add_argument("--smoke-log", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    commit = subprocess.check_output(
        ["git", "rev-parse", f"{args.commit}^{{commit}}"], text=True
    ).strip()
    if args.status.read_text(encoding="utf-8").strip() != "PASS":
        raise SystemExit("native release status is not PASS")
    smoke_text = args.smoke_log.read_text(encoding="utf-8")
    if "Clean iros2j APT installation verified" not in smoke_text:
        raise SystemExit("clean-install smoke evidence is incomplete")

    manifest_data = json.loads(args.manifest.read_text(encoding="utf-8"))
    if manifest_data["release"]["status"] != "released":
        raise SystemExit("release manifest is not finalized")
    build_commit = manifest_data["provenance"]["build_commit"]

    evidence = {
        "schema_version": 1,
        "status": "PASS",
        "release_commit": commit,
        "build_commit": build_commit,
        "created_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "host": {
            "architecture": subprocess.check_output(["uname", "-m"], text=True).strip(),
            "os_release": Path("/etc/os-release").read_text(encoding="utf-8"),
        },
        "inputs": {
            "manifest_sha256": text_sha256(args.manifest),
            "inventory_sha256": sha256(args.inventory),
            "install_smoke_sha256": sha256(args.smoke_log),
        },
        "artifacts": {
            "apt_repository_sha256": sha256(args.repository),
            "sbom_sha256": sha256(args.sbom),
        },
    }
    if evidence["host"]["architecture"] != "aarch64":
        raise SystemExit("native gate must run on aarch64")
    args.output.write_text(
        json.dumps(evidence, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
