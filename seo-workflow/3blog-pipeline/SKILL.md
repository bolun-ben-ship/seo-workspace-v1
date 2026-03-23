---
name: 3blog-pipeline
description: >
  SEO content pipeline — audit, research, plan, keyword research, blog calendar, write 3
  blog posts, and push to CMS as drafts. Does NOT execute on-page title/meta changes (use
  shopline-onpage-implement or webflow-onpage-implement for that). Platform-aware: auto-detects
  Shopline, Webflow, or WordPress from client CLAUDE.md and routes blog publishing to the
  correct CMS API. Always loads historical context first so it never repeats prior blog topics
  or re-recommends resolved items. Use when user says "write 3 blogs", "3blog-pipeline",
  "blog pipeline", "write SEO blogs", "content pipeline", "audit and write blogs", or
  "run full content pipeline".
user-invocable: true
argument-hint: "<domain> (e.g. owllight-sleep.com)"
---

# 3blog-pipeline — Content Pipeline

Runs the full 7-phase pipeline:
**[historical context] → seo-audit → last30days → GSC/GA4 → seo-plan → seo-keywords → blog-calendar → blog-write (3 posts) → push to CMS as drafts**

Platform-aware: reads `## Platform` → `CMS:` from `CLAUDE.md`. Announce detected platform before proceeding.

## Platform Routing Table

| Action | Shopline | Webflow | WordPress (preview) | Unknown |
|---|---|---|---|---|
| Blog draft push | REST API `published: false` | MCP `isDraft: true` | WP REST API `status: draft` | Save HTML locally |
| Required credential | `SHOPLINE_{CLIENT}_TOKEN` | `WEBFLOW_{CLIENT}_TOKEN` + MCP | `WP_{CLIENT}_TOKEN` | None |
| Approval prompt | "push to Shopline as drafts?" | "push to Webflow CMS as drafts?" | "push to WordPress as drafts?" | Not applicable |

If `PLATFORM = unknown`: save all 3 HTML files locally, skip CMS push, tell user to copy manually.
If `PLATFORM = wordpress`: preview support — confirm WP REST auth method and SEO plugin before pushing.

---

## Output Structure

```
Content & SEO/outputs/<platform>-<handle>/
├── audit/          ← AUDIT-YYYY-MM-DD.md
├── research/       ← GSC-REPORT-YYYY-MM-DD.md, GA4-REPORT-YYYY-MM-DD.md, SOCIAL-TRENDS-YYYY-MM-DD.md
├── implementation/ ← SEO-PLAN-YYYY-MM-DD.md
├── keywords/       ← KEYWORDS-YYYY-MM-DD.md
├── blog-plans/     ← BLOG-PLAN-YYYY-MM-DD.md
└── blogs/          ← 3 × HTML blog posts
```

## File Naming Convention

```
audit/AUDIT-YYYY-MM-DD.md
implementation/SEO-PLAN-YYYY-MM-DD.md
research/GSC-REPORT-YYYY-MM-DD.md
research/GA4-REPORT-YYYY-MM-DD.md
research/SOCIAL-TRENDS-YYYY-MM-DD.md
keywords/KEYWORDS-YYYY-MM-DD.md
blog-plans/BLOG-PLAN-YYYY-MM-DD.md
blogs/<post-slug>.html
```

---

## Step 0: Confirm Client Config

Read `CLAUDE.md` from the current workspace and extract:
- `Platform` → `Shopline` or `Webflow`
- `Store / Site handle` → output folder name
- `Access token` env var → for CMS push
- `GSC site`, `GA4 property ID`, `Credentials env var` → for research phase

---

## Step 0.5: Load Historical Context

Check output folder for prior reports. Sort by YYYY-MM-DD descending, load newest per category:
1. `audit/POST-IMPLEMENTATION-AUDIT-*.md` — current SEO score, resolved items (✅)
2. `audit/AUDIT-*.md` — baseline audit fallback
3. `implementation/SEO-PLAN-*.md` — prior action plan
4. `research/GSC-REPORT-*.md` / `GA4-REPORT-*.md` — performance baseline

**Rules:**
- NEVER re-recommend anything already marked ✅
- DO flag regressions
- DO carry forward outstanding priorities
- NEVER overwrite prior files — always use today's date

If no files exist: note first run, proceed.

---

## Step 1: SEO Audit

