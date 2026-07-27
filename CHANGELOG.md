# Changelog

## Process 1.5.0

- Added `preparation` for supporting work that does not directly execute the
  task deliverable.
- Distinguished preparation from technical analysis, execution planning, and
  implementation.
- Required temporary preparation to record and return to the prior delivery
  state.

## Process 1.4.0

- Added the normative ScrumNEO task lifecycle for Indra Workspace.
- Defined status meanings, successful and return transitions, terminal
  outcomes, and whole-task status semantics.
- Made ClickUp checkpoint comments part of task history and defined their
  content, notification rules, verification, and connector fallback.
- Made new agent sessions load the ScrumNEO policy automatically.

## Process 1.3.0

- Made ClickUp time estimates and start/stop time tracking mandatory.
- Added calibrated P50/P80 estimation, confidence, machine wait, external wait,
  and calendar-duration rules.
- Added the versioned task/type history, operation/error records, estimation
  helper, validators, and mandatory completion reports.
- Added performance optimization guardrails that preserve release gates and
  require clean-run validation.

## Process 1.2.0

- Added the mandatory GitHub/ClickUp task-management policy.
- Defined reciprocal linking, source-of-truth ownership, status mapping,
  checkpoint evidence, blocker handling, and cross-session continuation.
- Made `AGENTS.md` load the task-management policy for every new agent session.

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
