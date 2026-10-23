# Scroll Smart

A Reels-style app for learning about India: swipe through daily news and India GK cards instead of doomscrolling.

- `app/`: Flutter app (web + Android). Run it with `cd app && flutter run -d chrome`.
- `pipeline/`: Python scripts that turn Indian news feeds into cards using DeepSeek.
- `content/`: generated JSON, published to GitHub Pages and downloaded by the app.
- `.github/workflows/daily.yml`: runs every day at 06:00 IST to generate news and publish `content/`.
- `.github/workflows/gk-packs.yml`: manual workflow that generates evergreen GK packs.
- `.github/workflows/build-apk.yml`: builds a signed Android APK on every push that changes `app/`.

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

## Android app

Each build is published to the rolling **latest** release, so the download link never changes:

https://github.com/neoandmatrix/hopefully-anit-reel-app/releases/latest/download/scroll-smart.apk

Open the link on your phone and install the file. The first time, Android asks you to allow installs from your browser. Later builds install over the existing app and keep your progress.

### Signing key (one-time)

Android only accepts an update if it's signed with the same key as the installed app. The key was generated locally:

- `~/.android-keys/scroll_smart.jks`: the keystore. **Back this up.**
- `~/.android-keys/scroll_smart-secrets.txt`: the four values to add under **Settings → Secrets and variables → Actions**: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` and `ANDROID_KEY_PASSWORD`.

If the key is lost, uninstall the app and install a build signed with a new key. That also wipes the app's local progress.