- Crawl site, detect business type (up to 500 pages)
- Run technical, content, schema, sitemap checks
- Produce health score (0–100) + prioritised action list
- Note score change vs prior if HISTORICAL_CONTEXT exists
- `mkdir -p` audit/ subfolder before saving
- **Save to:** `audit/AUDIT-YYYY-MM-DD.md`

---

## Step 2: Market Research (run Steps 2a + 2b in parallel)

**2a — Social trends (last30days)**
- Research primary topic (from `context/client-info.md`)
- Extract: top content themes, emerging questions, trending angles
- **Save to:** `research/SOCIAL-TRENDS-YYYY-MM-DD.md`

**2b — Performance data (GSC + GA4)**
- Pull top queries by impressions, CTR gaps (position ≤10, CTR <3%), top pages
- Pull sessions by channel, top landing pages, bounce rates
- **Save to:** `research/GSC-REPORT-YYYY-MM-DD.md` + `research/GA4-REPORT-YYYY-MM-DD.md`

**2c — Synthesise**
Combine into `RESEARCH_SUMMARY`: gaps, ranking opportunities, trending angles.

---

## Step 3: SEO Implementation Plan

- Build 4-week sprint plan from audit + market + performance data
- Prioritise: GSC CTR gaps → audit findings → content opportunities
- Skip anything already resolved in HISTORICAL_CONTEXT
- `mkdir -p` implementation/ before saving
- **Save to:** `implementation/SEO-PLAN-YYYY-MM-DD.md`

---

**⏸ STOP — Approval Required**

Present the SEO plan summary (top 5 fixes, content opportunities, GSC CTR gaps, blog topics).

Say: **"Approve to proceed to keyword research and blog writing?"**

Do not continue until the user explicitly approves.

---

## Step 4: Keyword Research

- Generate 4 keyword tables: primary (high-intent), long-tail transactional, long-tail informational, PAA/AI queries
- Prioritise keywords with GSC impressions + low CTR, or high last30days social engagement
- **Save to:** `keywords/KEYWORDS-YYYY-MM-DD.md`

---

## Step 5: Blog Plan (28-Day Calendar)

- Plan exactly 3 blog posts — no topic overlap with prior months
- Each post: topic, title, target keyword cluster, word count, template type
- Space posts at least 7 days apart; mix informational + transactional intent
- **Save to:** `blog-plans/BLOG-PLAN-YYYY-MM-DD.md`

---

## Step 6: Write 3 Blog Posts

- Load `blog-plans/BLOG-PLAN-*.md`, `keywords/KEYWORDS-*.md`, and `context/tone-guide.md` (if present)
- For each post:
  - Answer-first format, TL;DR box, sourced statistics, citation capsules
  - FAQ schema, internal linking zones
  - Output format: **HTML**
  - `mkdir -p` blogs/ before saving
  - **Save to:** `blogs/<post-slug>.html`
- Confirm all 3 posts saved

---

## Step 7: Push Blogs to CMS as Drafts (platform-aware)

Read `## Platform` from `CLAUDE.md` and route to the correct push method.

---

### If Platform = Shopline

**7a — Set API constants**
```
BASE_URL = https://{STORE_HANDLE}.myshopline.com/admin/openapi/v20251201
HEADERS  = Authorization: Bearer {ACCESS_TOKEN}
           Content-Type: application/json; charset=utf-8
```
Get `ACCESS_TOKEN` from the env var named in `CLAUDE.md` (`Access token` field).

**7b — Identify target blog collection**
If a blog collection was specified (e.g., in ai-seo-pipeline questionnaire), use it.
Otherwise, call `GET {BASE_URL}/store/blogs.json` and list available collections.
Ask user which collection to use if more than one exists and none was pre-selected.

For owllight-sleep, confirmed collections:
| Blog | ID |
|---|---|
| News | `686f553a771a545e09f23934` |
| Brand Story | `689b052bbdb0ff72d20d2f53` |
| Mattress Comparisons | `68e8d3d72d9b3812239e99a8` |
| Owllight Series | `69aff002ec210535546e9a58` |

**7c — Push each post as a draft**

For each of the 3 blog posts:
1. Derive `handle` from slug (lowercase, hyphens, no spaces)
2. Read HTML body from `blogs/<post-slug>.html` — strip `<html>`, `<head>`, `<body>` wrappers
3. POST to Shopline:

