"""News feeds. `hint` is a category suggestion; the model makes the final call.

Checked Oct 2026: Times of India article pages are JS-rendered (no text) and
DD News timed out, so they are left out.
"""

FEEDS = [
    {"name": "PIB", "url": "https://www.pib.gov.in/RssMain.aspx?ModId=6&Lang=1&Regid=3", "hint": "polity"},
    {"name": "The Hindu", "url": "https://www.thehindu.com/news/national/feeder/default.rss", "hint": "polity"},
    {"name": "The Hindu", "url": "https://www.thehindu.com/business/Economy/feeder/default.rss", "hint": "economy"},
    {"name": "The Hindu", "url": "https://www.thehindu.com/sci-tech/feeder/default.rss", "hint": "science"},
    {"name": "The Hindu", "url": "https://www.thehindu.com/sport/feeder/default.rss", "hint": "sports"},
    {"name": "The Hindu", "url": "https://www.thehindu.com/news/international/feeder/default.rss", "hint": "international"},
    {"name": "Indian Express", "url": "https://indianexpress.com/section/india/feed/", "hint": "polity"},
    {"name": "Indian Express", "url": "https://indianexpress.com/section/explained/feed/", "hint": "economy"},
    {"name": "LiveMint", "url": "https://www.livemint.com/rss/news", "hint": "economy"},
    {"name": "LiveMint", "url": "https://www.livemint.com/rss/economy", "hint": "economy"},
]

USER_AGENT = (
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/140.0 Safari/537.36"
)
