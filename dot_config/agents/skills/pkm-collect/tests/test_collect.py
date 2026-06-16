import sys, json, tempfile, unittest
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import collect


class TestCollectHelpers(unittest.TestCase):
    def test_classify_substantial_by_edit(self):
        d = {"edited_files": ["a"], "user_prompts": [], "produced_pr": False, "commit_count": 0}
        self.assertEqual(collect.classify(d, min_prompts=2, min_edits=1), "substantial")

    def test_classify_trivial(self):
        d = {"edited_files": [], "user_prompts": ["hi"], "produced_pr": False, "commit_count": 0}
        self.assertEqual(collect.classify(d, min_prompts=2, min_edits=1), "trivial")

    def test_classify_borderline(self):
        d = {"edited_files": [], "user_prompts": ["a", "b"], "produced_pr": False, "commit_count": 0}
        self.assertEqual(collect.classify(d, min_prompts=2, min_edits=1), "borderline")

    def test_sensitive_keyword(self):
        d = {"user_prompts": ["대장내시경 결과 정리"], "cwd": "/x"}
        self.assertTrue(collect.is_sensitive(d, ["대장내시경"], []))

    def test_sensitive_path(self):
        d = {"user_prompts": ["일반"], "cwd": "/Users/casper/private-repo"}
        self.assertTrue(collect.is_sensitive(d, [], ["private-repo"]))

    def test_resolve_since_marker(self):
        fd, p = tempfile.mkstemp(suffix=".json")
        Path(p).write_text(json.dumps({"last_run_ts": "2026-06-16T09:00:00+09:00"}))
        since = collect.resolve_since(p, None)
        self.assertEqual(since.hour, 9)
        Path(p).unlink()

    def test_resolve_since_fallback_midnight(self):
        since = collect.resolve_since("/nonexistent/marker.json", None)
        self.assertEqual((since.hour, since.minute, since.second), (0, 0, 0))


if __name__ == "__main__":
    unittest.main()
