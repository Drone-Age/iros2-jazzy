# Documentation policy

This policy is normative for repository documentation.

## Language and file convention

English is canonical for machine-facing interpretation. Every human-facing
normative document has a Ukrainian counterpart named `NAME.uk.md` in the same
directory. Both files must be updated in the same commit and must express the
same requirements and acceptance criteria. Identifiers, commands, paths,
versions, fields, and tags are not translated.

`AGENTS.md` is intentionally English-only to give automation one unambiguous
instruction source.

## What is normative

Policies, regulations, mandatory checklists, contributor rules, migration
decisions, release procedures, schemas, and public operational instructions
are normative. A change is incomplete if its translation, navigation links,
changelog entry, or required process-version increment is missing.

If translations conflict, English controls execution. The mismatch is still a
defect and must be corrected before a process or product release.

## Requirement language and status

`MUST`, `MUST NOT`, `SHOULD`, and `MAY` have their usual normative meanings.
Documents must distinguish implemented behavior from an accepted target.
Planned v1 requirements must not be advertised as available in the currently
published 0.1.x package.

Historical instructions must begin with a visible legacy notice once they are
superseded. Do not silently rewrite instructions for an already published tag.
