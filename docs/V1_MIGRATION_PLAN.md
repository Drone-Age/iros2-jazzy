# `iros2j` v1 migration plan

This checklist is the definition of readiness for `v2.1.0.0`. Checked items must
be supported by committed code, tests, or release evidence.

## Packaging

- [ ] Generate one Debian package per ROS package using the deterministic
      `iros2j-*` mapping.
- [ ] Generate exact internal dependency relationships and official-style
      metapackages.
- [ ] Install the complete distribution under `/opt/iros2j`.
- [ ] Remove all legacy monolithic package definitions and payload ownership.
- [ ] Define and test the explicit clean transition from installed 0.1.x.
- [ ] Produce a signed APT repository snapshot and bootstrap installer.

## Build scope

- [ ] Remove Dockerfiles, Docker entrypoints, container helpers, Buildx
      scripts, and Docker build documentation.
- [ ] Remove AMD64 build, publication, verification, and support paths.
- [ ] Make native Debian 13 Trixie ARM64 the only binary release path.
- [ ] Ensure no VINS-NEO validation is present in this repository.

## Metadata and gates

- [ ] Add a versioned component/release manifest and machine-readable schema.
- [ ] Pin upstream commits, upstream package versions, dependencies, toolchain,
      package set, architecture, and install prefix.
- [ ] Add staged-index and committed-snapshot metadata validators.
- [ ] Add package naming, dependency, ownership, ELF, clean-install, APT,
      checksum, SBOM, and evidence gates.
- [ ] Add resumable native build execution with immutable run identity and
      fail-closed status.
- [ ] Add a publisher that creates the tag only after evidence passes and
      refuses existing tags/releases.

## Documentation and release

- [ ] Replace legacy user installation instructions with the APT workflow.
- [ ] Add versioned `v2.1.0.0` release notes and final package inventory.
- [ ] Set `VERSION` to `1.0.0` only in the actual release preparation change;
      use repository tag `v2.1.0.0`.
- [ ] Pass the complete native gate on the exact pushed release commit.
- [ ] Publish immutable `v2.1.0.0` and complete clean-host post-release
      verification.
