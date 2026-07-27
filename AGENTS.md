# Agent instructions

## Normative documentation

- Read `docs/README.md` before changing packaging, build, test, or release
  behavior.
- Before starting or resuming implementation work, read
  `docs/TASK_MANAGEMENT.md` and identify the linked GitHub Issue and ClickUp
  task. If either link is missing, establish it before reporting progress.
- Read `docs/SCRUMNEO.md` before changing a ClickUp task status or posting a
  task comment. Use comments for material chronological checkpoints and verify
  automated comment creation by reading the task activity.
- Read `docs/ESTIMATION_AND_PERFORMANCE.md`. Before task work, ensure the
  ClickUp task has an initial estimate and start its time tracker. Stop the
  tracker when work pauses, waits for external input, or the session ends.
- English normative documents are the canonical source for machine-facing
  interpretation. Ukrainian `.uk.md` files are mandatory human-facing
  counterparts.
- Update both language versions in the same commit. Commands, paths, package
  names, versions, schema fields, and tags are not translated.
- If the language versions disagree, follow the English text, report the
  mismatch as a documentation defect, and correct both files in scope.

## Accepted v1 product constraints

- The Debian package namespace is `iros2j`.
- `jazzy` remains the internal ROS distribution identifier but is not part of
  an `iros2j-*` Debian package name.
- The supported release platform is native Debian 13 Trixie ARM64 only.
- AMD64, Docker, QEMU release builds, monolithic `iros2-*` packages, and
  VINS-NEO validation are outside the v1 release scope.
- Do not reintroduce any excluded target or compatibility alias without a
  separately reviewed process change.

## Process changes

Changes to policies, required checklists, release metadata, validators,
publication scripts, issue forms, or automation must follow
`docs/DOCUMENTATION_POLICY.md` and `docs/VERSIONING.md`.

## Work tracking

- GitHub is the source of truth for repository state, commits, tags, pull
  requests, release evidence, and technical definition of done.
- ClickUp is the source of truth for planning status, business scope,
  ownership, priorities, blockers, and cross-component visibility.
- Update both linked work items at every material checkpoint according to
  `docs/TASK_MANAGEMENT.md`.
- Maintain the repository task record, operation/error log, and completion
  report according to `docs/ESTIMATION_AND_PERFORMANCE.md`.
