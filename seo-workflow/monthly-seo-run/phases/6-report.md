# Phase 6 — Monthly Post-Implementation Report

**Goal:** Produce the full `POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.md` that becomes next month's starting baseline.

This is the most important file in the monthly cycle. It must be complete enough that a future Claude session can run Phase 0 (Load Historical Context) and know exactly where things stand.

---

## Step 1 — Gather all execution data

Load the following from this month's run:
1. `audit/AUDIT-YYYY-MM-DD.md` — this month's health score + issues
2. `implementation/SNAPSHOT-YYYY-MM-DD.md` — before/after record of every change
3. `implementation/SEO-PLAN-YYYY-MM-DD.md` — full proposed change list
4. `blog-plans/BLOG-PLAN-YYYY-MM-DD.md` — the 3 post specs
5. `blogs/*.html` — confirm all 3 posts exist (check filenames)
6. `research/GSC-REPORT-YYYY-MM-DD.md` — organic performance baseline
7. `research/GA4-REPORT-YYYY-MM-DD.md` — traffic baseline (if available)
8. `HISTORICAL_CONTEXT` — previous month's score, resolved items, outstanding items

---

## Step 2 — Write the report

```bash
mkdir -p "Content & SEO/outputs/{platform}-{handle}/audit"
```

Save to: `Content & SEO/outputs/{platform}-{handle}/audit/POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.md`

---

## Report Structure

### Section 1 — Monthly Summary

```
# Monthly SEO Report — {CLIENT_NAME}
**Period:** {MONTH YYYY}
**Date executed:** {TODAY}
**Platform:** {Shopline / Webflow}

## Score
| Metric | Last Month | This Month | Delta |
|---|---|---|---|
| SEO Health Score | X/100 | X/100 | +/- N |
| Organic Sessions | N | N | +/-% |
| SEO Title Coverage | X% | X% | +/-% |
| Meta Description Coverage | X% | X% | +/-% |
| Blog Posts Live | N | N | +N this month |
```

---

### Section 2 — Changes Executed

List every change that was successfully applied:

```
## Changes Applied (N total)

### Blog Posts Published
| Post | URL | Keywords | Words |
|---|---|---|---|
| [Title] | /[slug] | [primary keyword] | ~XXXX |

### On-Page SEO Changes
| Page/Item | Field | Before | After |
|---|---|---|---|
| /mattress-guide | SEO Title | Mattress Guide | Best Mattress for Back Pain SG 2026 — Owllight |
```

---

### Section 3 — Resolved Items

Mark all items as resolved that were:
a) Successfully executed this month
b) Already resolved in prior months (carry forward from `HISTORICAL_CONTEXT.resolved_items`)

```
## Resolved Items ✅
(These will NOT be re-recommended in future runs)

- ✅ /mattress-guide — SEO title optimised (was generic, now keyword-targeted)
- ✅ /about — Meta description added
- ✅ Blog: [Title] — published
[... all items]
```

**This is the most critical list for future runs.** Be thorough — every change that was successfully applied must appear here.

---

### Section 4 — Outstanding Priorities

Items that were proposed but not yet executed (failed, deferred, or out of scope):

```
## Outstanding Priorities ⏳
(Carry these into next month's Phase 3b as starting list)

| Priority | Page/Item | Issue | Proposed Action | Reason Not Done |
|---|---|---|---|---|
| HIGH | /products/pillow | No schema | Add Product schema | API error — retry next month |
| MED | /blog/sleep-tips | Title generic | Keyword-target title | Deferred — low priority |
```

---

### Section 5 — Regressions

Flag any item from `HISTORICAL_CONTEXT.resolved_items` that has broken again:

```
## Regressions ⚠️
(Previously resolved items that have broken — flagged for Phase 3b)

- ⚠️ [REGRESSION] /checkout — canonical tag removed (was fixed 2025-12-01, now missing again)
```

If none: `No regressions detected this month.`

---

### Section 6 — Keyword Performance

```
## Keywords Targeted This Month

| Keyword | Type | Intent | Target Page | Status |
|---|---|---|---|---|
| best mattress back pain singapore | Primary | Transactional | /mattress-guide | Optimised |
| [keyword] | Long-tail | Informational | [new blog post] | Published |
```

---

### Section 7 — Organic Baseline (for next month)

```
## Organic Baseline

| Metric | Value | Source |
|---|---|---|
| Organic sessions (last 30 days) | N | GA4 |
| Top page by organic clicks | /[page] | GSC |
| Top keyword by impressions | [keyword] | GSC |
| Average position | X.X | GSC |
| Average CTR | X.X% | GSC |
```

This baseline is loaded by Phase 0 next month to calculate month-over-month delta.

---

### Section 8 — Next Month Preview

```
## Recommended Focus — Next Month

Based on what remains outstanding and what this month's data shows:

1. [Highest priority outstanding item]
2. [Second priority — e.g. new keyword opportunity from GSC]
3. [Third priority — e.g. blog topic surfaced in social trends]
```

Keep this to 3 actionable bullet points. This is advisory only — next month's Phase 3 will re-derive from fresh data.

---

## Step 3 — Confirm save

After saving the report:

```
Phase 6 complete — Monthly SEO Run finished.

POST-IMPLEMENTATION-AUDIT saved:
audit/POST-IMPLEMENTATION-AUDIT-{YYYY-MM-DD}.md

This file will be loaded by Phase 0 next month as the primary baseline.

Summary:
  Score:    X/100 (was X/100 last month, Δ = +/-N)
  Changes:  N on-page changes applied
  Posts:    N blogs published
  Resolved: N items marked ✅ (will not be re-recommended)
  Outstanding: N items carried to next month
  Regressions: N (see report)

Monthly run complete. ✓
```
