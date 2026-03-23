---
name: shopline-onpage-implement
description: >
  On-page SEO implementation for Shopline stores. Loads historical context, runs SEO audit,
  pulls GSC + GA4 performance data, fetches live store snapshot (pages, blog posts, SEO
  metafields) via Shopline Admin REST API, runs last30days market research, builds a
  prioritised implementation plan with before/after values for every change, presents an
  approval UI, then executes approved on-page changes (SEO titles, meta descriptions, schema)
  directly via API and saves a post-implementation report. Always builds on prior months —
  never re-recommends resolved items. Use when the user asks to: fix on-page SEO on Shopline,
  "run Shopline on-page SEO", "implement SEO changes on Shopline", "fix titles and meta on
  Shopline", or "shopline onpage implement".
user-invocable: true
argument-hint: "<store-handle> (e.g. owllight-sleep)"
---

# Shopline SEO Orchestrator

A 8-phase pipeline: historical context → audit → performance data → store snapshot →
implementation plan → approval → execution → report.

Fully scalable: no credentials are hardcoded. Every store-specific value is collected
at startup or fetched from the API automatically.

---

## Prerequisites

Before starting, collect the following. If an argument was passed (e.g. `/shopline-seo-orchestrator mystore`), use it as the store handle and skip asking.

### Configured stores (use these automatically — no need to ask)

| Store Handle | Token variable | Notes |
|---|---|---|
| `owllight-sleep` | See workspace env | 3-year private app token |

For any store not listed above, ask the user for their handle and token.

### Required at startup (for unconfigured stores)

Ask the user for these values if not already known:

| Variable | Description | Example |
|---|---|---|
| `STORE_HANDLE` | Subdomain of the Shopline store | `mystore` |
| `ACCESS_TOKEN` | Private app Bearer JWT token from store admin | Long JWT string |

Store both in memory for use across all phases. Do NOT log the token to any output file.

### Auto-fetched (no need to ask the user)

`BLOG_COLLECTION_IDs` — fetched automatically in Phase 2b from `/store/blogs.json`.
Shopline stores can have multiple blog collections. Fetch all and present them.
For owllight-sleep, the confirmed collections are:

| Blog | ID | Articles |
|---|---|---|
| News | `686f553a771a545e09f23934` | 1 |
| Brand Story | `689b052bbdb0ff72d20d2f53` | 2 |
| Mattress Comparisons | `68e8d3d72d9b3812239e99a8` | 4 |
| Owllight Series | `69aff002ec210535546e9a58` | 1 |

### Optional (use if configured for this workspace)

- GSC service account key + site URL (for Phase 2a)
- GA4 property ID (for Phase 2a)

---

## API Constants

Set these at the start of every Phase that makes API calls:

```
BASE_URL  = https://{STORE_HANDLE}.myshopline.com/admin/openapi/v20251201
HEADERS   = Authorization: Bearer {ACCESS_TOKEN}
            Content-Type: application/json; charset=utf-8
API_VER   = v20251201
```

If any call returns `401 Unauthorized`, stop and tell the user the token is invalid or missing a required scope. Do not retry silently.

If any call returns `429 Too Many Requests`, wait 2 seconds and retry once.

---

## Output Folder

All outputs go to:
```
{WORKSPACE_ROOT}/outputs/shopline-{STORE_HANDLE}/
├── audit/              ← Phase 1 audit (AUDIT-YYYY-MM-DD.md)
│                          Phase 6 post-implementation report
├── research/           ← Phase 2a GSC/GA4 data
└── implementation/     ← Phase 2b snapshot + Phase 3 plan
```

**WORKSPACE_ROOT** — set this to the base Content & SEO folder for this project.
Default: the current working directory. Update this line when copying to a new project.

Before saving any file, create the target subfolder:
```bash
mkdir -p "{WORKSPACE_ROOT}/outputs/shopline-{STORE_HANDLE}/audit"
mkdir -p "{WORKSPACE_ROOT}/outputs/shopline-{STORE_HANDLE}/research"
mkdir -p "{WORKSPACE_ROOT}/outputs/shopline-{STORE_HANDLE}/implementation"
```

All output filenames include date suffixes — never overwrite prior files.

---

## File Naming Convention

