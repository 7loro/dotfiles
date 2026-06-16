import sys, unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import codex_digest

FX = Path(__file__).resolve().parent / "fixtures"
HIST = FX / "codex_history.jsonl"
ROLL = FX / "codex_rollout"


class TestCodexDigest(unittest.TestCase):
    def test_history_since_filter(self):
        # since=1781000000 → sessOLD(1700000000) 제외, sessAA만
        sess = codex_digest.load_codex_history(HIST, 1781000000)
        self.assertIn("sessAA", sess)
        self.assertNotIn("sessOLD", sess)
        self.assertEqual(sess["sessAA"]["prompts"], ["코덱스로 리팩토링 해줘", "테스트도 추가"])

    def test_build_digests_signals(self):
        digs = codex_digest.build_codex_digests(HIST, ROLL, 1781000000)
        self.assertEqual(len(digs), 1)
        d = digs[0]
        self.assertEqual(d["source"], "codex")
        self.assertEqual(d["session_id"], "sessAA")
        self.assertEqual(d["project"], "akira-mac")
        self.assertIn("lib/foo.dart", d["edited_files"])
        self.assertTrue(d["produced_pr"])
        self.assertEqual(d["pr_url"], "https://github.com/o/r/pull/7")


if __name__ == "__main__":
    unittest.main()
