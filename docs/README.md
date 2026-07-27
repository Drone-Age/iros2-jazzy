# Documentation

This index identifies the normative source of truth for the `iros2j` v1
migration and release process. English is canonical; Ukrainian files are
mandatory maintained translations.

## Normative documents

- [Documentation policy](DOCUMENTATION_POLICY.md) /
  [Ukrainian](DOCUMENTATION_POLICY.uk.md)
- [Versioning and tags](VERSIONING.md) /
  [Ukrainian](VERSIONING.uk.md)
- [Package policy](PACKAGE_POLICY.md) /
  [Ukrainian](PACKAGE_POLICY.uk.md)
- [Release process](RELEASE_PROCESS.md) /
  [Ukrainian](RELEASE_PROCESS.uk.md)
- [Task management and cross-session continuity](TASK_MANAGEMENT.md) /
  [Ukrainian](TASK_MANAGEMENT.uk.md)
- [v1 migration plan](V1_MIGRATION_PLAN.md) /
  [Ukrainian](V1_MIGRATION_PLAN.uk.md)

Legacy 0.1.x Docker, AMD64, monolithic packaging, installation, and
verification instructions were removed when the `iros2j` implementation
started. Published tags retain the historical source.

## Process model

The process structure is adapted from
[`Drone-Age/iMAVROS-release`](https://github.com/Drone-Age/iMAVROS-release):
independent product/process versions, immutable product and `process-v*` tags,
bilingual normative pairs, release issues, pinned manifests, commit-bound
native evidence, and tags created only after gates pass. Project-specific
iMAVROS requirements such as FCU hardware testing were not copied.
