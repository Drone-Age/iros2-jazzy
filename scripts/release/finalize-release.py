#!/usr/bin/env python3
"""Fill artifact hashes in the release manifest after the native gate."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def artifact(path: Path) -> dict[str, str]:
    return {"filename": path.name, "sha256": sha256(path)}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--artifacts", type=Path, required=True)
    parser.add_argument("--build-commit", required=True)
    args = parser.parse_args()

    if len(args.build_commit) != 40 or any(
        character not in "0123456789abcdef" for character in args.build_commit
    ):
        raise SystemExit("build commit must be an exact lowercase SHA")

    data = json.loads(args.manifest.read_text(encoding="utf-8"))
    version = data["release"]["package_version"]
    inventory = args.artifacts / "package-inventory.json"
    repository = args.artifacts / "iros2j-apt_trixie_arm64.tar.gz"
    sbom = args.artifacts / f"iros2j-{version}.spdx.json"
    smoke = args.artifacts / "install-smoke-test.txt"
    status = args.artifacts / "status.txt"
    if status.read_text(encoding="utf-8").strip() != "PASS":
        raise SystemExit("native release status is not PASS")

    data["release"]["status"] = "released"
    data["packages"]["inventory_sha256"] = sha256(inventory)
    data["artifacts"] = {
        "apt_repository": artifact(repository),
        "sha256": artifact(repository.with_suffix(repository.suffix + ".sha256")),
        "sbom": artifact(sbom),
        "native_gate": {"filename": "native-gate.json"},
        "install_smoke": artifact(smoke),
    }
    data["provenance"] = {"build_commit": args.build_commit}
    args.manifest.write_text(
        json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    print(f"Finalized release manifest: {args.manifest.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
