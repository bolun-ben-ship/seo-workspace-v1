# last30days Scripts

The Python research engine for this skill must be downloaded from the source repository.

## Setup

```bash
# Clone the scripts from the mvanhorn/last30days-skill repo
git clone https://github.com/mvanhorn/last30days-skill /tmp/last30days-skill
cp -r /tmp/last30days-skill/scripts/* ~/.claude/skills/last30days/scripts/
```

Or manually download `scripts/last30days.py` and `scripts/lib/` from:
https://github.com/mvanhorn/last30days-skill

## Required env vars

- `OPENAI_API_KEY` — required for Reddit/X search
- `SCRAPECREATORS_API_KEY` — optional, for TikTok/Instagram (100 free credits, then PAYG)

## Install Python deps

```bash
pip install openai requests
```
