---
name: seo-implementation-plan
description: >
  Global command — builds a complete SEO implementation plan from scratch for any client
  workspace. Runs: historical context check → SEO audit → GSC + GA4 + last30days research
  (parallel) → produces a fully structured before/after implementation plan for every
  proposed change. Stops at the plan — does NOT execute any changes (use the platform's
  onpage-implement skill for execution). Platform-aware: reads config from CLAUDE.md.
  Always builds on prior work — never re-recommends resolved items.
  Use when user says "create implementation plan", "build SEO plan", "what should we fix",
  "seo-implementation-plan", "make a plan", or "plan before we implement".
user-invocable: true
argument-hint: "(no arguments — reads config from CLAUDE.md)"
---

# SEO Implementation Plan

Global planning command. Runs entirely from the client workspace. Reads all config from `CLAUDE.md`.

Produces a complete, before/after implementation plan for every proposed SEO change.
Stops at the plan — does NOT touch the CMS or any live content.

## Platform Detection

Read `## Platform` → `CMS:` from `CLAUDE.md` before starting. Announce detected platform.

```
"Shopline"   → PLATFORM = shopline  → execute with /shopline-onpage-implement
"Webflow"    → PLATFORM = webflow   → execute with /webflow-onpage-implement
"WordPress"  → PLATFORM = wordpress → execute with /wordpress-onpage-implement (preview)
other/missing → PLATFORM = unknown  → plan only, manual execution required
```

This skill does NOT execute regardless of platform. Platform is detected solely to:
- Label the plan correctly ("Changes to execute via Shopline API" vs "via Webflow API")
- Identify which Category G items are manual for this specific platform
- Direct the user to the correct execution skill in the closing message

---

## Output

```
Content & SEO/outputs/{platform}-{handle}/
└── implementation/
    └── IMPLEMENTATION-PLAN-YYYY-MM-DD.pdf   ← the complete before/after plan
```

Also refreshes:
```
research/GSC-REPORT-YYYY-MM-DD.pdf
research/GA4-REPORT-YYYY-MM-DD.pdf
research/SOCIAL-TRENDS-YYYY-MM-DD.pdf
```

---

## Phase 0: Read Client Config

Read `CLAUDE.md` from current workspace. Extract:
- `Platform` (Shopline / Webflow / other)
- `Store / Site handle`
- `Access token` env var
- `GSC site`, `GA4 property ID`, `Credentials env var`

Also read `context/client-info.md` for the primary niche/topic (used for last30days query).

---

## Phase 1: Load Historical Context

Check `Content & SEO/outputs/{platform}-{handle}/` for prior reports.
Sort by YYYY-MM-DD descending, load newest per category:

1. `audit/POST-IMPLEMENTATION-AUDIT-*.pdf` — current SEO score, all ✅ resolved items
2. `audit/AUDIT-*.pdf` — baseline audit (fallback)
3. `implementation/IMPLEMENTATION-PLAN-*.pdf` or `SEO-PLAN-*.pdf` — prior plan
4. `implementation/SHOPLINE-SNAPSHOT-*.pdf` or `WEBFLOW-SNAPSHOT-*.pdf` — prior CMS state
5. `research/GSC-REPORT-*.pdf` + `GA4-REPORT-*.pdf` — prior performance baseline

**Build HISTORICAL_CONTEXT:**
```
last_run_date:          <date from most recent file>
current_score:          <score>/100 or "unknown"
resolved_items:         [all ✅ items — NEVER re-recommend these]
outstanding_priorities: [table from last report]
prior_implementation:   <summary of last executed plan>
organic_baseline:       <session count or "not available">
```

Announce what was found:
- If prior reports exist: "Building on [date] work. Resolved items will not be re-recommended."
- If first run: "No prior outputs found. This is a first run."

**Audit freshness check:**
- POST-IMPLEMENTATION-AUDIT < 30 days → skip fresh audit, use as baseline
- Any audit < 30 days → skip fresh audit
- Audit > 30 days or no audit → run fresh audit

---

## Phase 2: SEO Audit (if needed — see freshness check above)

- Crawl site, detect business type, check up to 500 pages
- Technical: robots.txt, sitemaps, canonicals, Core Web Vitals
- Content: E-E-A-T, thin content, AI citation readiness
- Schema: structured data detection and recommendations
- Produce health score (0–100) + prioritised action list
- `mkdir -p` audit/ before saving
- **Save to:** `audit/AUDIT-YYYY-MM-DD.md` then convert to PDF (see PDF conversion pattern below)

If skipping fresh audit: load existing audit into context as the baseline.

---

## Phase 3: Research (run all three in parallel)

