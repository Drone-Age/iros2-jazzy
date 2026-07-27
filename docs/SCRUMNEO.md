# ScrumNEO task lifecycle

This policy defines the ClickUp task-status lifecycle and task-comment rules
used by this repository. `TASK_MANAGEMENT.md` remains authoritative for the
GitHub/ClickUp relationship and evidence ownership.

## Status groups

| Group | Status | Meaning |
|---|---|---|
| Not started | `backlog` | Registered but not yet approved or scheduled. |
| Not started | `todo` | Approved, estimated, and ready to start. |
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
backlog -> todo -> analyse -> planning -> in progress -> in review
        -> completed -> accepted -> complete -> closed
```

A task may skip `analyse` or `planning` only when those results already exist
and are linked. `rejected` returns to `analyse`, `planning`, or `in progress`
after its reason is understood. `blocked` returns to the state representing
resumed work. Its comment must identify the prior state and resume condition.

`complete` means successful delivery. `cancelled` means no delivery. `closed`
is archival and must not hide which terminal outcome occurred.

Set the status to the current state of the whole task, not an agent's
short-lived sub-operation.

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

After automated posting, read the task comments and verify the new comment. If
the ClickUp comment API fails:

1. do not repeatedly submit the same mutation;
2. post through the authenticated ClickUp interface when available and verify
   it in task activity;
3. if interface posting is unavailable, update the task current summary and
   record the connector limitation in the repository task error log;
4. retain durable evidence and the full checkpoint in the linked GitHub Issue;
5. restore the missing ClickUp comment after integration access is repaired.

