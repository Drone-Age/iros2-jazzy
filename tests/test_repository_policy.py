from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class RepositoryPolicyTests(unittest.TestCase):
    def test_excluded_build_paths_are_absent(self):
        forbidden = [
            "Dockerfile",
            "scripts/container",
            "scripts/00-check-host.ps1",
            "scripts/10-build-environment.ps1",
            "scripts/20-build-package.ps1",
            "packaging/docker-entrypoint.sh",
            "packaging/control.in",
        ]
        present = []
        for relative in forbidden:
            path = ROOT / relative
            if path.is_file() or (path.is_dir() and any(path.rglob("*"))):
                present.append(relative)
        self.assertEqual(present, [])

    def test_product_and_process_versions_match_draft_manifest(self):
        import json

        version = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
        process = (ROOT / "PROCESS_VERSION").read_text(encoding="utf-8").strip()
        manifest = json.loads(
            (ROOT / "manifests" / f"iros2j-{version}.json").read_text(
                encoding="utf-8"
            )
        )
        self.assertEqual(manifest["release"]["package_version"], version)
        self.assertEqual(manifest["release"]["process_version"], process)
        self.assertEqual(manifest["release"]["tag"], f"v2.{version}")

    def test_native_dispatcher_streams_remote_scripts_over_stdin(self):
        dispatcher = (ROOT / "scripts" / "invoke-native-release.ps1").read_text(
            encoding="utf-8"
        )
        self.assertIn(
            """$start | & ssh @sshOptions $HostName "tr -d '\\r' | bash -s\"""",
            dispatcher,
        )
        self.assertIn(
            """$state = $stateScript | & ssh @sshOptions $HostName "tr -d '\\r' | bash -s\"""",
            dispatcher,
        )
        self.assertNotIn('nohup sh -c', dispatcher)
        self.assertIn('rc=`$?', dispatcher)
        self.assertIn('remote_root_abs=`$(cd', dispatcher)
        self.assertIn('> "`$remote_root_abs/exit-code"', dispatcher)

    def test_rosdep_results_are_split_into_individual_debian_packages(self):
        builder = (ROOT / "scripts" / "native" / "build-debs.sh").read_text(
            encoding="utf-8"
        )
        self.assertIn("tr -s '[:space:]' '\\n'", builder)


if __name__ == "__main__":
    unittest.main()
