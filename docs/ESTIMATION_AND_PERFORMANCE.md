# Estimation, time tracking, and performance policy

This policy is normative for estimating work, measuring task effort, learning
from completed tasks, and improving throughput without weakening quality
gates.

## ClickUp estimate and timer

Before implementation, the linked ClickUp task must contain:

- built-in **Time Estimate** set to initial P50 tracked work;
- P50 and P80 tracked work, calendar range, and confidence (`low`, `medium`,
  or `high`) in its description;
- task type from `metrics/task-types.json`;
- estimation basis, comparable task IDs, risks, unknowns, expected machine
  time, and external wait.

P50 is median expected tracked work. P80 should cover approximately 80% of
comparable outcomes. The initial estimate is immutable history;
re-estimation adds a timestamped entry with previous/new values, reason, and
evidence.

The ClickUp start/stop tracker is authoritative for total task work:

1. verify that no unrelated timer is active;
2. start it before analysis, implementation, review, supervised build,
   verification, documentation, or publication;
3. identify the stage in the entry description;
4. stop it before waiting for user input, credentials, hardware, external
   approval, or an unsupervised long-running operation;
5. start a new entry when active work resumes;
6. at completion, copy the ClickUp total into the repository task record.

Actively monitored machine work is tracked. Unsupervised execution is
`machine_minutes`; waiting for external input is `external_wait_minutes`.
Calendar duration is measured separately. If ClickUp is unavailable, record
UTC start/end locally and add a manual entry when access returns.

## Estimation and recalculation

Estimate bottom-up. Every stage records expected tracked work, machine time,
external wait, uncertainty, prerequisites, and completion evidence.
Re-estimate after the initial audit, first minimal build, first complete build,
material blocker/scope change, and before the release gate.

The repository estimation database is:

- `metrics/task-types.json` — taxonomy and calibration settings;
- `metrics/tasks/<id>.json` — one record per GitHub/ClickUp task pair;
- `docs/task-reports/<id>.md` — completion report;
- `schema/task-record.schema.json` — record contract;
- `scripts/task_metrics.py` — validation, calibration, and report generation.

Use `github-<issue-number>` as the ID when possible. Never store credentials,
tokens, private host addresses, or non-public personal data.

## Operations and errors

Record each material operation with stage, category, duration, attempt,
`PASS`/`FAIL`/`BLOCKED`/`SKIPPED`, commit, evidence, and reusability.

Record every material error with stage, category, symptom, root cause,
correction, prevention, tracked/machine time lost, and invalidated evidence.
Failed attempts are calibration inputs and must not be hidden.

## Calibration

For a completed comparable task:

```text
estimate ratio = actual ClickUp tracked minutes / initial P50 minutes
```

Use the latest 5–10 completed records of the same type. The median ratio
calibrates P50; the empirical 80th percentile calibrates P80. With fewer than
five samples, apply an explicit risk factor and keep confidence `low`.
Outliers remain in history with annotations.

## Completion report

Before closing a task, generate and commit its report containing:

- linked GitHub and ClickUp tasks;
- initial/final estimates and confidence;
- ClickUp tracked total, calendar, machine, and external-wait durations;
- stage estimate-versus-actual table;
- operations, retries, errors, causes, fixes, and prevention;
- commits, tags, releases, checks, and evidence;
- escaped defects or confirmation that none are known;
- reusable improvements and future estimation recommendations.

A task cannot close while its record is `active`, tracked time is absent, or
the report is missing.

## Performance guardrails

Optimize in this order: remove duplicate work, resume verified checkpoints,
add preflight checks, use exact-input caches, parallelize independent stages,
then tune workers/resources.

An optimization is accepted only when mandatory gates are unchanged or
stronger; cache keys include source lock/toolchain/flags/OS/architecture; a
clean uncached comparison passes; outputs are equivalent; recovery remains
fail-closed; and escaped defects do not increase.

Never improve reported speed by stopping the timer during active work,
omitting failed attempts, moving work to an untracked task, or skipping a
gate.
