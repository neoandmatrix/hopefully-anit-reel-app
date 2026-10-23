# Scroll Smart

A Reels-style app for learning about India: swipe through daily news and India GK cards instead of doomscrolling.

- `app/`: Flutter app (web + Android). Run it with `cd app && flutter run -d chrome`.
- `pipeline/`: Python scripts that turn Indian news feeds into cards using DeepSeek.
- `content/`: generated JSON, published to GitHub Pages and downloaded by the app.
- `.github/workflows/daily.yml`: runs every day at 06:00 IST to generate news and publish `content/`.
- `.github/workflows/gk-packs.yml`: manual workflow that generates evergreen GK packs.

## One-time setup

1. **Settings → Secrets and variables → Actions**: add a `DEEPSEEK_API_KEY` secret.
2. **Settings → Pages → Build and deployment → Source**: select **GitHub Actions**.
3. **Actions → Daily content → Run workflow** generates today's cards and publishes them.
4. **Actions → Generate GK packs → Run workflow** with topic `all` builds about 1,500 GK cards.

## Run the pipeline locally

```bash
cd pipeline
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
echo 'DEEPSEEK_API_KEY=sk-...' > .env          # gitignored
.venv/bin/python make_cards.py --dry-run       # fetch + select only
.venv/bin/python make_cards.py                 # write content/daily/<today>.json
.venv/bin/python gen_gk_packs.py --topic polity --per-subtopic 3   # small test
.venv/bin/python -m unittest test_pipeline
```
