"""RSS → recent, de-duplicated stories, plus article text extraction."""

from __future__ import annotations

import calendar
import difflib
import html
import re
import time
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from html.parser import HTMLParser

import feedparser

from sources import FEEDS, USER_AGENT


@dataclass
class Story:
    source: str
    hint: str
    title: str
    link: str
    summary: str
    published: float | None  # unix time; PIB has no dates
    text: str = ""


def _strip_html(s: str) -> str:
    return " ".join(re.sub(r"<[^>]+>", " ", html.unescape(s or "")).split())


def _norm_title(t: str) -> str:
    return re.sub(r"[^a-z0-9ऀ-ॿ ]", "", t.lower())


def dedupe(stories: list[Story], threshold: float = 0.8) -> list[Story]:
    """Drops stories whose titles are near-duplicates of an earlier one."""
    kept: list[Story] = []
    seen: list[str] = []
    for s in stories:
        n = _norm_title(s.title)
        if any(difflib.SequenceMatcher(None, n, o).ratio() >= threshold for o in seen):
            continue
        kept.append(s)
        seen.append(n)
    return kept


def collect(hours: float = 30, now: float | None = None) -> list[Story]:
    now = now or time.time()
    cutoff = now - hours * 3600

    def read(feed: dict) -> list[Story]:
        parsed = feedparser.parse(feed["url"], agent=USER_AGENT)
        out = []
        for e in parsed.entries:
            ts = e.get("published_parsed")
            published = calendar.timegm(ts) if ts else None
            if published is not None and published < cutoff:
                continue
            title = _strip_html(e.get("title", ""))
            if title and e.get("link"):
                out.append(Story(feed["name"], feed["hint"], title, e.link,
                                 _strip_html(e.get("summary", "")), published))
        print(f"  {feed['name']:<15} {len(out):>3} recent  ({feed['url']})")
        return out

    with ThreadPoolExecutor(max_workers=6) as pool:
        stories = [s for batch in pool.map(read, FEEDS) for s in batch]
    return dedupe(stories)


# ---------------------------------------------------------------- articles

_BOILERPLATE = re.compile(
    r"subscri|log ?in|logout|unlock|e-?paper|copyright|all rights reserved|"
    r"download the app|follow us|newsletter|premium stor|sign up|advertisement",
    re.I,
)


class _Paragraphs(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.paragraphs: list[str] = []
        self._current: list[str] | None = None
        self._skip = 0

    def handle_starttag(self, tag, attrs):
        if tag in ("script", "style", "noscript", "footer", "nav"):
            self._skip += 1
        elif tag == "p":
            self._current = []

    def handle_endtag(self, tag):
        if tag in ("script", "style", "noscript", "footer", "nav"):
            self._skip = max(0, self._skip - 1)
        elif tag == "p" and self._current is not None:
            text = " ".join("".join(self._current).split())
            if len(text.split()) >= 12 and not _BOILERPLATE.search(text):
                self.paragraphs.append(text)
            self._current = None

    def handle_data(self, data):
        if self._current is not None and not self._skip:
            self._current.append(data)


def extract_text(page_html: str, max_words: int = 450) -> str:
    parser = _Paragraphs()
    parser.feed(page_html)
    words = " ".join(parser.paragraphs).split()
    return " ".join(words[:max_words])


def fetch_article(story: Story) -> Story:
    try:
        req = urllib.request.Request(story.link, headers={"User-Agent": USER_AGENT})
        with urllib.request.urlopen(req, timeout=20) as resp:
            page = resp.read().decode("utf-8", "ignore")
        story.text = extract_text(page)
    except Exception as e:  # network errors, bad encodings: fall back to summary
        print(f"  could not fetch {story.link}: {e}")
    if len(story.text.split()) < 60 and len(story.summary.split()) >= 30:
        story.text = story.summary
    return story


def fetch_articles(stories: list[Story]) -> list[Story]:
    with ThreadPoolExecutor(max_workers=6) as pool:
        return list(pool.map(fetch_article, stories))


if __name__ == "__main__":
    found = collect()
    print(f"{len(found)} unique recent stories")
    for s in found[:15]:
        print(f"- [{s.source}] {s.title}")
