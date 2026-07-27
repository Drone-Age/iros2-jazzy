# `iros2j` release process

This is the mandatory process for v1 product releases. The immutable
`v2.1.0.0` baseline already exists; the first complete package implementation
must pass this process as package version `1.0.1` and tag `v2.1.0.1`.

## 1. Open and pin the release

Create a Release issue. Record product version, proposed immutable tag,
`PROCESS_VERSION`, scope, source commit, Debian 13 ARM64 builder identity, and
known risks. Generate a versioned component manifest that pins every upstream
repository commit, upstream package version, resolved external dependency,
toolchain version, build configuration, and expected package set.

Update and stage together:

- `VERSION`;
- the versioned component/release manifest;
- `CHANGELOG.md`;
- versioned release notes;
- package index metadata inputs.

## 2. Validate the committed snapshot

Metadata validation must run first against the staged Git index and then
against the resulting commit. It must reject working-tree-only release data,
unpinned sources, package-name mapping violations, dependency references to
legacy packages, version disagreement, missing bilingual documentation, and
an incomplete package set.

Do not create a product tag yet.

## 3. Native Debian 13 ARM64 gate

Build the exact pushed commit on a native Debian 13 Trixie `aarch64` host.
Record host identity, OS, kernel, compiler, glibc, Python, CMake, colcon,
resolved dependencies, source commits, timestamps, and complete logs.

The gate must:

1. build every package and metapackage in dependency order;
2. run available unit and integration tests;
3. verify package names, versions, architectures, dependencies, ownership,
   install prefix, and absence of build-host paths;
4. run `ldd` on every ELF and reject every unresolved library;
5. create and verify the signed APT repository metadata;
6. install the selected metapackage from that repository on a clean Debian 13
   ARM64 system;
7. verify `ros2` discovery and representative runtime smoke tests in a clean
   shell;
8. verify uninstall/upgrade behavior from legacy 0.1.x where applicable;
9. produce checksums, SBOM, package/component manifest, and fail-closed
   versioned evidence.

VINS-NEO build, installation, and smoke testing are explicitly outside this
repository's gate. AMD64, Docker, and QEMU checks must not be added to the v1
release sequence.

After the native run passes, finalize the draft manifest with artifact hashes
and the exact build commit:

```bash
python3 scripts/release/finalize-release.py \
  --manifest manifests/iros2j-<version>.json \
  --artifacts artifacts \
  --build-commit <native-build-commit>
```

Commit and push that finalized metadata snapshot. On the same native ARM64
host, create `native-gate.json` for the finalized release commit with
`create-native-gate.py`. The build commit and release commit are recorded
separately; only release metadata may differ between them.

## 4. Publish

Publication tooling must bind the successful native evidence to the exact
source commit, manifest hash, APT repository snapshot, and artifact hashes. It
must reject an existing tag or release.

Only after all gates pass may it create the generation-qualified product tag
defined by `VERSIONING.md` (for package version `1.0.1`, `v2.1.0.1`) at that
commit and upload the APT bootstrap/repository bundle, checksums, manifests,
SBOM, logs/evidence, and committed release notes. The tag and release assets
are immutable.

## 5. Post-release verification

On a clean supported ARM64 host, resolve the published tag to the gated commit,
download the published repository metadata, verify signatures and checksums,
install through APT, and repeat the clean-shell runtime smoke test. Record the
result in the Release issue before closing it.

If a defect is found after tagging, mark the release defective and publish a
new PATCH release after repeating the complete gate. Never move or reuse the
old tag.
