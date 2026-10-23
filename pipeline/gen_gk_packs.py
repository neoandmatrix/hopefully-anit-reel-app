"""Generates evergreen India GK packs: content/packs/<topic>.json.

Each subtopic gets a batch of cards, then a second fact-checking pass drops
anything the model isn't confident about. Re-running appends to existing packs
and skips subtopics that are already done, so it's safe to resume.

Usage:
    python pipeline/gen_gk_packs.py --topic polity            # one topic
    python pipeline/gen_gk_packs.py --all                     # everything (~1,500 cards)
    python pipeline/gen_gk_packs.py --topic history --per-subtopic 5   # quick test
"""

from __future__ import annotations

import argparse
import json
from concurrent.futures import ThreadPoolExecutor

from common import CONTENT, clean_card, update_manifest, validate_card, write_json

TOPICS: dict[str, list[str]] = {
    "polity": [
        "Preamble and making of the Constitution", "Fundamental Rights", "Directive Principles and Fundamental Duties",
        "President and Vice-President", "Prime Minister and Council of Ministers", "Parliament: Lok Sabha and Rajya Sabha",
        "How a bill becomes law", "Supreme Court and High Courts", "Governor, Chief Minister and state legislatures",
        "Panchayati Raj and municipalities", "Election Commission and elections", "Constitutional bodies (CAG, UPSC, Finance Commission)",
        "Important constitutional amendments", "Emergency provisions", "Centre-state relations and federalism",
    ],
    "history": [
        "Indus Valley Civilisation", "Vedic period", "Mauryan Empire and Ashoka", "Gupta Empire",
        "South Indian dynasties (Cholas, Pallavas, Chalukyas)", "Delhi Sultanate", "Mughal Empire",
        "Vijayanagara and Maratha empires", "Arrival of Europeans and the East India Company", "Revolt of 1857",
        "Social reform movements of the 19th century", "Indian National Congress and early nationalism",
        "Gandhian movements", "Revolutionaries and the INA", "Partition and Independence", "Integration of princely states",
    ],
    "geography": [
        "Himalayas and mountain ranges", "Major rivers and river systems", "Plateaus, plains and deserts",
        "Coastline, islands and ports", "Monsoon and climate", "Soils and agriculture regions",
        "Minerals and energy resources", "Lakes, waterfalls and dams", "Passes and borders", "Extreme points and records of India",
    ],
    "economy": [
        "RBI and monetary policy", "Banking terms explained", "Budget and fiscal terms", "Taxes: GST and income tax",
        "GDP, inflation and key indicators", "Stock markets and SEBI", "Five-Year Plans and NITI Aayog",
        "1991 reforms and liberalisation", "Digital payments and UPI", "Agriculture economy and MSP",
        "Major government schemes", "Trade, exports and foreign exchange",
    ],
    "science": [
        "ISRO missions and milestones", "Indian scientists and their discoveries", "Nuclear programme and energy",
        "Defence technology and missiles", "Indian contributions to mathematics", "Health, vaccines and medicine in India",
        "Everyday science explained", "Digital India and technology",
    ],
    "culture": [
        "Classical dance forms", "Classical music traditions", "Festivals across India", "Architecture and monuments",
        "UNESCO World Heritage Sites in India", "Languages and scripts", "Literature and Jnanpith awardees",
        "Painting and folk art traditions", "National symbols", "Religions and philosophies of India",
    ],
    "sports": [
        "India at the Olympics", "Cricket milestones", "Hockey history", "Chess in India",
        "Badminton, tennis and other sports", "Sports awards and trophies", "Major tournaments hosted by India",
    ],
    "environment": [
        "National parks and tiger reserves", "Biosphere reserves and Ramsar sites", "Endangered species of India",
        "Environmental laws and movements", "Climate change and India's commitments", "Forests and mangroves",
    ],
    "states": [
        "States of North India", "States of South India", "States of East India", "States of West India",
        "Northeast India", "Union Territories", "State capitals and formation days", "Famous foods and crafts by state",
    ],
    "international": [
        "India and its neighbours", "United Nations and India", "BRICS, G20, SCO and Quad",
        "International organisations headquarters and heads", "India's foreign policy doctrines",
        "Indian diaspora", "Important treaties and agreements",
    ],
}

