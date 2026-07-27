# Task management and cross-session continuity

This policy is normative for implementation, process, documentation, and
release work in this repository.

Time estimates, ClickUp timer use, historical metrics, and completion reports
are governed by `ESTIMATION_AND_PERFORMANCE.md`.

## 1. Work-item requirement

Material work must have:

1. one open GitHub Issue in the repository;
2. one ClickUp task in the appropriate component list;
3. reciprocal links between them;
4. an explicit approval state before implementation begins.

Small typo-only corrections may be recorded directly in a pull request or
commit when they do not change behavior, scope, or process.

The GitHub Issue title should use `[APPROVED]` after scope approval. Apply the
`approved` label and the relevant type label such as `release`,
`enhancement`, `bug`, or `documentation`.

## 2. Source-of-truth ownership

GitHub is authoritative for:

- source code and documentation snapshots;
- commits, branches, pull requests, tags, and releases;
- technical scope and definition of done;
- build/test commands, logs, checksums, manifests, and gate evidence;
- immutable historical state.

ClickUp is authoritative for:

- planning status, priority, owner, schedule, and coordination;
- business objective and cross-component impact;
- stage checklist and current blocker summary;
- links to related tasks outside this repository.

Duplicate information must remain technically equivalent. If the systems
differ, immutable Git evidence controls technical facts; ClickUp controls
current planning state. Correct the mismatch at the next checkpoint.

## 3. Required task content

Both linked items must identify:

- objective and user-visible result;
- approved scope and explicit exclusions;
- product version/tag and process version/tag when applicable;
- current source or build commit;
- ordered stages with checkboxes;
- acceptance criteria;
- known risks, external dependencies, and blockers;
- evidence links for completed gates.

Do not mark a stage complete merely because code was written. Completion
requires its stated check or evidence.

## 4. Status mapping

Use this default mapping:

| Work state | GitHub | ClickUp |
|---|---|---|
| Proposed | Open Issue without `approved` | `planning` |
| Approved, not started | Open Issue with `approved` | `to do` |
| Active implementation or gate | Open Issue | `in progress` |
| External input temporarily required | Open Issue with blocker comment | `on hold` |
| Material defect or schedule risk | Open Issue with risk comment | `at risk` |
| Scope/process must be revised | Open Issue with proposed change | `update required` |
| Accepted and published | Closed as completed | `complete` |
| Rejected or superseded | Closed as not planned | `cancelled` |

A blocker does not close the task. Record the exact missing input, last
successful checkpoint, and safe resume command.

## 5. Checkpoints and progress updates

Update both systems after each material checkpoint:

- approved scope or version changes;
- commit pushed for review/build;
- build, test, audit, or release gate result;
- blocker appearance, change, or removal;
- manifest finalization;
- tag or release publication;
- post-release verification.

Start the ClickUp timer before active checkpoint work and stop it whenever
active work pauses. A chat session is not a time record.

Each checkpoint update includes:

- UTC timestamp when produced by automation;
- exact commit SHA;
- completed and next stage;
- commands/checks and PASS/FAIL result;
- links to logs, artifacts, pull requests, releases, or evidence;
- blocker and required owner action, if any.

GitHub receives durable technical evidence. ClickUp receives the concise
planning summary and links back to that evidence. Updating only a chat message
does not satisfy this policy.

## 6. Scope and version changes

When approved scope changes:

1. update the GitHub Issue and ClickUp task before implementation continues;
2. record who approved the change and why;
3. update applicable normative documents and version files;
4. identify invalidated checks or artifacts;
5. repeat every affected gate.

Product and process versions follow `VERSIONING.md`. Never move or reuse a tag
to make task tracking appear consistent.

## 7. New-session startup protocol

`AGENTS.md` is the automatic entrypoint for a new agent session. Before making
changes, the session must:

1. read `docs/README.md` and this policy;
2. inspect repository status, current branch, `VERSION`, and
   `PROCESS_VERSION`;
3. locate the linked GitHub Issue and ClickUp task from the current work
   context;
4. read their latest state and compare it with Git;
5. identify the last verified checkpoint, next unchecked stage, and blockers;
6. post updates only when state materially changes.

If no linked task can be identified safely, stop implementation, report the
missing linkage, and request the task identifier. Do not create duplicate work
items speculatively.

## 8. Completion

Before closing linked tasks:

1. all acceptance criteria and mandatory gates pass;
2. final commits and immutable tags are pushed;
3. release/evidence links are present in both systems;
4. documentation and versions match the published state;
5. GitHub Issue is closed as completed;
6. ClickUp checklist is complete and status is `complete`.

Post-release defects create a new linked task and PATCH version. They do not
reopen or rewrite immutable release history.
