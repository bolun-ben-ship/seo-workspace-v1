---
name: webflow-onpage-implement
description: >
  On-page SEO implementation for Webflow sites. Loads historical context, runs SEO audit,
  pulls GSC + GA4 performance data, fetches live Webflow site structure (page titles, meta,
  scripts, CMS state) via Webflow Data API, runs last30days market research, builds a
  prioritised implementation plan with before/after values for every change, presents an
  approval UI, then executes approved on-page changes (SEO titles, meta descriptions, noindex)
  directly via Webflow MCP and saves a post-implementation report. Always builds on prior
  months — never re-recommends resolved items. Requires Webflow MCP to be connected.
  Use when the user asks to: fix on-page SEO on Webflow, "run Webflow on-page SEO",
  "implement SEO changes on Webflow", "fix titles and meta on Webflow", or
  "webflow onpage implement".
user-invocable: true
argument-hint: "<domain> (e.g. aexphl.com)"
---

# Webflow SEO Orchestrator

A 8-phase pipeline that takes a Webflow site from historical context → audit → performance data →
approval → implementation → report, without the user needing to manually coordinate each step.

## Prerequisites

Before starting, confirm:
1. **Domain** — what site are we working on? (e.g., `aexphl.com`)
2. **Webflow MCP** — is a Webflow MCP connector available? Look for tools prefixed with
   the Webflow MCP namespace (e.g., `data_pages_tool`, `data_cms_tool`, `data_scripts_tool`).
   If not connected, tell the user and stop.
3. **seo-and-blog skill** — the SEO sub-skills live in the `seo-and-blog` skill bundle.
   Read `seo-and-blog/SKILL.md` to understand the routing table before starting.

## Output Folder

All outputs go to:
```
Content & SEO/outputs/<domain>/
├── audit/              ← Phase 1 audit report (AUDIT-YYYY-MM-DD.pdf)
│                          Phase 6 post-implementation report (POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.pdf)
├── research/           ← Phase 2a performance data (GSC-REPORT-YYYY-MM-DD.pdf, GA4-REPORT-YYYY-MM-DD.pdf)
└── implementation/     ← Phase 3 implementation plan (SEO-PLAN-YYYY-MM-DD.pdf)
```

## Subfolder Creation

All paths are **relative to the current working directory** — wherever Claude Code is open.
Before saving any file, create the target subfolder if it doesn't exist:
```bash
mkdir -p "Content & SEO/outputs/<domain>/audit"
mkdir -p "Content & SEO/outputs/<domain>/research"
mkdir -p "Content & SEO/outputs/<domain>/implementation"
```
Run the relevant `mkdir -p` immediately before each phase's save step.

All output filenames include date suffixes — never overwrite prior months' files.

---

## Phase Overview

| Phase | Name | Action |
|---|---|---|
| 0 | Load Historical Context | Check output folder for prior reports |
| 1 | SEO Audit | `phases/1-audit.md` |
| 2a | GSC + GA4 Performance Data | Pull live data via Python API |
| 2b | Webflow Data Fetch | `phases/2-webflow-fetch.md` |
| 2c | Market Research (last30days) | Social trends for the domain's niche |
| 3 | Implementation Plan | `phases/3-implementation-plan.md` |
| 4 | User Approval | `phases/4-approval.md` |
| 5 | Execute Changes | `phases/5-execute.md` |
| 6 | Post-Implementation Report | `phases/6-report.md` |

Read each phase file before executing that phase. Do not skip ahead.

---

## Execution Flow

Run phases sequentially. Each phase produces outputs that feed the next.

```
Phase 0 (History)   → historical context loaded
       ↓
Phase 1 (Audit)     → audit findings (scoped to what's new since last run)
       ↓
Phase 2a (GSC/GA4)  → CTR gaps, ranking data, traffic baseline
Phase 2b (Webflow)  → current page titles, meta, scripts, CMS state
Phase 2c (Trends)   → social/market signals for the niche (last30days)
       ↓
Phase 3 (Plan)      → proposed changes grounded in audit + real data + market signals
       ↓
Phase 4 (Approval)  → user confirms which changes to apply
       ↓
Phase 5 (Execute)   → approved changes applied in Webflow
       ↓
Phase 6 (Report)    → before/after change report saved
```

**Stop at Phase 4 and wait for user approval before proceeding to Phase 5.**
Never execute changes without explicit approval.

---

## Phase 0: Load Historical Context (ALWAYS run first)

## File Naming Convention (always use this — no exceptions)

All output files must follow this exact pattern so skills can reliably find them:

```
audit/AUDIT-YYYY-MM-DD.pdf                        ← base SEO audit
audit/POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.pdf    ← after Webflow changes (this skill's Phase 6 output)
implementation/SEO-PLAN-YYYY-MM-DD.pdf            ← action/implementation plan (this skill's Phase 3 output)
research/PERFORMANCE-REPORT-YYYY-MM-DD.pdf        ← GA4 + GSC combined
research/GSC-REPORT-YYYY-MM-DD.pdf                ← GSC standalone
research/GA4-REPORT-YYYY-MM-DD.pdf                ← GA4 standalone
research/SOCIAL-TRENDS-YYYY-MM-DD.pdf             ← last30days market research (Phase 2c)
```

## Loading Historical Context

Check the following folders and load the **most recent file in each** (sort by date in filename YYYY-MM-DD, descending):

