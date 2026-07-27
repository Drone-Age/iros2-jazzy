#!/usr/bin/env python3
"""Generate deterministic Debian metadata from an isolated colcon install."""

from __future__ import annotations

import argparse
import json
import re
import sys
import xml.etree.ElementTree as ET
from dataclasses import asdict, dataclass
from pathlib import Path


DEPENDENCY_TAGS = {
    "depend",
    "exec_depend",
    "build_export_depend",
    "buildtool_export_depend",
    "group_depend",
}
DEBIAN_NAME = re.compile(r"^[a-z0-9][a-z0-9+.-]+$")


def debian_name(ros_name: str) -> str:
    normalized = ros_name.lower().replace("_", "-")
    name = f"iros2j-{normalized}"
    if not DEBIAN_NAME.fullmatch(name):
        raise ValueError(f"invalid ROS package name for Debian mapping: {ros_name!r}")
    return name


def package_xml_for(prefix: Path, ros_name: str) -> Path:
    candidates = [
        prefix / "share" / ros_name / "package.xml",
        prefix / "share" / ros_name / "package.xml.installspace",
    ]
    for candidate in candidates:
        if candidate.is_file():
            return candidate
    raise FileNotFoundError(f"package.xml not found for {ros_name} under {prefix}")


def direct_ros_dependencies(package_xml: Path) -> set[str]:
    root = ET.parse(package_xml).getroot()
    dependencies: set[str] = set()
    for element in root:
        condition = element.attrib.get("condition", "")
        if "$ROS_VERSION" in condition:
            compact = condition.replace('"', "").replace("'", "").replace(" ", "")
            if "==1" in compact or "!=2" in compact:
                continue
        if "$ROS_DISTRO" in condition:
            compact = condition.replace('"', "").replace("'", "").replace(" ", "")
            if "!=jazzy" in compact:
                continue
            if "==" in compact and "==jazzy" not in compact:
                continue
        if element.tag in DEPENDENCY_TAGS and element.text:
            dependencies.add(element.text.strip())
    return dependencies


def contains_elf(prefix: Path) -> bool:
    for path in prefix.rglob("*"):
        if not path.is_file() or path.is_symlink():
            continue
        try:
            with path.open("rb") as stream:
                if stream.read(4) == b"\x7fELF":
                    return True
        except OSError:
            continue
    return False


@dataclass(frozen=True)
class Package:
    ros_name: str
    debian_name: str
    architecture: str
    dependencies: tuple[str, ...]
    external_dependencies: tuple[str, ...]
    prefix: str


def inventory(install_base: Path, version: str) -> list[Package]:
    prefixes = sorted(
        path
        for path in install_base.iterdir()
        if path.is_dir()
        and (
            (path / "share" / path.name / "package.xml").is_file()
            or (path / "share" / path.name / "package.xml.installspace").is_file()
        )
    )
    ros_names = {path.name for path in prefixes}
    packages: list[Package] = []
    for prefix in prefixes:
        ros_name = prefix.name
        dependencies = direct_ros_dependencies(package_xml_for(prefix, ros_name))
        internal = tuple(
            f"{debian_name(dependency)} (= {version})"
            for dependency in sorted(dependencies & ros_names)
            if dependency != ros_name
        )
        packages.append(
            Package(
                ros_name=ros_name,
                debian_name=debian_name(ros_name),
                architecture="arm64" if contains_elf(prefix) else "all",
                dependencies=internal,
                external_dependencies=tuple(sorted(dependencies - ros_names)),
                prefix=str(prefix),
            )
        )
    if not packages:
        raise ValueError(f"no isolated ROS package prefixes found in {install_base}")
    return packages


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--install-base", type=Path, required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()

    data = {
        "schema_version": 1,
        "package_version": args.version,
        "install_prefix": "/opt/iros2j",
        "packages": [asdict(package) for package in inventory(args.install_base, args.version)],
    }
    rendered = json.dumps(data, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8")
    else:
        sys.stdout.write(rendered)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
