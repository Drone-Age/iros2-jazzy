from pathlib import Path
import tempfile
import unittest

from scripts.package_metadata import debian_name, inventory


PACKAGE_XML = """\
<package format="3">
  <name>{name}</name>
  <version>1.0.0</version>
  <description>fixture</description>
  <maintainer email="test@example.com">Test</maintainer>
  <license>Apache-2.0</license>
  {dependencies}
</package>
"""


def create_package(
    install_base: Path, name: str, dependencies: tuple[str, ...] = (), elf: bool = False
) -> None:
    prefix = install_base / name
    (prefix / "share" / "ament_index").mkdir(parents=True)
    package_share = prefix / "share" / name
    package_share.mkdir(parents=True)
    dependency_xml = "\n  ".join(
        f"<exec_depend>{dependency}</exec_depend>" for dependency in dependencies
    )
    (package_share / "package.xml").write_text(
        PACKAGE_XML.format(name=name, dependencies=dependency_xml),
        encoding="utf-8",
    )
    if elf:
        library = prefix / "lib" / f"lib{name}.so"
        library.parent.mkdir(parents=True)
        library.write_bytes(b"\x7fELFfixture")


class PackageMetadataTests(unittest.TestCase):
    def test_official_name_mapping(self):
        self.assertEqual(debian_name("sensor_msgs"), "iros2j-sensor-msgs")
        self.assertEqual(debian_name("rviz2"), "iros2j-rviz2")

    def test_inventory_maps_internal_dependencies_and_architecture(self):
        with tempfile.TemporaryDirectory() as temporary:
            install_base = Path(temporary)
            create_package(install_base, "rclcpp", elf=True)
            create_package(
                install_base,
                "demo_nodes_cpp",
                dependencies=("rclcpp", "external_system_dependency"),
            )

            packages = {package.ros_name: package for package in inventory(
                install_base, "1.0.1-1+deb13"
            )}

            self.assertEqual(packages["rclcpp"].architecture, "arm64")
            self.assertEqual(packages["demo_nodes_cpp"].architecture, "all")
            self.assertEqual(
                packages["demo_nodes_cpp"].dependencies,
                ("iros2j-rclcpp (= 1.0.1-1+deb13)",),
            )
            self.assertEqual(
                packages["demo_nodes_cpp"].external_dependencies,
                ("external_system_dependency",),
            )


if __name__ == "__main__":
    unittest.main()
