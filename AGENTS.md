# Agent instructions

## Normative documentation

- Read `docs/README.md` before changing packaging, build, test, or release
  behavior.
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
