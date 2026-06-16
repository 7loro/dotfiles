import sys, unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import claude_digest

FIX = Path(__file__).resolve().parent / "fixtures" / "claude_sample.jsonl"


class TestClaudeDigest(unittest.TestCase):
    def setUp(self):
        self.d = claude_digest.parse_claude_transcript(FIX)

    def test_returns_digest(self):
        self.assertIsNotNone(self.d)
        self.assertEqual(self.d["source"], "claude")
        self.assertEqual(self.d["session_id"], "sess-1")
        self.assertEqual(self.d["project"], "akira-mac")

    def test_real_prompt_only(self):
        # 노이즈(<command-name>)는 제외, 실제 프롬프트 1개만
        self.assertEqual(self.d["user_prompts"], ["전사 정확도 개선해줘"])

    def test_edit_and_commit_and_pr(self):
        self.assertIn("lib/stt.dart", self.d["edited_files"])
        self.assertEqual(self.d["commit_count"], 1)
        self.assertTrue(self.d["produced_pr"])
        self.assertEqual(self.d["pr_url"], "https://github.com/o/r/pull/42")

    def test_no_timestamp_returns_none(self):
        import tempfile, os
        fd, p = tempfile.mkstemp(suffix=".jsonl")
        os.write(fd, b'{"type":"user","message":{"role":"user","content":"hi"}}\n')
        os.close(fd)
        self.assertIsNone(claude_digest.parse_claude_transcript(p))
        os.unlink(p)

    def test_pr_url_ignored_without_creation(self):
        # gh pr create / make-pr 없이 트랜스크립트에 PR 링크만 출력된 세션은 PR로 오인하지 않음
        import tempfile, os, json as _json
        lines = [
            {"type": "user", "userType": "external", "timestamp": "2026-06-16T01:00:00.000Z",
             "cwd": "/x", "sessionId": "s2", "message": {"role": "user", "content": "리뷰 좀 봐줘"}},
            {"type": "user", "userType": "external", "timestamp": "2026-06-16T01:01:00.000Z",
             "cwd": "/x", "sessionId": "s2",
             "message": {"role": "user", "content": [{"type": "tool_result",
                         "content": "참고: https://github.com/o/r/pull/99"}]}},
        ]
        fd, p = tempfile.mkstemp(suffix=".jsonl")
        os.write(fd, ("\n".join(_json.dumps(x) for x in lines)).encode("utf-8"))
        os.close(fd)
        d = claude_digest.parse_claude_transcript(p)
        os.unlink(p)
        self.assertFalse(d["produced_pr"])
        self.assertIsNone(d["pr_url"])


if __name__ == "__main__":
    unittest.main()
