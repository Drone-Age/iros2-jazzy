#!/usr/bin/env python3
"""Create a compact SPDX 2.3 JSON SBOM for the iros2j package snapshot."""

from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path


def spdx_id(name: str) -> str:
    return "SPDXRef-Package-" + name.replace("+", "-").replace(".", "-")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--inventory", type=Path, required=True)
    parser.add_argument("--artifacts", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    inventory = json.loads(args.inventory.read_text(encoding="utf-8"))
    packages = []
    relationships = []
    for package in inventory["packages"]:
        debs = list(args.artifacts.glob(f"{package['debian_name']}_*.deb"))
        if len(debs) != 1:
            raise SystemExit(f"expected one artifact for {package['debian_name']}")
        digest = hashlib.sha256(debs[0].read_bytes()).hexdigest()
        identifier = spdx_id(package["debian_name"])
        packages.append(
            {
                "SPDXID": identifier,
                "name": package["debian_name"],
                "versionInfo": inventory["package_version"],
                "downloadLocation": "NOASSERTION",
                "filesAnalyzed": False,
                "checksums": [{"algorithm": "SHA256", "checksumValue": digest}],
                "supplier": "Organization: Drone Age",
            }
        )
        relationships.append(
            {
                "spdxElementId": "SPDXRef-DOCUMENT",
                "relationshipType": "DESCRIBES",
                "relatedSpdxElement": identifier,
            }
        )

    created = datetime.fromtimestamp(
        int(__import__("os").environ.get("SOURCE_DATE_EPOCH", "0")), timezone.utc
    ).isoformat().replace("+00:00", "Z")
    document = {
        "spdxVersion": "SPDX-2.3",
        "dataLicense": "CC0-1.0",
        "SPDXID": "SPDXRef-DOCUMENT",
        "name": f"iros2j-{inventory['package_version']}",
        "documentNamespace": (
            "https://github.com/Drone-Age/iros2_0/sbom/"
            + inventory["package_version"]
        ),
        "creationInfo": {
            "created": created,
            "creators": ["Organization: Drone Age", "Tool: iros2j-generate-sbom"],
        },
        "packages": packages,
        "relationships": relationships,
    }
    args.output.write_text(
        json.dumps(document, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
