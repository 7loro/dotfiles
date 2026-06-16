import sys, unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import notes_index

NOTES = Path(__file__).resolve().parent / "fixtures" / "notes"


class TestNotesIndex(unittest.TestCase):
    def setUp(self):
        self.idx = notes_index.build_notes_index(NOTES)

    def test_indexes_all_md(self):
        self.assertEqual(len(self.idx), 2)

    def test_pr_fields_parsed(self):
        pr = next(e for e in self.idx if e["title"] == "PR도큐먼트")
        self.assertEqual(pr["pr_url"], "https://github.com/o/r/pull/42")
        self.assertEqual(pr["repository"], "akira-mac")
        self.assertEqual(pr["date"], "2026-06-16")

    def test_non_pr_has_none(self):
        gen = next(e for e in self.idx if e["title"] == "일반노트")
        self.assertIsNone(gen["pr_url"])

    def test_pr_url_set(self):
        self.assertEqual(
            notes_index.pr_url_set(self.idx),
            {"https://github.com/o/r/pull/42"},
        )


if __name__ == "__main__":
    unittest.main()
