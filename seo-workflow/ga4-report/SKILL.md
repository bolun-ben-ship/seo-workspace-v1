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
- `GA4-REPORT-YYYY-MM-DD.md` (preferred)
- `PERFORMANCE-REPORT-YYYY-MM-DD.md` (fallback)

Load the most recent. If found, compare: total sessions, organic sessions, bounce rate, top landing page.

## Step 4 — Save Output

```bash
mkdir -p "<OUTPUTS_PATH>/research"
```

Save to: `<OUTPUTS_PATH>/research/GA4-REPORT-YYYY-MM-DD.md` (use today's date).
Never overwrite an existing file.

After saving, display key findings inline in chat.
