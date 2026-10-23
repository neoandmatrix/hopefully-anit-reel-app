"""Daily job: today's Indian news → content/daily/<date>.json + manifest.

Usage:
    python pipeline/make_cards.py                  # today (IST)
    python pipeline/make_cards.py --count 15       # fewer cards
    python pipeline/make_cards.py --dry-run        # fetch + select only, no writing
"""

from __future__ import annotations

import argparse
import json
from concurrent.futures import ThreadPoolExecutor

from common import CATEGORIES, CONTENT, clean_card, ist_today, update_manifest, validate_card, write_json
from fetch_news import Story, collect, fetch_articles

SELECT_SYSTEM = f"""You are the editor of a daily current-affairs feed for an Indian reader who wants to build
general knowledge about India and the world (think UPSC-style current affairs, but readable).

From the numbered headlines, pick the most important stories. Prefer: government policy and schemes,
Parliament and courts (constitutional matters), the economy and RBI, science, space and technology,
environment, India's international relations, major sports results, and significant news from states.
Avoid: crime reports, celebrity gossip, political mudslinging and allegations, opinion pieces, stock tips,
and near-duplicate stories (keep the best one). Headlines may be in Hindi; judge them the same way.

Assign each pick exactly one category from: {", ".join(CATEGORIES)}.
Respond in JSON: {{"picks": [{{"i": <headline number>, "category": "<category>"}}]}}, most important first."""

WRITE_SYSTEM = """You write short learning cards about Indian news for a swipe-style app. Output JSON.

Rules:
- Use ONLY facts stated in the article text provided. Never invent numbers, names, dates or quotes.
- "why_it_matters" may add well-established general background (e.g. what the repo rate is, which
  ministry runs a scheme) but no speculation.
- Write in clear, neutral Indian English even if the article is in Hindi. No sensational tone.
- headline: at most 12 words, specific and informative (not clickbait).
- body: 50-70 words explaining what happened and the key context.
- why_it_matters: one sentence on why this matters to an ordinary Indian or for general knowledge.
- key_fact: the one number, date, name or term worth remembering (max 12 words), taken from the article.
- quiz: one multiple-choice question testing that key fact; 4 distinct plausible options; "answer" is
  the 0-based index of the correct option; "explain" is one sentence.
- tags: 1-4 short keywords.
- If an article's text is too thin or unclear to write an accurate card, set "skip": true for it.

Respond as {"cards": [{"i": <story number>, "skip": false, "headline": "...", "body": "...",
"why_it_matters": "...", "key_fact": "...", "quiz": {"q": "...", "options": ["...","...","...","..."],
"answer": 0, "explain": "..."}, "tags": ["..."]}]}"""


def select(stories: list[Story], count: int) -> list[tuple[Story, str]]:
    from llm import chat_json

    listing = "\n".join(f"{i}. [{s.source}] {s.title}" for i, s in enumerate(stories))
    result = chat_json(SELECT_SYSTEM, f"Pick up to {count} stories.\n\n{listing}", max_tokens=3000)
    picks, used = [], set()
    for p in result.get("picks", []):
        i = p.get("i")
        if isinstance(i, int) and 0 <= i < len(stories) and i not in used:
            used.add(i)
            category = p.get("category") if p.get("category") in CATEGORIES else stories[i].hint
            picks.append((stories[i], category))
    return picks


def write_cards(batch: list[tuple[int, Story]]) -> list[dict]:
    from llm import chat_json

    body = "\n\n".join(
        f"### Story {i}\nSource: {s.source}\nHeadline: {s.title}\nArticle text:\n{s.text}"
        for i, s in batch
    )
    return chat_json(WRITE_SYSTEM, body, max_tokens=6000).get("cards", [])


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--date", default=ist_today())
    ap.add_argument("--count", type=int, default=20, help="target number of cards")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    print("Fetching feeds…")
    stories = collect()
    print(f"{len(stories)} unique recent stories")
    if not stories:
        raise SystemExit("no stories found; feeds may be down")

    print("Selecting…")
    # Ask for extra picks: some articles can't be fetched or are too thin.
    picks = select(stories, args.count + 8)
    print(f"{len(picks)} picked; fetching article text…")
    fetched = fetch_articles([s for s, _ in picks])
    category_of = {id(s): c for s, c in picks}
    usable = [s for s in fetched if len(s.text.split()) >= 60][: args.count]
    print(f"{len(usable)} stories have enough text")

    if args.dry_run:
        for s in usable:
            print(f"- [{category_of[id(s)]}] {s.title} ({len(s.text.split())} words)")
        return

    numbered = list(enumerate(usable))
    batches = [numbered[i:i + 5] for i in range(0, len(numbered), 5)]
    print(f"Writing cards in {len(batches)} batches…")
    with ThreadPoolExecutor(max_workers=4) as pool:
        raw_cards = [c for result in pool.map(write_cards, batches) for c in result]

    cards, rejected = [], 0
    for raw in raw_cards:
        i = raw.get("i")
        if raw.get("skip") or not isinstance(i, int) or not 0 <= i < len(usable):
            rejected += 1
            continue
        story = usable[i]
        card = clean_card(
            raw,
            id=f"news-{args.date}-{len(cards) + 1:02d}",
            type="news",
            category=category_of[id(story)],
            date=args.date,
            source_url=story.link,
        )
        problems = validate_card(card)
        if problems:
            print(f"  rejected '{card['headline'][:50]}': {', '.join(problems)}")
            rejected += 1
            continue
        cards.append(card)

    if not cards:
        raise SystemExit("no valid cards produced")
    out = CONTENT / "daily" / f"{args.date}.json"
    write_json(out, {"date": args.date, "cards": cards})
    update_manifest(day=args.date)
    print(f"Wrote {len(cards)} cards to {out.relative_to(CONTENT.parent)} ({rejected} rejected)")
    print(json.dumps(cards[0], ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
