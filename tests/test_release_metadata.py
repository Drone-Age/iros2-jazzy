import copy
import json
from pathlib import Path
import tempfile
import unittest

from scripts.release.metadata_gate import validate


ROOT = Path(__file__).resolve().parents[1]


class ReleaseMetadataTests(unittest.TestCase):
    def setUp(self):
        version = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
        self.manifest_path = ROOT / "manifests" / f"iros2j-{version}.json"
        self.manifest = json.loads(self.manifest_path.read_text(encoding="utf-8"))

    def write_manifest(self, data: dict) -> Path:
        temporary = tempfile.NamedTemporaryFile(
            mode="w", encoding="utf-8", suffix=".json", delete=False
        )
        json.dump(data, temporary)
        temporary.close()
        self.addCleanup(Path(temporary.name).unlink, missing_ok=True)
        return Path(temporary.name)

    def test_committed_draft_manifest_is_valid(self):
        validate(self.manifest_path)

    def test_wrong_generation_tag_is_rejected(self):
        changed = copy.deepcopy(self.manifest)
        changed["release"]["tag"] = "v1.1.0.1"
        with self.assertRaises(AssertionError):
            validate(self.write_manifest(changed))

    def test_amd64_cannot_be_release_architecture(self):
        changed = copy.deepcopy(self.manifest)
        changed["build"]["architecture"] = "amd64"
        with self.assertRaises(AssertionError):
            validate(self.write_manifest(changed))


if __name__ == "__main__":
    unittest.main()
