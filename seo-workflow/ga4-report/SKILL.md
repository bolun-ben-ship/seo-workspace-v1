---
name: ga4-report
description: >
  Pull a Google Analytics 4 30-day summary report for the current client.
  Shows sessions by channel, top landing pages, bounce rates, traffic trends,
  and organic vs paid split. Use when user says "GA4 report", "analytics report",
  "how is traffic", "traffic report", "ga4", "google analytics", "how many visitors",
  "session report", "traffic breakdown".
user-invocable: true
argument-hint: "(no arguments needed)"
---

# GA4 Report — Google Analytics 4 30-Day Summary

Pulls live data from Google Analytics 4 for the **current client** and produces
a structured traffic summary. All config is read from the client's `CLAUDE.md`
— no values are hardcoded.

## Step 1 — Read Config from CLAUDE.md

From the currently loaded `CLAUDE.md`, extract:
- `GA4 property ID` → the numeric property ID (e.g. `485483885`)
- `Credentials env var` → the env var name holding the path to the JSON key file (e.g. `OWLLIGHT_GOOGLE_KEY`)
- `Outputs` path → where to save the report (e.g. `Content & SEO/outputs/shopline-owllight-sleep/`)

If any of these are missing or say "not yet configured", stop and tell the user:
> "GA4 is not configured for this client yet. Add `GA4 property ID`, `Credentials env var`, and ensure the env var is set in ~/.zshrc."

## Step 2 — Run the Report

Run this Python script via Bash, substituting values from Step 1:

```python
import os
from google.oauth2 import service_account
from google.analytics.data_v1beta import BetaAnalyticsDataClient
from google.analytics.data_v1beta.types import (
    RunReportRequest, DateRange, Metric, Dimension, OrderBy
)

KEY_FILE = os.environ["<CREDENTIALS_ENV_VAR>"]   # e.g. os.environ["OWLLIGHT_GOOGLE_KEY"]
PROPERTY_ID = "<GA4_PROPERTY_ID>"                 # e.g. "485483885"

creds = service_account.Credentials.from_service_account_file(KEY_FILE)
client = BetaAnalyticsDataClient(credentials=creds)

# Overall totals
totals = client.run_report(RunReportRequest(
    property=f"properties/{PROPERTY_ID}",
    date_ranges=[DateRange(start_date="30daysAgo", end_date="today")],
    metrics=[
        Metric(name="sessions"), Metric(name="activeUsers"),
        Metric(name="screenPageViews"), Metric(name="bounceRate"),
        Metric(name="averageSessionDuration")
    ],
))

# By channel
channels = client.run_report(RunReportRequest(
    property=f"properties/{PROPERTY_ID}",
    date_ranges=[DateRange(start_date="30daysAgo", end_date="today")],
    dimensions=[Dimension(name="sessionDefaultChannelGroup")],
    metrics=[Metric(name="sessions"), Metric(name="activeUsers"), Metric(name="bounceRate")],
    order_bys=[OrderBy(metric=OrderBy.MetricOrderBy(metric_name="sessions"), desc=True)],
))

# Top landing pages
landing = client.run_report(RunReportRequest(
    property=f"properties/{PROPERTY_ID}",
    date_ranges=[DateRange(start_date="30daysAgo", end_date="today")],
    dimensions=[Dimension(name="landingPage")],
    metrics=[
        Metric(name="sessions"), Metric(name="activeUsers"),
        Metric(name="bounceRate"), Metric(name="conversions")
    ],
    order_bys=[OrderBy(metric=OrderBy.MetricOrderBy(metric_name="sessions"), desc=True)],
    limit=15,
))

# Daily trend
daily = client.run_report(RunReportRequest(
    property=f"properties/{PROPERTY_ID}",
    date_ranges=[DateRange(start_date="30daysAgo", end_date="today")],
    dimensions=[Dimension(name="date")],
    metrics=[Metric(name="sessions"), Metric(name="activeUsers")],
    order_bys=[OrderBy(dimension=OrderBy.DimensionOrderBy(dimension_name="date"))],
))

print("TOTALS:", totals)
print("CHANNELS:", channels)
print("LANDING:", landing)
print("DAILY:", daily)
```

