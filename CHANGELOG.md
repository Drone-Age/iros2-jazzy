# Changelog

## 1.0.1 (unreleased)

- Started the native Debian 13 ARM64 `iros2j` package-line implementation.
- Replaced the monolithic package builder with per-ROS-package Debian metadata
  and exact internal snapshot dependencies.
- Removed Docker and AMD64 build entrypoints.
- Locked all Jazzy source repositories to exact commits.

## Process 1.1.0 (unreleased)

- Added deterministic package inventory generation, package audits, and signed
  APT repository construction.
- Added exact-source lock and native workspace preparation stages.

## Process 1.0.0

- Established canonical English and maintained Ukrainian normative documents.
- Separated the `iros2j` package version `1.0.0` from the repository release
  tag `v2.1.0.0`, whose leading component identifies ROS 2.
- Separated product versions from release-process versions and introduced
  immutable `process-v*` tags.
- Recorded the accepted `iros2j` per-ROS-package Debian model.
- Restricted v1 releases to native Debian 13 Trixie ARM64.
- Excluded AMD64, Docker, QEMU release builds, legacy monolithic packages, and
  VINS-NEO validation from the v1 scope.
- Added release issue, evidence, manifest, APT repository, and publication
  requirements.
