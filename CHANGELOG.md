# Changelog

## Process 1.5.9

- Made native APT verification transactional for its temporary source-list and
  keyring files.
- Restored any pre-existing iROS2j APT configuration after verification and
  removed temporary configuration on both PASS and failure.
- Added regression coverage for APT verification cleanup.

## Process 1.5.8

- Deferred native build/log cleanup until every packaging, audit, signing, SBOM,
  installation, and smoke-test gate has passed.
- Preserved build intermediates after failures so corrected runs can resume
  without recompiling the complete ROS graph.
- Added regression coverage for cleanup ordering.
- Required verified ClickUp checkpoint comments before marking material stages
  complete.
- Added pre-write terminal gates, post-write `status`/`date_closed`
  verification, and restoration rules for unexpected terminal transitions.

## Process 1.5.7

- Prevented successful `dpkg-deb` listing operations from being reported as
  failures when `grep -q` closes a pipe early under `pipefail`.
- Added regression coverage for complete package-audit input consumption.

## Process 1.5.6

- Normalized multi-package rosdep output into individual Debian dependency
  names before generating control files.
- Added regression coverage for Debian `Depends` tokenization.

## Process 1.5.5

- Excluded ROS package-group identifiers from Debian runtime dependencies;
  their Bloom-compatible dependencies are already explicitly declared.
- Treated Gazebo libraries bundled by source-building vendor packages as
  internal payload and RTI Connext as an optional proprietary backend.
- Added regression coverage for Debian 13 dependency classification.

## Process 1.5.4

- Included isolated vendor packages that intentionally omit an ament-index
  directory in the Debian package inventory.
- Made native-run exit-code recording independent of the subshell working
  directory.
- Added regression coverage for both native packaging and dispatch failures.

## Process 1.5.3

- Normalized Windows PowerShell CRLF input before remote Bash execution.
- Replaced the nested native-run command string with a background subshell
  that safely records the release exit code.

## Process 1.5.2

- Fixed Windows OpenSSH native dispatch by streaming multi-line remote scripts
  to `bash -s` instead of passing them as a command-line argument.
- Added regression coverage for native start and status polling transport.

## Process 1.5.1

- Corrected ClickUp comment verification: draft text is not evidence of
  publication.
- Required editor clearing, a separate authored Activity entry, and a fresh
  comment read before reporting a successful post.

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
