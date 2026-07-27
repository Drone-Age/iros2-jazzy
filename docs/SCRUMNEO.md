# ScrumNEO task lifecycle

This policy defines the ClickUp task-status lifecycle and task-comment rules
used by this repository. `TASK_MANAGEMENT.md` remains authoritative for the
GitHub/ClickUp relationship and evidence ownership.

## Status groups

| Group | Status | Meaning |
|---|---|---|
| Not started | `backlog` | Registered but not yet approved or scheduled. |
| Not started | `todo` | Approved, estimated, and ready to start. |
| Active | `preparation` | Supporting process, environment, documentation, access, or coordination work is active but does not directly execute the task deliverable. |
| Active | `analyse` | Requirements, constraints, risks, or a defect are being investigated. |
| Active | `planning` | Scope, stages, estimates, acceptance criteria, and owners are being prepared. |
| Active | `in progress` | Implementation or an execution gate is active. |
| Active | `in review` | Code, documentation, evidence, or results are under review. |
| Active | `completed` | Implementation and mandatory checks are complete; acceptance is pending. |
| Active | `accepted` | The owner accepted the result; administrative closure is pending. |
| Active | `rejected` | Review or acceptance failed; record the reason and required rework. |
| Active | `blocked` | Work cannot continue until a named input, event, permission, or dependency is provided. |
| Done | `complete` | The accepted outcome and all linked work items are complete. |
| Done | `cancelled` | Work was intentionally stopped or superseded without delivery. |
| Closed | `closed` | Archived terminal state; use only after `complete` or `cancelled`. |

## Transitions

The default successful flow is:

```text
backlog -> todo -> preparation -> analyse -> planning -> in progress -> in review
        -> completed -> accepted -> complete -> closed
```

`preparation` is used only while supporting work is the primary current
activity, for example establishing regulations, access, tooling, build
infrastructure, or task coordination. Work that examines the task's technical
requirements is `analyse`; work that defines its execution stages and
estimates is `planning`; work that creates the deliverable is `in progress`.

A task may skip `preparation`, `analyse`, or `planning` only when the applicable
results already exist and are linked or the stage is not needed. `rejected`
returns to `analyse`, `planning`, or `in progress` after its reason is
understood. `blocked` returns to the state representing resumed work.
Temporary `preparation` returns to the prior delivery state when preparation
finishes. The checkpoint comment must identify that prior state and resume
condition.

`complete` means successful delivery. `cancelled` means no delivery. `closed`
is archival and must not hide which terminal outcome occurred.

Set the status to the current state of the whole task, not an agent's
short-lived sub-operation.

### Status mutation safety

Every status change is a guarded mutation:

1. read the task and record its current status;
2. confirm the target is a valid transition for the whole task;
3. for `complete`, `cancelled`, or `closed`, require a terminal checkpoint
   comment and every completion gate in `TASK_MANAGEMENT.md`;
4. write only the intended status field;
5. immediately read the task again and verify both `status` and `date_closed`;
6. if an unexpected terminal status or closed date appears, restore the
   recorded non-terminal status, verify the restoration, and post an incident
   comment before other task mutations continue.

`closed` must never be used as a shortcut for a finished stage, a temporary
pause, an agent turn ending, or a successful sub-operation. Automated work
must fail closed before a terminal mutation when its terminal gate cannot be
proved.

## Task comments

ClickUp comments are the chronological coordination log. The description holds
the current objective, scope, estimate, checklist, and summary; comments record
material events without rewriting history.

Write a comment for:

- approval, scope, version, estimate, or priority changes;
- analysis or planning completion;
- a pushed commit or pull request ready for review;
- PASS/FAIL build, test, audit, migration, or release-gate results;
- a blocker appearing, changing, or clearing;
- rejection and the exact rework requested;
- owner acceptance;
- tag, release, artifact, or post-release verification publication;
- cancellation or final completion.

A material stage is not recorded as complete until its ClickUp checkpoint
comment is published and verified. Update the task checklist and publish the
comment in the same checkpoint; if comment publication is unavailable, leave
the stage unchecked until the documented fallback evidence is recorded.

Do not comment for routine commands, unchanged polling, transient progress, or
information already in the immediately preceding comment. Aggregate related
low-level actions into one checkpoint.

Each checkpoint comment should contain:

```text
Stage/status:
Result: PASS | FAIL | BLOCKED | INFO
Completed:
Evidence: commit, issue, PR, log, artifact, or release link
Next:
Blocker/owner action: none, or exact required action
Estimate impact: none, or revised P50/P80 with reason
```

Use UTC timestamps for automated comments. Notify assignees only when their
decision or action is required, or when an accepted release is published. A
comment does not replace durable GitHub technical evidence.

## Comment integration fallback

After posting, verify all of the following:

- the editor is cleared;
- Activity shows a separate comment entry with an author and timestamp;
- a fresh comment read returns the new comment or its identifier.

Text still visible in the editor or merely present elsewhere on the page is
not publication evidence. If the ClickUp comment API fails:

1. do not repeatedly submit the same mutation;
2. post through the authenticated ClickUp interface when available, using its
   supported submit shortcut or control, then perform all verification checks
   above;
3. if interface posting is unavailable, update the task current summary and
   record the connector limitation in the repository task error log;
4. retain durable evidence and the full checkpoint in the linked GitHub Issue;
5. restore the missing ClickUp comment after integration access is repaired.
