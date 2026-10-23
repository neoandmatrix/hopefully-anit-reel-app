"""Offline tests: python -m unittest pipeline/test_pipeline.py (from repo root) or
`python -m unittest test_pipeline` from pipeline/."""

import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import common
from common import clean_card, validate_card
from fetch_news import Story, dedupe, extract_text

GOOD = {
    "headline": "RBI keeps repo rate unchanged at its October meeting",
    "body": " ".join(["word"] * 55),
    "why_it_matters": "Loan EMIs stay the same.",
    "key_fact": "Repo rate unchanged",
    "quiz": {"q": "Who sets the repo rate?", "options": ["MPC", "SEBI", "NITI Aayog", "CAG"], "answer": 0},
    "tags": ["RBI"],
    "unexpected": "dropped",
}


class CardTests(unittest.TestCase):
    def card(self, **overrides):
        raw = {**GOOD, **overrides}
        return clean_card(raw, id="news-1", type="news", category="economy", date="2026-10-23",
                          source_url="https://example.com")

    def test_good_card_passes_and_unknown_keys_are_dropped(self):
        card = self.card()
        self.assertEqual(validate_card(card), [])
        self.assertNotIn("unexpected", card)
        self.assertEqual(card["source_url"], "https://example.com")

    def test_bad_quiz_rejected(self):
        for quiz in (
            {"q": "x", "options": ["a", "b", "c"], "answer": 0},           # 3 options
            {"q": "x", "options": ["a", "b", "c", "d"], "answer": 4},      # out of range
            {"q": "x", "options": ["a", "a", "c", "d"], "answer": 0},      # duplicate
            {"q": "x", "options": ["a", "b", "c", "d"], "answer": "0"},    # wrong type
        ):
            self.assertIn("invalid quiz", validate_card(self.card(quiz=quiz)), quiz)

    def test_length_limits(self):
        self.assertIn("headline too long", validate_card(self.card(headline=" ".join(["w"] * 20))))
        self.assertTrue(validate_card(self.card(body="too short")))

    def test_unknown_category_rejected(self):
        card = clean_card(GOOD, id="x", type="gk", category="gossip")
        self.assertTrue(any("category" in p for p in validate_card(card)))


class NewsTests(unittest.TestCase):
    def test_dedupe_near_duplicate_titles(self):
        s = lambda t: Story("src", "polity", t, "https://x", "", None)
        kept = dedupe([
            s("RBI keeps repo rate unchanged at 5.5%"),
            s("RBI keeps repo rate unchanged at 5.5 %"),
            s("ISRO launches new navigation satellite"),
        ])
        self.assertEqual(len(kept), 2)

    def test_extract_text_skips_boilerplate_and_scripts(self):
        page = """<html><script>var x = 'lots of words here to be ignored by the parser okay';</script>
        <p>Subscribe now to unlock premium stories and editorials and much more content today</p>
        <p>The Reserve Bank of India kept the policy repo rate unchanged on Friday, citing easing inflation.</p>
        <p>Short.</p></html>"""
        text = extract_text(page)
        self.assertTrue(text.startswith("The Reserve Bank"))
        self.assertNotIn("Subscribe", text)
        self.assertNotIn("Short", text)


class ManifestTests(unittest.TestCase):
    def test_keeps_last_30_days_and_pack_versions(self):
        with tempfile.TemporaryDirectory() as tmp:
            content = Path(tmp)
            with mock.patch.object(common, "CONTENT", content), \
                 mock.patch.object(common, "MANIFEST", content / "manifest.json"):
                for d in range(1, 36):
                    common.update_manifest(day=f"2026-10-{d:02d}" if d <= 31 else f"2026-11-{d - 31:02d}")
                pack = content / "packs" / "polity.json"
                common.write_json(pack, {"cards": [{"id": "a"}]})
                m = common.update_manifest(pack=pack)
                self.assertEqual(len(m["days"]), 30)
                self.assertEqual(m["days"][-1], "2026-11-04")
                self.assertEqual(m["packs"][0]["file"], "packs/polity.json")
                self.assertEqual(m["packs"][0]["count"], 1)
                self.assertEqual(json.loads((content / "manifest.json").read_text()), m)


if __name__ == "__main__":
    unittest.main()
