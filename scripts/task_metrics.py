#!/usr/bin/env python3
"""Validate task history, calibrate estimates, and generate completion reports."""

from __future__ import annotations

import argparse
import json
import math
import statistics
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TASKS = ROOT / "metrics" / "tasks"
TYPES = ROOT / "metrics" / "task-types.json"


def load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def records() -> list[dict]:
    return [load(path) for path in sorted(TASKS.glob("*.json"))]


def validate_record(record: dict, task_types: dict) -> None:
    assert record["schema_version"] == 1
    assert record["id"].startswith("github-")
    assert record["task_type"] in task_types
    assert record["status"] in {"planned", "active", "blocked", "completed", "cancelled"}
    assert record["links"]["github"].startswith("https://github.com/")
    assert record["links"]["clickup"].startswith("https://app.clickup.com/")
    assert record["estimates"]
    initial = record["estimates"][0]
    assert initial["kind"] == "initial"
    assert initial["p50_tracked_minutes"] > 0
    assert initial["p80_tracked_minutes"] >= initial["p50_tracked_minutes"]
    assert initial["confidence"] in {"low", "medium", "high"}
    for operation in record["operations"]:
        assert operation["result"] in {"PASS", "FAIL", "BLOCKED", "SKIPPED"}
        assert operation["attempt"] >= 1
    if record["status"] == "completed":
        assert record["actual"]["clickup_tracked_minutes"] is not None
        assert record["actual"]["completed_at"]
        assert record["completion_report"]
        assert (ROOT / record["completion_report"]).is_file()


def validate_all() -> None:
    types = load(TYPES)["types"]
    for record in records():
        validate_record(record, types)
    print(f"Validated {len(records())} task records and {len(types)} task types.")


def percentile(values: list[float], fraction: float) -> float:
    ordered = sorted(values)
    return ordered[max(0, math.ceil(len(ordered) * fraction) - 1)]


def calibrated_estimate(task_type: str, base_minutes: int) -> dict:
    config = load(TYPES)["types"][task_type]
    comparable = []
    for record in records():
        actual = record["actual"]["clickup_tracked_minutes"]
        if record["task_type"] == task_type and record["status"] == "completed" and actual:
            comparable.append(actual / record["estimates"][0]["p50_tracked_minutes"])
    comparable = comparable[-10:]
    if comparable:
        p50_ratio = statistics.median(comparable)
    else:
        p50_ratio = 1.0
    if len(comparable) >= config["minimum_calibration_samples"]:
        p80_ratio = percentile(comparable, 0.8)
        confidence = "medium" if len(comparable) < 10 else "high"
    else:
        p80_ratio = max(p50_ratio, config["cold_start_p80_factor"])
        confidence = "low"
    return {
        "task_type": task_type,
        "samples": len(comparable),
        "base_minutes": base_minutes,
        "recommended_p50_minutes": math.ceil(base_minutes * p50_ratio),
        "recommended_p80_minutes": math.ceil(base_minutes * p80_ratio),
        "confidence": confidence,
        "ratios": comparable,
    }


def render_report(record: dict) -> str:
    initial = record["estimates"][0]
    actual = record["actual"]
    operations = "\n".join(
        f"- `{item['result']}` {item['stage']}/{item['category']}: {item['summary']}"
        for item in record["operations"]
    ) or "- None recorded."
    errors = "\n".join(
        f"- **{item['category']}**: {item['symptom']}  \n"
        f"  Cause: {item['root_cause']}  \n"
        f"  Prevention: {item['prevention']}"
        for item in record["errors"]
    ) or "- No material errors recorded."
    return f"""# Task report: {record['id']}

## Links

- GitHub: {record['links']['github']}
- ClickUp: {record['links']['clickup']}

## Estimate and actual

| Metric | Initial | Actual |
|---|---:|---:|
| ClickUp tracked work | {initial['p50_tracked_minutes']} min P50 / {initial['p80_tracked_minutes']} min P80 | {actual['clickup_tracked_minutes']} min |
| Calendar duration | {initial['p50_calendar_minutes']} min P50 / {initial['p80_calendar_minutes']} min P80 | {actual['calendar_minutes']} min |
| Machine time | {initial['machine_minutes']} min | {actual['machine_minutes']} min |
| External wait | {initial['external_wait_minutes']} min | {actual['external_wait_minutes']} min |

Confidence: `{initial['confidence']}`.

## Operations

{operations}

## Errors and prevention

{errors}

## Deliverables

{chr(10).join(f"- {item}" for item in record['deliverables']) or "- None recorded."}

## Reusable improvements

{chr(10).join(f"- {item}" for item in record['reusable_improvements']) or "- None recorded."}

## Escaped defects

{record['escaped_defects']}
"""


def main() -> int:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("validate")
    estimate = subparsers.add_parser("estimate")
    estimate.add_argument("--type", required=True)
    estimate.add_argument("--base-minutes", type=int, required=True)
    report = subparsers.add_parser("report")
    report.add_argument("--record", type=Path, required=True)
    report.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    if args.command == "validate":
        validate_all()
    elif args.command == "estimate":
        print(json.dumps(calibrated_estimate(args.type, args.base_minutes), indent=2))
    else:
        record = load(args.record)
        if record["status"] != "completed":
            raise SystemExit("completion report requires status=completed")
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(render_report(record), encoding="utf-8")
        print(f"Generated {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
