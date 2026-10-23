"""Shared helpers: paths, card validation, manifest handling."""

from __future__ import annotations

import datetime as dt
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONTENT = ROOT / "content"
MANIFEST = CONTENT / "manifest.json"

# Must match the categories styled in app/lib/core/theme.dart.
CATEGORIES = [
    "polity", "economy", "geography", "history", "science", "sports",
    "international", "states", "culture", "environment",
]

IST = dt.timezone(dt.timedelta(hours=5, minutes=30))
MANIFEST_DAYS = 30


def ist_today() -> str:
    return dt.datetime.now(IST).date().isoformat()


def load_dotenv(path: Path = Path(__file__).with_name(".env")) -> None:
    """Minimal .env loader so the API key never has to live in the repo."""
    if not path.exists():
        return
    for line in path.read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            key, value = line.split("=", 1)
            os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


def _words(s: str) -> int:
    return len(s.split())


def validate_card(card: dict) -> list[str]:
    """Returns a list of problems; empty means the card is usable."""
    problems = []
    for field in ("id", "type", "category", "headline", "body"):
        if not isinstance(card.get(field), str) or not card[field].strip():
            problems.append(f"missing {field}")
    if problems:
        return problems
    if card["category"] not in CATEGORIES:
        problems.append(f"unknown category {card['category']!r}")
    if _words(card["headline"]) > 16:
        problems.append("headline too long")
    if not 25 <= _words(card["body"]) <= 110:
        problems.append(f"body has {_words(card['body'])} words")
    quiz = card.get("quiz")
    if quiz is not None:
        options = quiz.get("options")
        if (
            not isinstance(quiz.get("q"), str)
            or not isinstance(options, list)
            or len(options) != 4
            or not all(isinstance(o, str) and o.strip() for o in options)
            or len({o.strip().lower() for o in options}) != 4
            or not isinstance(quiz.get("answer"), int)
            or not 0 <= quiz["answer"] < 4
        ):
            problems.append("invalid quiz")
    return problems


def clean_card(raw: dict, *, id: str, type: str, category: str, date: str | None = None,
               source_url: str | None = None) -> dict:
    """Builds a card in the app's schema from model output, dropping unknown keys."""
    card = {
        "id": id,
        "type": type,
        "category": category if category in CATEGORIES else "",
        "headline": str(raw.get("headline", "")).strip(),
        "body": str(raw.get("body", "")).strip(),
    }
    for key in ("why_it_matters", "key_fact"):
        if str(raw.get(key) or "").strip():
            card[key] = str(raw[key]).strip()
    if source_url:
        card["source_url"] = source_url
    if date:
        card["date"] = date
    quiz = raw.get("quiz")
    if isinstance(quiz, dict):
        card["quiz"] = {
            "q": str(quiz.get("q", "")).strip(),
            "options": [str(o).strip() for o in quiz.get("options", [])],
            "answer": quiz.get("answer"),
        }
        if str(quiz.get("explain") or "").strip():
            card["quiz"]["explain"] = str(quiz["explain"]).strip()
    tags = raw.get("tags")
    if isinstance(tags, list):
        card["tags"] = [str(t).strip() for t in tags if str(t).strip()][:5]
    return card


def write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")


def file_version(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()[:12]


def update_manifest(*, day: str | None = None, pack: Path | None = None) -> dict:
    """Adds a day and/or pack to manifest.json, keeping the newest 30 days."""
    manifest = json.loads(MANIFEST.read_text()) if MANIFEST.exists() else {}
    days = set(manifest.get("days", []))
    if day:
        days.add(day)
    manifest["days"] = sorted(days)[-MANIFEST_DAYS:]

    packs = {p["file"]: p for p in manifest.get("packs", [])}
    if pack:
        rel = pack.relative_to(CONTENT).as_posix()
        count = len(json.loads(pack.read_text())["cards"])
        packs[rel] = {"file": rel, "version": file_version(pack), "count": count}
    manifest["packs"] = sorted(packs.values(), key=lambda p: p["file"])
    manifest["updated"] = dt.datetime.now(IST).isoformat(timespec="seconds")
    write_json(MANIFEST, manifest)
    return manifest