```python
import requests, os

BASE_URL = f"https://{STORE_HANDLE}.myshopline.com/admin/openapi/v20251201"
ACCESS_TOKEN = os.environ[TOKEN_ENV_VAR]
HEADERS = {
    "Authorization": f"Bearer {ACCESS_TOKEN}",
    "Content-Type": "application/json; charset=utf-8"
}

payload = {
    "blog": {
        "title": post_title,
        "handle": post_slug,
        "content_html": html_body,
        "published": False
    }
}
resp = requests.post(
    f"{BASE_URL}/store/blogs/{BLOG_COLLECTION_ID}/articles.json",
    headers=HEADERS,
    json=payload
)
if resp.status_code in (200, 201):
    new_id = resp.json()["blog"]["id"]
    print(f"Created draft: {post_title} (ID: {new_id})")
else:
    print(f"Error {resp.status_code}: {resp.text}")
```

**IMPORTANT quirks (confirmed against owllight-sleep):**
- Payload MUST use `{"blog": {...}}` wrapper — NOT `{"article": {...}}`
- MUST include `"handle"` field — missing handle causes 422
- Response key is `"blog"`, not `"article"`: use `resp.json()["blog"]["id"]`
- `"published": False` creates a draft (not live on store)

**7d — Set SEO metafields on each new draft**

After creating each draft, set its SEO title and meta description:
```python
payload = {
    "metafields": [
        {
            "owner_resource": "articles",
            "owner_id": new_article_id,
            "namespace": "seo",
            "key": "seoTitle",
            "value": seo_title,
            "value_type": "string"
        },
        {
            "owner_resource": "articles",
            "owner_id": new_article_id,
            "namespace": "seo",
            "key": "seoDescription",
            "value": meta_description,
            "value_type": "string"
        }
    ]
}
resp = requests.post(f"{BASE_URL}/metafields_set.json", headers=HEADERS, json=payload)
```

**7e — Confirm**
Report all 3 draft titles and their Shopline article IDs.
Remind user: open Shopline Admin → Blog → [collection] → add images → publish when ready.

---

### If Platform = Webflow

**Check first:** Look for Webflow MCP tools (`data_cms_tool`, `data_pages_tool`).
If not available: skip this step, tell user to copy HTML manually.

**7a — Find Blog CMS collection**
Call `data_cms_tool` → `get_collection_list`. Find Blog Posts collection ID.
Call `get_collection_details` to map exact field slugs.

Key fields (verify against actual schema):
- `name` (PlainText, required) — post title
- `slug` (PlainText, required) — URL slug
- `content` (RichText) — full HTML body
- `preview-text-2` (PlainText) — plain text excerpt ~100 words
- `meta-title` (PlainText) — SEO title
- `meta-description` (PlainText, max 160 chars)
- `date-of-entry` (DateTime) — ISO datetime

**7b — Push each post as draft**
Call `create_collection_items` with `isDraft: true`.
HTML body → RichText field. PlainText fields must have tags stripped.

**7c — Confirm**
Report 3 pushed titles and /blog/<slug> paths.
Remind user: open Webflow CMS → add images → publish when ready.

---

### If Platform = Other

Save HTML files locally (already done in Step 6).
Note: CMS push not supported for this platform — copy HTML manually.

---

## Pipeline Complete

```
✅ 3blog-pipeline complete

Historical context:  [date of prior reports, or "first run"]
Score change:        [prior] → [new] (or "baseline established")

Phase 0.5 — History:    Prior reports loaded ✓
Phase 1   — SEO Audit:  audit/AUDIT-YYYY-MM-DD.md
Phase 2a  — Trends:     research/SOCIAL-TRENDS-YYYY-MM-DD.md
Phase 2b  — GA4/GSC:    research/GSC-REPORT-YYYY-MM-DD.md + GA4-REPORT-YYYY-MM-DD.md
Phase 3   — SEO Plan:   implementation/SEO-PLAN-YYYY-MM-DD.md
Phase 4   — Keywords:   keywords/KEYWORDS-YYYY-MM-DD.md
Phase 5   — Blog Plan:  blog-plans/BLOG-PLAN-YYYY-MM-DD.md
Phase 6   — Blogs:      blogs/<post-1>.html
                        blogs/<post-2>.html
                        blogs/<post-3>.html
Phase 7   — CMS Push:   ✅ 3 drafts created in [Platform] (or: not connected)

Next: Open [CMS] → add images → publish each post when ready.
```

---

## Sub-skill Reference Paths

`.skills/skills/seo-and-blog/skills/<skill-name>.md` (try first)
`.skills/skills/<skill-name>/SKILL.md` (fallback)

If neither found, execute from first principles using the skill name as guidance.
