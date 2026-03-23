# Phase 0 — Load Historical Context

**Mandatory. Always run first. Cannot be skipped — even if user says "just run the audit".**

This phase prevents re-doing completed work and ensures every monthly cycle builds on the last.

---

## Step 1 — Resolve output folder

Read `CLAUDE.md` → `Outputs` field → this is the base path.

```bash
OUTPUTS="Content & SEO/outputs/{platform}-{handle}"

ls -la "$OUTPUTS/audit/"          2>/dev/null || echo "NO_AUDIT_DIR"
ls -la "$OUTPUTS/implementation/" 2>/dev/null || echo "NO_IMPL_DIR"
ls -la "$OUTPUTS/research/"       2>/dev/null || echo "NO_RESEARCH_DIR"
ls -la "$OUTPUTS/keywords/"       2>/dev/null || echo "NO_KEYWORDS_DIR"
ls -la "$OUTPUTS/blog-plans/"     2>/dev/null || echo "NO_BLOGPLANS_DIR"
ls -la "$OUTPUTS/blogs/"          2>/dev/null || echo "NO_BLOGS_DIR"
```

If no folders exist at all → this is the first monthly run. Note it and proceed.

---

## Step 2 — Load most recent file in each category

Sort all files by `YYYY-MM-DD` suffix descending. Load the **newest** in each category.
If the newest file is empty or unreadable, try the next most recent. Continue until a readable file is found or the category is exhausted.

### Priority 1 — Post-Implementation Audit *(highest signal)*
Pattern: `audit/POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.md`

This is produced by Phase 6. If it exists, load it as the primary baseline. Extract:
- `LAST_SCORE` — SEO health score after last execution
- `RESOLVED_ITEMS` — all items marked ✅ (never re-recommend these)
- `OUTSTANDING_PRIORITIES` — the table of items still in progress
- `LAST_SEO_COVERAGE` — title/meta coverage % for blogs and products/pages
- `ORGANIC_BASELINE` — session count from last month's GSC/GA4

### Priority 2 — Base Audit *(fallback)*
Pattern: `audit/AUDIT-YYYY-MM-DD.md`

Load as supplementary context. If no POST-IMPLEMENTATION-AUDIT exists, this is the primary baseline. Extract:
- `AUDIT_SCORE`, `AUDIT_DATE`, `CRITICAL_ISSUES`, `QUICK_WINS`

### Priority 3 — SEO Plan
Pattern: `implementation/SEO-PLAN-YYYY-MM-DD.md`

Load most recent. Extract:
- What on-page changes were proposed
- Which were approved vs skipped
- Any items still outstanding

### Priority 4 — Keywords
Pattern: `keywords/KEYWORDS-YYYY-MM-DD.md`

Load most recent. Use as a reference to avoid duplicating keyword targets in this month's run.

### Priority 5 — Blog Plan + Blog History
Pattern: `blog-plans/BLOG-PLAN-YYYY-MM-DD.md` + list all files in `blogs/`

Load most recent blog plan. List all prior blog slugs/titles to prevent topic overlap.
Store as `PRIOR_BLOG_TOPICS` — Phase 3c must not repeat any of these.

### Priority 6 — Performance Reports
Pattern: `research/GSC-REPORT-YYYY-MM-DD.md`, `research/GA4-REPORT-YYYY-MM-DD.md`, or `research/PERFORMANCE-REPORT-YYYY-MM-DD.md`

Load most recent of each. Extract organic session baseline for month-over-month comparison.

---

## Step 3 — Build HISTORICAL_CONTEXT

Store the following in memory for use across all phases:

```
HISTORICAL_CONTEXT = {
  is_first_run:           true | false,
  last_run_date:          <date from most recent file>,
  primary_baseline:       POST-IMPLEMENTATION-AUDIT | AUDIT | none,
  current_score:          <score>/100 or "unknown",
  resolved_items:         [list of all ✅ items — never re-recommend],
  outstanding_priorities: [table rows from last report],
  seo_coverage:           { blogs: X%, products: X%, pages: X% } or "unknown",
  prior_blog_topics:      [list of prior post titles/topics],
  organic_baseline:       <session count or "not available">,
  prior_keywords:         [keyword targets from last KEYWORDS file]
}
```

---

## Step 4 — Announce and gate Phase 1

**If prior reports exist:**
```
Found existing outputs for {platform}-{handle}:
  ✅ Post-implementation audit: [date] (score: X/100)
  ✅ SEO plan: [date]
  ✅ Keywords: [date]
  ✅ Blog plan: [date] ([N] prior blog topics loaded)
  ✅ GSC/GA4 reports: [date]

Building on prior work.
Resolved items will not be re-recommended.
Prior blog topics will not be repeated.
Organic baseline: [N sessions] → will track change this month.
```

**If first run:**
```
No prior outputs found for {platform}-{handle}. This is the first monthly run.
Proceeding without historical context — all findings are new.
```

---

## Rules (enforced throughout all phases)

- **NEVER re-recommend** anything in `RESOLVED_ITEMS`
- **NEVER repeat** any topic in `PRIOR_BLOG_TOPICS`
- **DO flag regressions** — if a resolved item has broken again, call it out explicitly as a regression
- **DO carry forward** `OUTSTANDING_PRIORITIES` into Phase 3b as the starting list
- **NEVER overwrite** prior output files — always use today's date in new filenames