```
audit/AUDIT-YYYY-MM-DD.md
audit/POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.md
implementation/SHOPLINE-SNAPSHOT-YYYY-MM-DD.md
implementation/IMPLEMENTATION-PLAN-YYYY-MM-DD.md
research/PERFORMANCE-REPORT-YYYY-MM-DD.md
research/GSC-REPORT-YYYY-MM-DD.md
research/GA4-REPORT-YYYY-MM-DD.md
research/SOCIAL-TRENDS-YYYY-MM-DD.md
```

---

## Phase Overview

| Phase | Name | Action |
|---|---|---|
| 0 | Load Historical Context | Check output folder for prior reports |
| 1 | SEO Audit | `phases/1-audit.md` |
| 2a | GSC + GA4 Performance Data | Pull live data via Python API (if configured) |
| 2b | Shopline Data Fetch | `phases/2-shopline-fetch.md` |
| 2c | Market Research (last30days) | Social trends for the store's niche |
| 3 | Implementation Plan | `phases/3-implementation-plan.md` |
| 4 | User Approval | `phases/4-approval.md` |
| 5 | Execute Changes | `phases/5-execute.md` |
| 6 | Post-Implementation Report | `phases/6-report.md` |

Read each phase file before executing that phase. Do not skip ahead.

---

## Execution Flow

```
Phase 0 (History)       → historical context loaded
       ↓
Phase 1 (Audit)         → audit findings
       ↓
Phase 2a (GSC/GA4)      → CTR gaps, ranking data, traffic baseline
Phase 2b (Shopline)     → pages, blog posts, existing SEO metafields
Phase 2c (Trends)       → social/market signals for the niche (last30days)
       ↓
Phase 3 (Plan)          → proposed changes with before/after values
       ↓
Phase 4 (Approval)      → user confirms what to apply
       ↓
Phase 5 (Execute)       → changes applied via Shopline REST API
       ↓
Phase 6 (Report)        → before/after report saved
```

**Stop at Phase 4 and wait for explicit user approval before Phase 5.**
Never execute changes without approval.

---

## Phase 0 — Load Historical Context (ALWAYS run first, before anything else)

**This phase is mandatory. Do not skip it, even if the user says "just run the audit".**

### Step 1 — Resolve the output folder

The output folder for this store is:
```
{WORKSPACE_ROOT}/outputs/shopline-{STORE_HANDLE}/
```

Run the following to see what exists:
```bash
ls -la "{WORKSPACE_ROOT}/outputs/shopline-{STORE_HANDLE}/audit/" 2>/dev/null || echo "NO_AUDIT_DIR"
ls -la "{WORKSPACE_ROOT}/outputs/shopline-{STORE_HANDLE}/implementation/" 2>/dev/null || echo "NO_IMPL_DIR"
ls -la "{WORKSPACE_ROOT}/outputs/shopline-{STORE_HANDLE}/research/" 2>/dev/null || echo "NO_RESEARCH_DIR"
```

If the folder doesn't exist at all → this is a first run. Note it and proceed to Phase 1.

---

### Step 2 — Find and load the most recent file in each category

Sort all files by the date suffix in the filename (`YYYY-MM-DD`) descending. Load the **newest** in each category:

#### Priority 1 — Post-Implementation Audit (highest signal)
Pattern: `audit/POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.md`

This file is produced by Phase 6. It contains:
- Current SEO score (after last execution)
- All resolved items (marked ✅)
- Outstanding priorities table
- SEO metafield coverage numbers

If this file exists → **load it as the primary baseline**. Extract:
- `LAST_SCORE` — the Post-Implementation Score
- `RESOLVED_ITEMS` — everything marked ✅ (do not re-recommend these)
- `OUTSTANDING_PRIORITIES` — the table at the end of the report
- `LAST_SEO_COVERAGE` — blog post and page metafield coverage %

#### Priority 2 — Base Audit
Pattern: `audit/AUDIT-YYYY-MM-DD.md`

Load as supplementary context if it exists. If no POST-IMPLEMENTATION-AUDIT exists, this becomes the primary baseline.

Extract:
- `AUDIT_SCORE` — the overall SEO Health Score
- `AUDIT_DATE` — date from filename
- `CRITICAL_ISSUES` — top critical items from the audit
- `QUICK_WINS` — top quick wins

#### Priority 3 — Implementation Plan
Pattern: `implementation/IMPLEMENTATION-PLAN-YYYY-MM-DD.md`

Load if it exists. Extract:
- What was proposed (Categories A–G)
- What was approved vs skipped
- Any items still outstanding from the plan

