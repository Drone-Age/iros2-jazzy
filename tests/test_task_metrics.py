import unittest

from scripts.task_metrics import calibrated_estimate, records, validate_all


class TaskMetricsTests(unittest.TestCase):
    def test_repository_records_validate(self):
        validate_all()

    def test_single_sample_keeps_p80_conservative(self):
        result = calibrated_estimate("release-engineering", 100)
        self.assertEqual(result["samples"], 1)
        self.assertEqual(result["recommended_p50_minutes"], 10)
        self.assertGreaterEqual(result["recommended_p80_minutes"], 150)
        self.assertEqual(result["confidence"], "low")

    def test_current_task_records_operations_and_errors(self):
        current = next(record for record in records() if record["id"] == "github-6")
        self.assertTrue(current["operations"])
        self.assertTrue(current["errors"])
        self.assertEqual(current["status"], "completed")
        self.assertEqual(current["actual"]["clickup_tracked_minutes"], 228.6)
        self.assertTrue(current["completion_report"])


if __name__ == "__main__":
    unittest.main()
