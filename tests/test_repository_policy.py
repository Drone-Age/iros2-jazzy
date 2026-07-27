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

    def test_package_audit_does_not_short_circuit_dpkg_deb_pipes(self):
        audit = (ROOT / "scripts" / "release" / "audit-packages.sh").read_text(
            encoding="utf-8"
        )
        self.assertIn('contents="$(dpkg-deb -c "${deb}")"', audit)
        self.assertNotIn('dpkg-deb -c "${deb}" | grep', audit)

    def test_release_keeps_build_state_until_all_native_gates_pass(self):
        package = (ROOT / "scripts" / "native" / "build-package.sh").read_text(
            encoding="utf-8"
        )
        release = (ROOT / "scripts" / "native" / "release-rpi.sh").read_text(
            encoding="utf-8"
        )
        self.assertIn('IROS2_CLEAN_AFTER_PACKAGE:-0', package)
        self.assertIn("IROS2_CLEAN_AFTER_PACKAGE=0", release)
        self.assertGreater(
            release.index('scripts/native/cleanup-build.sh'),
            release.index("printf 'PASS"),
        )

    def test_native_verification_restores_apt_configuration(self):
        verify = (ROOT / "scripts" / "release" / "verify-native.sh").read_text(
            encoding="utf-8"
        )
        self.assertIn('previous_source="${temporary}/previous-iros2j.list"', verify)
        self.assertIn('as_root rm -f -- "${source_list}" "${keyring}"', verify)
        self.assertIn('trap cleanup EXIT', verify)

    def test_native_gate_normalizes_manifest_line_endings(self):
        for script_name in ("create-native-gate.py", "verify-native-gate.py"):
            script = (
                ROOT / "scripts" / "release" / script_name
            ).read_text(encoding="utf-8")
            self.assertIn("text_sha256(args.manifest)", script)
            self.assertIn('.replace("\\r\\n", "\\n").replace("\\r", "\\n")', script)

    def test_release_preflight_allows_expected_missing_release(self):
        publisher = (
            ROOT / "scripts" / "release" / "publish-release.ps1"
        ).read_text(encoding="utf-8")
        self.assertIn('$ErrorActionPreference = "Continue"', publisher)
        self.assertIn("$releaseExists = $LASTEXITCODE -eq 0", publisher)
        self.assertIn("$tagExists = $LASTEXITCODE -eq 0", publisher)
        self.assertIn(
            "$ErrorActionPreference = $previousErrorActionPreference", publisher
        )

    def test_debian_packages_exclude_python_bytecode(self):
        builder = (ROOT / "scripts" / "native" / "build-debs.sh").read_text(
            encoding="utf-8"
        )
        self.assertIn("-name '*.pyc'", builder)
        self.assertIn("-name '*.pyo'", builder)
        self.assertLess(builder.index("-name '*.pyc'"), builder.index("dpkg-deb --build"))

    def test_post_release_smoke_is_fail_fast(self):
        verify = (ROOT / "scripts" / "release" / "verify-native.sh").read_text(
            encoding="utf-8"
        )
        self.assertIn("bash --noprofile --norc -e -c", verify)


if __name__ == "__main__":
    unittest.main()