#### Priority 4 — Shopline Snapshot
Pattern: `implementation/SHOPLINE-SNAPSHOT-YYYY-MM-DD.md`

Load if it exists. This shows the previous "before" state of all pages and blog posts.
Use it to detect regressions (e.g., a page that previously had a seoTitle that is now missing).

#### Priority 5 — Performance Report
Pattern: `research/PERFORMANCE-REPORT-YYYY-MM-DD.md` or `research/GSC-REPORT-YYYY-MM-DD.md`

Load if it exists. Extract organic session baseline and CTR gap list for comparison.

---

### Step 3 — Build HISTORICAL_CONTEXT

After loading all available files, store a summary as `HISTORICAL_CONTEXT`:

```
HISTORICAL_CONTEXT = {
  last_run_date:          <date from most recent file>,
  primary_baseline:       POST-IMPLEMENTATION-AUDIT | AUDIT | none,
  current_score:          <score>/100 or "unknown",
  resolved_items:         [list of ✅ items — never re-recommend these],
  outstanding_priorities: [table rows from last report],
  seo_coverage:           { blog_posts: X%, pages: X% } or "unknown",
  prior_implementation:   <summary of what was last executed>,
  organic_baseline:       <session count or "not available">
}
```

---

### Step 4 — Announce and gate Phase 1

After loading, announce what was found:

**If prior reports exist:**
```
Found existing outputs for shopline-{STORE_HANDLE}:
  ✅ Post-implementation audit: [date] (score: X/100)
  ✅ Base audit: [date]
  ✅ Implementation plan: [date]
  ✅ Shopline snapshot: [date]
  ✅ Performance report: [date]

Building on prior work. Resolved items will not be re-recommended.
Outstanding priorities carried forward into Phase 3.
```

**If only a base audit exists (no post-impl):**
```
Found base audit from [date] (score: X/100). No implementation has been run yet.
Carrying forward audit findings into Phase 3.
```

**If nothing exists:**
```
No prior outputs found for shopline-{STORE_HANDLE}. This is a first run.
```

---

### Step 5 — Decide whether Phase 1 (audit) needs to run

Pass this decision to Phase 1:

| Situation | Phase 1 action |
|---|---|
| POST-IMPLEMENTATION-AUDIT exists AND is < 30 days old | Skip fresh audit — use post-impl report as baseline |
| AUDIT exists AND is < 30 days old, no post-impl | Skip fresh audit — use existing audit |
| Most recent audit (any type) is > 30 days old | Run a fresh audit |
| No audit files at all | Run a fresh audit |

**Do not make this decision silently.** Tell the user which path you're taking and why.

---

### Rules (enforced throughout all phases)

- **NEVER re-recommend** anything in `RESOLVED_ITEMS` (marked ✅ in prior reports)
- **DO flag regressions** — if a resolved item has regressed (e.g., a seoTitle that was previously set is now missing in the new snapshot), call it out explicitly as a regression, not a new finding
- **DO carry forward** `OUTSTANDING_PRIORITIES` as the starting list for Phase 3
- **DO compare** new Shopline snapshot data against the prior snapshot to detect regressions
- **NEVER overwrite** prior output files — always use today's date in new filenames

---

## Phase 2a — GSC + GA4 Performance Data

Pull live performance data if credentials are available for this workspace. If not configured, skip this phase and note it in the plan.

**Read from the loaded CLAUDE.md:**
- `Credentials env var` → the env var holding the path to the JSON key file
- `GA4 property ID` → the numeric GA4 property ID
- `GSC site` → the site URL for GSC queries

If any of these are missing from CLAUDE.md, skip this phase and note it in the plan.

If credentials ARE available:
- Pull top queries (impressions, CTR, position) from GSC for last 30 days
- Pull sessions by channel + top landing pages from GA4 for last 30 days
- Identify CTR gap opportunities: position ≤10, CTR <3%
- Save to: `research/GSC-REPORT-YYYY-MM-DD.md` and `research/GA4-REPORT-YYYY-MM-DD.md`
- Feed CTR gaps into Phase 3 as priority fixes

---

## Phase 2c — Market Research (last30days)

Run last30days research for the store's primary niche before building the implementation plan.
This reveals what the target audience is actually talking about, searching for, and sharing.

**Read from the loaded CLAUDE.md:**
- `context/client-info.md` → extract the primary niche/topic for the last30days query