**`audit/` — load both if they exist:**
1. `POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.pdf` — highest priority; this skill produces this file in Phase 6; it contains the current SEO score, all resolved items (✅), and what still needs doing
2. `AUDIT-YYYY-MM-DD.pdf` — base audit; use as supplement or fallback

**`implementation/` — load newest:**
3. `SEO-PLAN-YYYY-MM-DD.pdf` — the approved action plan from the last cycle

**`research/` — load newest if exists:**
4. `PERFORMANCE-REPORT-YYYY-MM-DD.pdf` or `GSC-REPORT-YYYY-MM-DD.pdf` — prior organic baseline for comparison

**If files exist:**
- Read all loaded files before doing anything else
- Extract: current SEO score, resolved items (✅), outstanding priorities, organic session count
- Store as `HISTORICAL_CONTEXT` and announce: "Found reports from [date]. Building on these — skipping already-resolved items."

**If no files exist:** note it's a first run and proceed.

**Rules:**
- Do NOT re-recommend anything already marked ✅
- DO flag regressions explicitly
- DO carry forward the outstanding priorities list as the Phase 3 starting point
- Never overwrite prior files — always use today's date in new output filenames

---

## Phase 2c: Market Research — Social Trends (last30days)

Run last30days research for the domain's primary niche topic before building the
implementation plan. This reveals what the target audience is actually talking about,
searching for, and sharing right now — grounding the plan in real demand signals.

**Read from the loaded CLAUDE.md:**
- `context/client-info.md` → extract the primary niche/topic for the last30days query

**Execute:**
- Run the last30days research skill for the primary niche topic
- Focus: top content themes, emerging questions, competitor mentions, trending angles
- Save to: `Content & SEO/outputs/<domain>/research/SOCIAL-TRENDS-YYYY-MM-DD.md` then convert to PDF (see PDF Conversion Pattern below)

**Feed into Phase 3:** Surface content angles and audience questions that aren't
yet covered on the site but are generating real engagement.

---

## Phase 2a: GSC + GA4 Performance Data

Pull live performance data before building the implementation plan. This grounds the plan
in actual ranking gaps and CTR opportunities rather than audit findings alone.

**Google credentials — read from the current client's CLAUDE.md:**
- `Credentials env var` → the env var holding the path to the JSON key file
- `GA4 property ID` → the numeric GA4 property ID
- `GSC site` → the site URL for GSC queries

If any of these are missing from CLAUDE.md, skip this step and note it in the report.

Python libraries required: `google-analytics-data`, `google-api-python-client`, `google-auth`

**Pull from GSC (last 30 days):**
- Top queries by impressions — identify ranking but low-CTR keywords (position ≤10, CTR <3%)
- Top pages by clicks — identify best-performing organic pages
- Pages with high impressions but low clicks — title/meta fix opportunities

**Pull from GA4 (last 30 days):**
- Sessions by channel — organic baseline for month-over-month tracking
- Top landing pages by sessions + bounce rate
- Compare organic session count vs HISTORICAL_CONTEXT if available

**Save to:** `Content & SEO/outputs/<domain>/research/PERFORMANCE-REPORT-YYYY-MM-DD.md` then convert to PDF (see PDF Conversion Pattern below)

**Feed into Phase 3:** CTR gaps become priority fixes in the implementation plan.
Pages ranking position 2–10 with CTR <3% are higher priority than new content.

---

## Important Constraints

These constraints come from real experience with the Webflow Data API:

**What CAN be changed via API:**
- Page SEO title (`seo.title`)
- Page meta description (`seo.description`)
- Page Open Graph data
- Custom code scripts (header/footer injection via `data_scripts_tool`)
- CMS collection items — all CMS fields including RichText content
- CMS collection field display names
- Publishing pages and CMS items

**What CANNOT be changed via API (flag in the plan):**
- H1/H2/H3 headings on static pages — these are in the Webflow Designer canvas
- Body copy on static pages — requires Designer or Design API (separate scope)
- Images and their alt text — requires the Assets API with Designer open
- robots.txt — requires Site Config API (separate permission scope)
- Sitemap configuration — requires Site Config API
- Page redirect rules — requires Site Config API
- URL slugs on live pages — technically possible but risks breaking live links

Always clearly note these limitations in the implementation plan so the user knows
what they still need to handle manually.

---

## Webflow Script Injection Pattern

Schema markup and noindex tags cannot be set as static HTML via the Data API.
The correct approach is the **registered script + page assignment** pattern:

1. Register the script site-wide using `add_inline_site_script` via `data_scripts_tool`
2. Apply the script to specific pages using `upsert_page_script`

Script constraints:
- Max 2000 characters per inline script
- `displayName` must be alphanumeric (no hyphens or underscores as first char)
- `location` should be `header` for meta tags and schema
- Each script needs a unique `id`

For noindex: inject `<meta name="robots" content="noindex,nofollow">` via JS:
```javascript
document.head.insertAdjacentHTML('beforeend','<meta name="robots" content="noindex,nofollow">');
```

For schema: inject via `document.createElement('script')` with `type="application/ld+json"`.

**Critical note:** JS-injected noindex overrides Webflow's native index toggle.
To re-index a page later, the script must be removed from that page via the API.

---

## Webflow Site ID

The site ID is required for most API calls. Fetch it using `data_sites_tool` if not known.
For aexphl.com the site ID is `5e1ef6e0ff2a7e7d638dd146`.

---

## PDF Conversion Pattern

After each phase that saves a report file, write the file as `.md` first then immediately run this Python script via Bash (set `md_path` to the actual path just written):

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