**3a — GSC Data**
Pull 30-day data using credentials from CLAUDE.md:
- Top queries by impressions, CTR, position
- CTR gap opportunities: position ≤10, CTR <3%
- **Save to:** `research/GSC-REPORT-YYYY-MM-DD.md` then convert to PDF (see PDF conversion pattern below)

**3b — GA4 Data**
Pull 30-day data:
- Sessions by channel, top landing pages, bounce rates
- **Save to:** `research/GA4-REPORT-YYYY-MM-DD.md` then convert to PDF (see PDF conversion pattern below)

**3c — Market Research (last30days)**
Research the client's primary niche:
- Top content themes, trending questions, competitor angles
- **Save to:** `research/SOCIAL-TRENDS-YYYY-MM-DD.md` then convert to PDF (see PDF conversion pattern below)

If credentials not configured in CLAUDE.md: skip 3a/3b, note it in the plan.

---

## Phase 4: Build Implementation Plan

Cross-reference: audit findings + GSC/GA4 CTR gaps + last30days signals + HISTORICAL_CONTEXT.

**Prioritisation order:**
1. GSC CTR gaps (position ≤10, CTR <3%) — highest ROI
2. Missing/broken SEO titles and meta descriptions
3. New content opportunities from last30days research
4. Technical fixes from audit
5. Schema and structured data improvements

**For each proposed change, show BEFORE → AFTER:**

---

### Category A — Page SEO Titles

| Page | Slug | Current Title | Proposed Title | Reason |
|---|---|---|---|---|
| Home | / | (missing) | Keyword-Rich Title — Brand | Priority keyword, 55 chars |

Rules: lead with primary keyword, brand at end after em dash, 50–60 chars.

---

### Category B — Page Meta Descriptions

| Page | Slug | Current Meta | Proposed Meta |
|---|---|---|---|
| Home | / | (missing) | Action-oriented, 140–160 chars |

---

### Category C — Blog Post SEO Titles

Prioritise posts: no seoTitle > GSC ranking data showing CTR <3% at position ≤10.

| Post Title | Slug | Current seoTitle | Proposed seoTitle |
|---|---|---|---|
| Title | /slug | (missing) | Keyword-Rich Version — Brand |

---

### Category D — Blog Post Meta Descriptions

| Post Title | Proposed seoDescription |
|---|---|
| Title | Compelling 140–160 char summary |

---

### Category E — New Content to Create

| # | Proposed Title | Target Keyword | Content Type | Recommended CMS Collection |
|---|---|---|---|---|
| 1 | Full title | primary keyword | Blog post | [collection name] |

---

### Category F — Schema to Inject

| Resource | Schema Type | Why |
|---|---|---|
| Homepage | Organization + WebSite | E-E-A-T, AI citation readiness |

---

### Category G — Cannot Be Done Via API (Manual Work Required)

| Item | Why | Manual Action |
|---|---|---|
| Theme H1/H2 | Controlled by theme template | Theme Editor |
| robots.txt | Store-level setting | Admin > Settings > SEO |

Always include this section. Users need to know what requires manual work.

---

## Phase 5: Save and Present

`mkdir -p` implementation/ before saving.
**Save to:** `implementation/IMPLEMENTATION-PLAN-YYYY-MM-DD.md` then convert to PDF using the pattern below.

End the plan document with:
```
## Summary
- SEO titles to set/update:       X items
- Meta descriptions to set:       X items
- New content to create:          X items
- Schema to inject:               X items
- Manual actions required:        X items (Category G)
- Items carried from prior plan:  X (from [date])
- Resolved items NOT re-recommended: X
```

### PDF Conversion Pattern

After each "Save to:" step above, run this Python script via Bash (set `md_path` to the actual path just written):

```python
import subprocess, sys, os
subprocess.run([sys.executable, '-m', 'pip', 'install', 'markdown', '-q'], capture_output=True)
import markdown as md_lib

md_path = "<THE_EXACT_PATH_WRITTEN_ABOVE>"  # ← set to the actual path
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

**Present in chat:** a concise summary table (top 10 changes), then say:

> "Implementation plan saved. To execute these changes, run the correct skill for your platform:
> - `/shopline-onpage-implement` — Shopline
> - `/webflow-onpage-implement` — Webflow
> - `/wordpress-onpage-implement` — WordPress (preview)
> Or run `/ai-seo-pipeline` to set up automated execution on a schedule."

This skill STOPS HERE. It does not make any API calls to the CMS.

---

## Sub-skill Reference Paths

`.skills/skills/seo-and-blog/skills/<skill-name>.md` (try first)
`.skills/skills/<skill-name>/SKILL.md` (fallback)
