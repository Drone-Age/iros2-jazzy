# Contributing

Read the [documentation index](docs/README.md) before changing packaging,
build, test, or release behavior.

Changes to regulations, mandatory checklists, release metadata, schemas, issue
forms, validators, publication scripts, or automation are process changes.
They must:

1. update the canonical English document and its `.uk.md` counterpart;
2. update `PROCESS_VERSION` according to `docs/VERSIONING.md`;
3. describe the change under a `Process` heading in `CHANGELOG.md`;
4. pass the documentation and applicable release-process checks;
5. be committed and published under a new immutable `process-v*` tag before
   the changed process is used for a product release.

Product implementation work must satisfy `docs/PACKAGE_POLICY.md` and
`docs/RELEASE_PROCESS.md`. Every implementation task must also follow the
linked GitHub/ClickUp workflow in `docs/TASK_MANAGEMENT.md`.
