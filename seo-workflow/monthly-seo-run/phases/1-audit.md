# Phase 1 — SEO Audit

**Goal:** Establish the current SEO baseline. Focus on what is new or changed since last month — not re-crawling everything already known.

---

## Step 1 — Decide whether to run a fresh audit

Check `HISTORICAL_CONTEXT.primary_baseline` and the date of the most recent audit:

| Situation | Action |
|---|---|
| POST-IMPLEMENTATION-AUDIT exists AND is < 30 days old | Skip fresh crawl — use post-impl report as this month's baseline. Note: "Using post-impl audit from [date] — skipping fresh crawl." |
| Any audit exists AND is < 14 days old | Skip fresh crawl — use existing audit as baseline. |
| Most recent audit is 14–30 days old | Run a focused crawl targeting only new pages, changed pages, and outstanding priorities. |
| Most recent audit is > 30 days old OR no audit exists | Run a full fresh audit. |

Always announce which path you're taking and why before proceeding.

---

## Step 2 — Run the audit (if needed)

Read `seo-and-blog/skills/seo-audit.md` or `seo-audit/SKILL.md` for detailed execution.

Key steps:
- Fetch homepage, detect business type (e-commerce, SaaS, local, content site, etc.)
- Crawl up to 500 pages
- Delegate to sub-specialists in parallel:
  - Technical: robots.txt, sitemaps, canonicals, Core Web Vitals
  - Content: E-E-A-T, readability, thin content, AI citation readiness
  - Schema: structured data detection and gaps
  - Sitemap: structure, coverage, missing pages
  - Images: alt text coverage, format, size
- Produce a health score (0–100) and prioritised action list

---

## Step 3 — Scope findings to what's new

If `HISTORICAL_CONTEXT` exists:
- Skip flagging anything already in `RESOLVED_ITEMS`
- Lead with: score change vs last month (if POST-IMPLEMENTATION-AUDIT was the baseline)
- Explicitly flag any **regressions** — items previously ✅ that have broken again
- Carry forward `OUTSTANDING_PRIORITIES` as the starting point for the action list

---

## Step 4 — Save and confirm

```bash
mkdir -p "Content & SEO/outputs/{platform}-{handle}/audit"
```

Save to: `Content & SEO/outputs/{platform}-{handle}/audit/AUDIT-YYYY-MM-DD.md`

Confirm save, then proceed to Phase 2 (research — run all three in parallel).