**Execute:**
- Run last30days research skill for the primary niche topic (e.g., "sleep products mattress")
- Focus: top content themes, emerging questions, competitor mentions, trending angles
- Save to: `{WORKSPACE_ROOT}/outputs/shopline-{STORE_HANDLE}/research/SOCIAL-TRENDS-YYYY-MM-DD.md`

**Feed into Phase 3:** Surface content gaps and trending angles for the blog plan.

---

## Important Constraints

**What CAN be changed via the Shopline API:**
- Blog post SEO title and meta description (MetafieldsSet, `owner_resource: "articles"`, `namespace: "seo"`, keys: `seoTitle` / `seoDescription`)
- Product SEO title and meta description (MetafieldsSet, `owner_resource: "products"`)
- Blog post body content, title, excerpt, author, handle (`content_html`, `digest`, `author`)
- Blog post published status (`published` boolean + `published_at` timestamp)
- Creating new blog posts (POST to articles endpoint)

**What CANNOT be changed via API (flag in the plan):**
- Page-level SEO — the store uses theme pages not custom Pages API; manage via Shopline Theme Editor
- Theme template HTML/Liquid — requires Shopline Theme Editor
- Navigation menus — requires store admin
- robots.txt — managed at store level, not via API
- Sitemap configuration — auto-generated by Shopline
- URL slugs on live indexed pages — risks breaking rankings; flag as manual
- Image alt text on static theme assets — requires Theme Editor

Always clearly note these limitations so the user knows what still needs manual work.

---

## Confirmed API Behaviours (tested against owllight-sleep, 2026-03-20 — updated 2026-03-20)

These are live-confirmed quirks — do not assume standard behaviour:

**1. Articles endpoint returns key `"blogs"`, not `"articles"`**
`GET /store/blogs/:id/articles.json` → response body: `{ "blogs": [...] }`
Always use `.get("blogs", [])` when parsing article lists.

**6. Article CREATE requires `"blog"` wrapper AND `"handle"` field**
`POST /store/blogs/:id/articles.json` MUST wrap the payload in `{"blog": {...}}` AND include
a `"handle"` field. Using `{"article": {...}}` or flat fields returns `422 "title not allow blank"`.
The response also uses the `"blog"` key: `result["blog"]["id"]` gives the new article ID.
```python
payload = {"blog": {"title": "...", "handle": "my-slug", "content_html": "...", "published": False}}
resp = requests.post(f"{BASE_URL}/store/blogs/{BLOG_ID}/articles.json", headers=HEADERS, json=payload)
new_id = resp.json()["blog"]["id"]
```

**2. Metafields fall back to shop-level when no article-level SEO is set**
`GET /metafields.json?owner_resource=articles&owner_id=X` returns the shop-level
SEO metafields if no article-specific ones exist, with `owner_resource: "shop"`.
Always filter returned metafields by `owner_resource == "articles"` to determine
whether an article has its own SEO set. If none, it's inheriting the store default.

**3. Pages endpoint returns empty — store has no custom pages**
`GET /store/pages.json` returns `{"errors":"script tag data not found:pages"}` consistently
across all API versions, even with `read_page` + `write_page` scopes confirmed present.
This is NOT a permission error — it means the store uses Shopline theme-level pages, not
custom Pages API pages. Theme pages cannot be managed via API; their SEO must be handled
in the Shopline Theme Editor manually. Do not flag this as a scope issue.

**4. Two token types — only the JWT works**
The 40-char hex strings (App Key, App Secret) do NOT work as Bearer tokens.
Only the full JWT (`eyJ...`) is the actual access token.

**5. Token that works for owllight-sleep**
The 3-year token starting `eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6MCwi...`
Expires: 2029. The shorter JWT (starting `eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3Mi...`) returns invalid.

---

## Shopline SEO Metafield Reference

SEO metadata on Shopline is always written via the MetafieldsSet API, never as inline resource fields.

| What | namespace | key | owner_resource |
|---|---|---|---|
| SEO title | `seo` | `seoTitle` | `articles` / `pages` / `products` / `blogs` |
| Meta description | `seo` | `seoDescription` | `articles` / `pages` / `products` / `blogs` |
| Meta keywords | `seo` | `seoKeyword` | `articles` / `pages` / `products` / `blogs` |

MetafieldsSet endpoint (upsert, max 25 per call):
```
POST {BASE_URL}/metafields_set.json
```

Reading existing SEO metafields:
```
GET {BASE_URL}/metafields.json?owner_resource=articles&owner_id={id}&namespace=seo
```
