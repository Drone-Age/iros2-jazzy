from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
NORMATIVE = [
    "CONTRIBUTING.md",
    "docs/DOCUMENTATION_POLICY.md",
    "docs/VERSIONING.md",
    "docs/PACKAGE_POLICY.md",
    "docs/RELEASE_PROCESS.md",
    "docs/V1_MIGRATION_PLAN.md",
]


def ukrainian_counterpart(path: Path) -> Path:
    return path.with_name(f"{path.stem}.uk{path.suffix}")


class DocumentationTests(unittest.TestCase):
    def test_normative_documents_have_ukrainian_counterparts(self):
        missing = [
            str(ukrainian_counterpart(ROOT / relative).relative_to(ROOT))
            for relative in NORMATIVE
            if not ukrainian_counterpart(ROOT / relative).is_file()
        ]
        self.assertEqual(missing, [])

    def test_index_links_every_normative_pair(self):
        english = (ROOT / "docs" / "README.md").read_text(encoding="utf-8")
        ukrainian = (ROOT / "docs" / "README.uk.md").read_text(encoding="utf-8")
        for relative in NORMATIVE[1:]:
            path = Path(relative)
            counterpart = ukrainian_counterpart(path)
            self.assertIn(path.name, english)
            self.assertIn(counterpart.name, english)
            self.assertIn(path.name, ukrainian)
            self.assertIn(counterpart.name, ukrainian)

    def test_accepted_v1_constraints_are_recorded(self):
        policy = (ROOT / "docs" / "PACKAGE_POLICY.md").read_text(encoding="utf-8")
        release = (ROOT / "docs" / "RELEASE_PROCESS.md").read_text(encoding="utf-8")
        regulations = policy + release
        for required in (
            "iros2j",
            "/opt/iros2j",
            "Debian 13 Trixie ARM64",
            "AMD64 is not built",
            "VINS-NEO",
            "iros2j-ros-core",
            "1.0.0-1+deb13",
        ):
            self.assertIn(required, regulations)

    def test_tag_encodes_ros_generation_without_changing_package_version(self):
        versioning = (ROOT / "docs" / "VERSIONING.md").read_text(encoding="utf-8")
        self.assertIn("v<ROS_GENERATION>.<MAJOR>.<MINOR>.<PATCH>", versioning)
        self.assertIn("package version `1.0.0`", versioning)
        self.assertIn("v2.1.0.0", versioning)
        self.assertIn("`1.0.0-1+deb13`", versioning)


if __name__ == "__main__":
    unittest.main()
