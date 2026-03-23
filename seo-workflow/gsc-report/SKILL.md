---
name: gsc-report
description: >
  Pull a Google Search Console 30-day summary report for the current client.
  Shows top queries, top pages, CTR gaps, ranking movements, and
  impression-to-click opportunities. Use when user says "GSC report",
  "search console", "what are my rankings", "how is organic performing",
  "keyword rankings", "gsc", "search performance".
user-invocable: true
argument-hint: "(no arguments needed)"
---

# GSC Report — Google Search Console 30-Day Summary

Pulls live data from Google Search Console for the **current client** and produces
a structured performance summary. All config is read from the client's `CLAUDE.md`
— no values are hardcoded.

## Step 1 — Read Config from CLAUDE.md

From the currently loaded `CLAUDE.md`, extract:
- `GSC site` → the site URL (e.g. `https://owllight-sleep.com`)
- `Credentials env var` → the env var name holding the path to the JSON key file (e.g. `OWLLIGHT_GOOGLE_KEY`)
- `Outputs` path → where to save the report (e.g. `Content & SEO/outputs/shopline-owllight-sleep/`)

If any of these are missing or say "not yet configured", stop and tell the user:
> "GSC is not configured for this client yet. Add `GSC site`, `Credentials env var`, and ensure the env var is set in ~/.zshrc."

## Step 2 — Run the Report

Run this Python script via Bash, substituting values from Step 1:

```python
import os
from google.oauth2 import service_account
from googleapiclient.discovery import build
from datetime import date, timedelta

KEY_FILE = os.environ["<CREDENTIALS_ENV_VAR>"]   # e.g. os.environ["OWLLIGHT_GOOGLE_KEY"]
SITE = "<GSC_SITE>"                               # e.g. "https://owllight-sleep.com"

end = date.today()
start = end - timedelta(days=30)

creds = service_account.Credentials.from_service_account_file(
    KEY_FILE, scopes=["https://www.googleapis.com/auth/webmasters.readonly"])
gsc = build("searchconsole", "v1", credentials=creds)

# Top queries by impressions
queries = gsc.searchanalytics().query(siteUrl=SITE, body={
    "startDate": str(start), "endDate": str(end),
    "dimensions": ["query"], "rowLimit": 50,
    "orderBy": [{"fieldName": "impressions", "sortOrder": "DESCENDING"}]
}).execute()

# Top pages by clicks
pages = gsc.searchanalytics().query(siteUrl=SITE, body={
    "startDate": str(start), "endDate": str(end),
    "dimensions": ["page"], "rowLimit": 20,
    "orderBy": [{"fieldName": "clicks", "sortOrder": "DESCENDING"}]
}).execute()

print("QUERIES:", queries)
print("PAGES:", pages)
```

> Note: GSC API does not support server-side position filtering.
> Filter CTR gaps client-side: `position <= 10 AND ctr < 0.03`

## Step 3 — Produce the Report

### 1. Overview
- Date range
- Total clicks, impressions, average CTR, average position (summed across all rows)

### 2. Top Queries (by impressions)
Table: Query | Position | Impressions | Clicks | CTR
Flag any query with position ≤10 and CTR <3% as a **CTR gap opportunity**

### 3. CTR Gap Analysis
Queries ranking position 1–10 with CTR below 3% — fastest wins.
For each: title tag is likely the issue. Note recommended fix.

### 4. Top Pages (by clicks)
Table: Page | Clicks | Impressions | Position | CTR

### 5. Pages with Impression-to-Click Gap
Pages with >200 impressions and <2% CTR — meta title/description fix opportunities.

### 6. Month-over-Month (if prior report exists)
Check `<OUTPUTS_PATH>/research/` for previous files:
- `GSC-REPORT-YYYY-MM-DD.md` (preferred)
- `PERFORMANCE-REPORT-YYYY-MM-DD.md` (fallback)

Load the most recent. If found, compare: clicks, impressions, avg position, top query movements.

## Step 4 — Save Output

```bash
mkdir -p "<OUTPUTS_PATH>/research"
```

Save to: `<OUTPUTS_PATH>/research/GSC-REPORT-YYYY-MM-DD.md` (use today's date).
Never overwrite an existing file.

After saving, display key findings inline in chat.
