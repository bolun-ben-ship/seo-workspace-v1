---
name: seo-final-report
description: >
  Global command — produces a comprehensive final report for any client workspace,
  summarising everything accomplished across an entire engagement. Loads all prior
  output files (all months, all audits, all plans, all blogs), pulls fresh GSC + GA4
  data, compares starting baseline vs current state, and writes a full journey summary.
  Use at the end of a campaign, engagement period, or automation run.
  Use when user says "final report", "wrap-up report", "end of campaign report",
  "seo-final-report", "campaign summary", "what did we achieve", or "engagement summary".
user-invocable: true
argument-hint: "(no arguments — reads config from CLAUDE.md)"
---

# SEO Final Report

Global command. Runs from the client workspace. Reads all config from `CLAUDE.md`.

Produces a complete end-of-engagement report covering everything that was planned,
executed, and achieved — comparing the starting baseline against the current state.

---

## Output

```
Content & SEO/outputs/{platform}-{handle}/
└── audit/
    └── FINAL-REPORT-YYYY-MM-DD.pdf
```

---

## Phase 0: Read Client Config

Read `CLAUDE.md`. Extract platform, handle, credentials, analytics IDs.
Read `context/client-info.md` for business summary.

---

## Phase 1: Load All Historical Files

Scan `Content & SEO/outputs/{platform}-{handle}/` — load EVERY file across ALL dates.

**Sort all files by YYYY-MM-DD ascending (oldest first) to build the timeline.**

| Folder | Files to load |
|---|---|
| `audit/` | All AUDIT-*.pdf + POST-IMPLEMENTATION-AUDIT-*.pdf |
| `implementation/` | All IMPLEMENTATION-PLAN-*.pdf + SEO-PLAN-*.pdf + SNAPSHOT-*.pdf |
| `research/` | All GSC-REPORT-*.pdf + GA4-REPORT-*.pdf + SOCIAL-TRENDS-*.pdf |
| `keywords/` | All KEYWORDS-*.pdf |
| `blog-plans/` | All BLOG-PLAN-*.pdf |
| `blogs/` | All *.html blog post files |

From this build:
- `ENGAGEMENT_START_DATE` — date of earliest file
- `ENGAGEMENT_END_DATE` — today's date
- `STARTING_SCORE` — SEO health score from earliest audit
- `LATEST_SCORE` — SEO health score from most recent post-implementation audit
- `TOTAL_BLOGS_WRITTEN` — count of all HTML files in blogs/
- `BLOG_TITLES` — list of all blog post titles written
- `TOTAL_CHANGES_EXECUTED` — count of all on-page changes made across all plans
- `RESOLVED_ITEMS` — all ✅ items across all audits

---

## Phase 2: Pull Fresh Performance Data

Pull current GSC + GA4 data using credentials from CLAUDE.md.

**GSC — compare vs earliest baseline:**
- Current top 10 queries: impressions, CTR, position
- Which queries improved in rank or CTR since engagement start
- New queries appearing that weren't in the starting baseline
- CTR gaps resolved (were position ≤10, CTR <3% — now CTR ≥3%)

**GA4 — compare vs earliest baseline:**
- Current sessions by channel vs starting baseline
- Organic traffic change (absolute + %)
- Top landing pages now vs starting period
- Bounce rate changes on key pages

If credentials not available: note it, work from last available reports.

---

## Phase 3: Write Final Report

**Save to:** `audit/FINAL-REPORT-YYYY-MM-DD.md` (converted to PDF after saving — see below)

The report must contain these sections:

---

### 1. Engagement Overview

```
Client:           {client name}
Website:          {URL}
Platform:         {Shopline / Webflow}
Engagement:       {START_DATE} → {END_DATE} ({X months})
Produced by:      RightClick:AI
```

---

### 2. SEO Health Score Journey

```
Starting score:   {STARTING_SCORE}/100  ({earliest audit date})
Current score:    {LATEST_SCORE}/100    ({most recent audit date})
Change:           +{N} points
```

Monthly score progression table if multiple audits exist:
| Month | Date | Score | Key Change |
|---|---|---|---|

---

### 3. On-Page Changes Executed

Full table of every change made across all months:

| Date | Resource | Type | Before | After |
|---|---|---|---|---|
| YYYY-MM-DD | /page-slug | SEO Title | Old title | New title |
| YYYY-MM-DD | Blog: Post Title | Meta Description | (missing) | New meta |

Total: **{N} on-page changes** across {N} implementation runs.

---

### 4. Content Published

All blog drafts pushed to CMS during this engagement:

| # | Post Title | Target Keyword | Collection | Date Pushed | Status |
|---|---|---|---|---|---|
| 1 | Title | keyword | Blog name | YYYY-MM-DD | Draft / Published |

Total: **{N} blog posts** written and pushed as drafts.

---

### 5. Organic Performance Movement

**Traffic:**
| Metric | Start Baseline | Current | Change |
|---|---|---|---|
| Organic sessions (30d) | X | Y | +Z% |
| Top organic landing page | /url | /url | — |

**Rankings (top keyword movements):**
| Query | Start Position | Current Position | Impressions Change | CTR Change |
|---|---|---|---|---|
| keyword | 15 | 8 | +X | +Y% |

**CTR gaps resolved:**
| Query | Was CTR | Now CTR | Position |
|---|---|---|---|

---

### 6. Issues Resolved

All items marked ✅ across all audit cycles:

| Category | Item | Resolved Date |
|---|---|---|
| Technical | Missing sitemap | YYYY-MM-DD |

Total: **{N} issues resolved** across the engagement.

---

### 7. Outstanding Items

Items that were identified but not yet executed (from last outstanding priorities list):

| Priority | Category | Item | Reason Not Yet Done |
|---|---|---|---|
| High | Schema | Organization schema on homepage | Requires Theme Editor (manual) |

---

### 8. Recommendations for Next Steps

Based on the current state of the site, here are the top 5 recommended next actions:

1. [Highest priority — based on current outstanding items and score]
2. ...
3. ...
4. ...
5. ...

---

### 9. Engagement Summary

One-paragraph narrative summary of the engagement: what was the starting state,
what was prioritised, what was achieved, and where the site now stands.

---

### Convert to PDF

After writing the report, run this Python script via Bash:

```python
import subprocess, sys, os
subprocess.run([sys.executable, '-m', 'pip', 'install', 'markdown', '-q'], capture_output=True)
import markdown as md_lib

md_path = "Content & SEO/outputs/{platform}-{handle}/audit/FINAL-REPORT-YYYY-MM-DD.md"  # ← set to the actual path written above
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

---

## Phase 4: Present Summary in Chat

After saving the report, present:

```
✅ Final Report complete

Engagement:       {START_DATE} → {END_DATE}
SEO Score:        {STARTING_SCORE} → {LATEST_SCORE} ({change})
Blogs written:    {N} posts
On-page changes:  {N} changes
Issues resolved:  {N} items

Full report saved to: audit/FINAL-REPORT-YYYY-MM-DD.pdf
```

---

## Sub-skill Reference Paths

`.skills/skills/seo-and-blog/skills/<skill-name>.md` (try first)
`.skills/skills/<skill-name>/SKILL.md` (fallback)
