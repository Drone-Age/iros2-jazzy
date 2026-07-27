# Completion report: GitHub Issue #6

## Outcome

Published and post-release verified
[`v2.1.0.2`](https://github.com/Drone-Age/iros2_0/releases/tag/v2.1.0.2)
for Debian 13 Trixie ARM64. The release contains 244 separate `iros2j`
packages, a signed APT snapshot, checksums, package inventory, SPDX SBOM, and
commit-bound native evidence.

`v2.1.0.1` remains immutable but is superseded: post-release verification
found incompatible cached Python bytecode and a smoke verifier that could mask
an earlier failed command. Corrective release 1.0.2 excludes `.pyc`/`.pyo` and
runs every ROS/RViz smoke command fail-fast.

## Estimate versus actual

| Measure | Initial P50 | Initial P80 | Actual |
|---|---:|---:|---:|
| ClickUp tracked work | 2,400 min | 3,600 min | 228.6 min |
| Calendar duration | 10,080 min | 20,160 min | 265.4 min |
| Machine time | 720 min | — | 142 min |
| External wait | 2,880 min | — | 0 min |

The cold-start estimate was intentionally conservative because no completed
per-package iROS2j release sample existed. This task is now the calibration
baseline. Future comparable releases should estimate packaging-only fixes
separately from source-graph changes.

## Key retries and errors

- Native packaging exposed vendor discovery, dependency classification,
  dependency tokenization, dispatcher transport, audit pipe handling, and APT
  cleanup defects. Each received regression coverage.
- Premature cleanup caused one unnecessary 49-minute rebuild. Cleanup now runs
  only after all native gates pass.
- A ClickUp task briefly entered `Closed` while active. Terminal states now
  require a pre-write gate, a terminal comment, and read-after-write validation
  of both `status` and `date_closed`.
- Post-release verification of 1.0.1 exposed the only escaped defect. The
  corrective 1.0.2 release passed archive bytecode inspection and download,
  checksum, installation, `ros2`, package-prefix, and RViz checks.

## Reusable improvements

- Preserve build state until every downstream gate passes.
- Never ship interpreter-specific Python caches.
- Run post-release validation against published assets, not local artifacts.
- Treat a ClickUp stage as complete only after its checklist and verified
  comment are both updated.
- Record each retry with symptom, root cause, correction, prevention, and lost
  time in the repository metrics record.
