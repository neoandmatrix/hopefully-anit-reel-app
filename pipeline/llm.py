"""DeepSeek client (OpenAI-compatible API) that returns parsed JSON."""

from __future__ import annotations

import json
import os
import time

from openai import OpenAI

from common import load_dotenv

load_dotenv()

MODEL = os.environ.get("DEEPSEEK_MODEL", "deepseek-flash")
_client: OpenAI | None = None


def client() -> OpenAI:
    global _client
    if _client is None:
        key = os.environ.get("DEEPSEEK_API_KEY")
        if not key:
            raise SystemExit("DEEPSEEK_API_KEY is not set (put it in pipeline/.env or the environment)")
        _client = OpenAI(api_key=key, base_url="https://api.deepseek.com", timeout=300)
    return _client


def chat_json(system: str, user: str, *, thinking: bool = False, max_tokens: int = 8000,
              attempts: int = 3) -> dict:
    """Calls the model in JSON mode. Retries on empty or unparseable output,
    which DeepSeek's docs say can happen occasionally."""
    last_error: Exception | None = None
    for attempt in range(1, attempts + 1):
        try:
            resp = client().chat.completions.create(
                model=MODEL,
                messages=[{"role": "system", "content": system},
                          {"role": "user", "content": user}],
                response_format={"type": "json_object"},
                max_tokens=max_tokens,
                extra_body={"thinking": {"type": "enabled" if thinking else "disabled"}},
            )
            content = resp.choices[0].message.content or ""
            if not content.strip():
                raise ValueError("empty response")
            return json.loads(content)
        except (ValueError, json.JSONDecodeError) as e:
            last_error = e
            print(f"  model output unusable (attempt {attempt}/{attempts}): {e}")
            time.sleep(2 * attempt)
    raise RuntimeError(f"model failed after {attempts} attempts: {last_error}")