GEN_SYSTEM = """You write evergreen general-knowledge cards about India for a swipe-style learning app. Output JSON.

Accuracy is the top priority. Only include facts that are well established and verifiable in standard
references (NCERT textbooks, official government sources). If you are not sure of a number or date,
pick a different fact. Avoid facts that change often (current office-holders, latest rankings).

Each card:
- headline: at most 12 words, curiosity-sparking but true.
- body: 50-70 words of plain English explaining the fact with context.
- why_it_matters: one sentence connecting it to today or to everyday life.
- key_fact: the one thing to remember (max 12 words).
- quiz: one MCQ on the key fact; 4 distinct plausible options; "answer" is the 0-based index; "explain" one sentence.
- tags: 1-4 keywords.

Respond as {"cards": [{"headline": "...", "body": "...", "why_it_matters": "...", "key_fact": "...",
"quiz": {"q": "...", "options": ["...","...","...","..."], "answer": 0, "explain": "..."}, "tags": ["..."]}]}"""

CHECK_SYSTEM = """You are a strict fact-checker for an Indian general-knowledge app. For each card, check every
claim (dates, numbers, names, places, the quiz answer). Mark ok=false if anything is wrong, outdated,
disputed or you are not confident. Output JSON: {"verdicts": [{"n": <card number>, "ok": true|false, "issue": "..."}]}"""


def generate(topic: str, subtopic: str, count: int, avoid: list[str]) -> list[dict]:
    from llm import chat_json

    prompt = f"Topic: {topic}\nSubtopic: {subtopic}\nWrite {count} cards, each about a different fact."
    if avoid:
        prompt += "\nDo not repeat these existing headlines:\n" + "\n".join(f"- {h}" for h in avoid[-60:])
    return chat_json(GEN_SYSTEM, prompt, thinking=True, max_tokens=16000).get("cards", [])


def fact_check(cards: list[dict]) -> list[dict]:
    from llm import chat_json

    numbered = "\n\n".join(
        f"Card {n}: {json.dumps({k: c.get(k) for k in ('headline', 'body', 'key_fact', 'quiz')}, ensure_ascii=False)}"
        for n, c in enumerate(cards)
    )
    verdicts = chat_json(CHECK_SYSTEM, numbered, thinking=True, max_tokens=8000).get("verdicts", [])
    bad = {v.get("n"): v.get("issue", "") for v in verdicts if v.get("ok") is False}
    for n, issue in bad.items():
        if isinstance(n, int) and 0 <= n < len(cards):
            print(f"    dropped '{cards[n].get('headline', '')[:50]}': {issue}")
    # A card the checker didn't return a verdict for is dropped too.
    checked = {v.get("n") for v in verdicts}
    return [c for n, c in enumerate(cards) if n in checked and n not in bad]


def build_topic(topic: str, per_subtopic: int) -> None:
    path = CONTENT / "packs" / f"{topic}.json"
    pack = json.loads(path.read_text()) if path.exists() else {"pack": topic, "done": [], "cards": []}
    todo = [s for s in TOPICS[topic] if s not in pack["done"]]
    print(f"{topic}: {len(pack['cards'])} cards so far, {len(todo)} subtopics to go")

    def run(subtopic: str) -> tuple[str, list[dict]]:
        avoid = [c["headline"] for c in pack["cards"]]
        raw = generate(topic, subtopic, per_subtopic, avoid)
        return subtopic, fact_check(raw) if raw else []

    with ThreadPoolExecutor(max_workers=4) as pool:
        for subtopic, raw_cards in pool.map(run, todo):
            added = 0
            for raw in raw_cards:
                card = clean_card(raw, id=f"gk-{topic}-{len(pack['cards']) + 1:04d}", type="gk", category=topic)
                problems = validate_card(card)
                if problems:
                    print(f"    rejected '{card['headline'][:50]}': {', '.join(problems)}")
                    continue
                pack["cards"].append(card)
                added += 1
            pack["done"].append(subtopic)
            print(f"  {subtopic}: +{added}")
            # Save after every subtopic so an interrupted run can resume.
            write_json(path, pack)
    update_manifest(pack=path)
    print(f"{topic}: {len(pack['cards'])} cards in {path.relative_to(CONTENT.parent)}")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--topic", choices=sorted(TOPICS))
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--per-subtopic", type=int, default=15)
    args = ap.parse_args()
    if not args.topic and not args.all:
        ap.error("pass --topic <name> or --all")
    for topic in (sorted(TOPICS) if args.all else [args.topic]):
        build_topic(topic, args.per_subtopic)


if __name__ == "__main__":
    main()
