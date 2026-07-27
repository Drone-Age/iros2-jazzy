#!/usr/bin/env python3
"""Verify that native evidence matches the release commit and artifacts."""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
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
    parser.add_argument("--gate", type=Path, required=True)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--artifacts", type=Path, required=True)
    parser.add_argument("--commit", default="HEAD")
    args = parser.parse_args()

    commit = subprocess.check_output(
        ["git", "rev-parse", f"{args.commit}^{{commit}}"], text=True
    ).strip()
    gate = json.loads(args.gate.read_text(encoding="utf-8"))
    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    assert gate["status"] == "PASS"
    assert gate["release_commit"] == commit
    assert gate["build_commit"] == manifest["provenance"]["build_commit"]
    assert gate["inputs"]["manifest_sha256"] == text_sha256(args.manifest)
    assert gate["inputs"]["inventory_sha256"] == sha256(
        args.artifacts / "package-inventory.json"
    )
    for key in ("apt_repository", "sbom", "install_smoke"):
        metadata = manifest["artifacts"][key]
        assert sha256(args.artifacts / metadata["filename"]) == metadata["sha256"]
    print(f"Native gate valid for {commit}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