## Step 3 — Produce the Report

### 1. Overview
- Date range
- Total sessions, users, pageviews, avg bounce rate, avg session duration

### 2. Channel Breakdown
Table: Channel | Sessions | Users | Bounce Rate | Share %
Highlight the organic search row — this is the SEO baseline metric.

### 3. Organic vs Paid Split
Calculate: organic sessions / total sessions as a percentage.
Flag if organic is below 10% — indicates high ad dependency.

### 4. Top Landing Pages
Table: Page | Sessions | Users | Bounce Rate
Flag pages with bounce rate >60% — content/intent mismatch.
Flag pages with bounce rate <10% — high engagement, worth internal linking to.

### 5. Traffic Trend
Summarise the 30-day daily pattern in plain English:
- Was there a spike or drop? On what date?
- Is traffic trending up, down, or flat vs the first half of the period?
(Do not output the full 30-row daily table — just the narrative summary.)

### 6. Month-over-Month (if prior report exists)
Check `<OUTPUTS_PATH>/research/` for previous files:
- `GA4-REPORT-YYYY-MM-DD.pdf` (preferred)
- `PERFORMANCE-REPORT-YYYY-MM-DD.md` (fallback)

Load the most recent. If found, compare: total sessions, organic sessions, bounce rate, top landing page.

## Step 4 — Save Output

```bash
mkdir -p "<OUTPUTS_PATH>/research"
```

Save to: `<OUTPUTS_PATH>/research/GA4-REPORT-YYYY-MM-DD.md` (use today's date).
Never overwrite an existing file.

## Step 5 — Convert to PDF

Run this Python script via Bash to convert the saved markdown to PDF:

```python
import subprocess, sys, os
subprocess.run([sys.executable, '-m', 'pip', 'install', 'markdown', '-q'], capture_output=True)
import markdown as md_lib

md_path = "<OUTPUTS_PATH>/research/GA4-REPORT-YYYY-MM-DD.md"  # ← set to the actual path written above
html_path = md_path[:-3] + "_tmp.html"
pdf_path  = md_path[:-3] + ".pdf"

with open(md_path) as f:
    body = f.read()
html_body = md_lib.markdown(body, extensions=["tables", "fenced_code"])
html = f"""<!DOCTYPE html><html><head><meta charset="utf-8">
<style>body{{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;max-width:920px;margin:40px auto;padding:0 48px;color:#1a1a2e;line-height:1.65}}h1{{font-size:2em;border-bottom:3px solid #e0e0e8;padding-bottom:12px}}h2{{font-size:1.4em;color:#2d2d50;border-bottom:1px solid #eee;padding-bottom:6px;margin-top:36px}}h3{{color:#444;margin-top:24px}}table{{border-collapse:collapse;width:100%;margin:16px 0;font-size:.9em}}th{{background:#f0f0f8;font-weight:600;padding:10px 14px;border:1px solid #d0d0e0}}td{{padding:8px 14px;border:1px solid #d0d0e0}}tr:nth-child(even){{background:#f8f8fc}}code{{background:#f4f4f8;padding:2px 6px;border-radius:3px;font-family:monospace;font-size:.88em}}pre{{background:#f4f4f8;padding:16px;border-radius:6px}}pre code{{background:none;padding:0}}hr{{border:none;border-top:2px solid #eee;margin:28px 0}}</style>
</head><body>{html_body}</body></html>"""
with open(html_path, "w") as f:
    f.write(html)
chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
subprocess.run([chrome, "--headless", "--disable-gpu", "--no-sandbox",
                f"--print-to-pdf={pdf_path}", "--print-to-pdf-no-header",
                html_path], check=True, capture_output=True)
os.remove(html_path)
os.remove(md_path)
print(f"✅ PDF saved: {pdf_path}")
```

Save to: `<OUTPUTS_PATH>/research/GA4-REPORT-YYYY-MM-DD.pdf`

After saving, display key findings inline in chat.
