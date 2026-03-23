# Phase 6 — Post-Implementation Report

Generate a comprehensive before/after report documenting every change made in Phase 5,
an updated SEO score, and a prioritised list of remaining work.

## Goal

Produce a report the user can share with stakeholders, reference for future audits,
and use to track SEO progress over time.

## Report File

Save as a NEW file — do not overwrite the original audit:
```
Content & SEO/outputs/<domain>/audit/POST-IMPLEMENTATION-AUDIT-<YYYY-MM-DD>.md
```

---

## Report Structure

Use this exact structure:

---

### Header

```markdown
# SEO Implementation Report — <domain>
**Report Type:** Post-Implementation Before/After Audit
**Date:** <date>
**Baseline Score:** <score>/100 (from Phase 1 audit)
**Post-Implementation Score:** <new_score>/100
**Data Source:** Webflow Data API v2 + original audit findings
```

---

### Executive Summary

Show the score movement table:

```markdown
| Category | Before | After | Change |
|---|---|---|---|
| Technical SEO | X/100 | X/100 | +/- X |
| Content Quality | X/100 | X/100 | — |
| On-Page SEO | X/100 | X/100 | +/- X |
| Schema / Structured Data | X/100 | X/100 | +/- X |
| Performance (CWV) | X/100 | X/100 | — |
| Images | X/100 | X/100 | — |
| AI Search Readiness | X/100 | X/100 | +/- X |
| **OVERALL** | **X/100** | **X/100** | **+/- X** |
```

Mark categories as "—" if no changes were made in that area.
Only count score changes for categories where actual changes were executed.

---

### Change Log 1 — Title Tags

Table of every title that was changed:

```markdown
| Page | Before | After |
|---|---|---|
| /about | About - AEHL | Meet the Team — Brand |
```

Include a brief impact note after the table.

---

### Change Log 2 — Meta Descriptions

Same format — before/after table for every page.

---

### Change Log 3 — Schema Injection

For each script registered and applied:
- Script name and type (Organization, FAQPage, Article, etc.)
- Pages it was applied to
- What rich result eligibility it unlocks
- Include the actual JSON-LD that was injected

---

### Change Log 4 — Noindex Pages

Table of all pages that were noindexed, with reason.

Include the noindex management note:

```
**Important:** The noindex scripts injected via the Webflow custom code API override
Webflow's native "index" toggle. To re-index any of these pages, two steps are required:
1. Remove the noindex script from that page via the Webflow API
2. Confirm Webflow's native index setting is ON for that page
```

---

### Change Log 5 — CMS / Category Updates

Document any CMS field renames or blog post updates.

---

### Updated Audit Findings (Per Category)

For each of the 7 SEO categories, write a brief section covering:
- What was resolved in this phase
- What remains outstanding
- New score justification

This mirrors the structure of the original audit but reflects current state.

---

### Outstanding Priorities — Next Phase

Table of remaining work, prioritised:

```markdown
| Priority | Task | Effort | Impact |
|---|---|---|---|
| Critical | ... | ... | ... |
| High | ... | ... | ... |
| Medium | ... | ... | ... |
```

Items in the "Manual Work Required" category from the implementation plan
should appear here with clear instructions for the user.

---

### Noindex Management Reference

End the report with a quick reference table of all noindexed pages and how to re-index
them if needed. This section is important for the user to have handy.

---

## Score Calculation

Recalculate the SEO Health Score based only on what changed:

| What changed | Score impact |
|---|---|
| 5+ title tags fixed | On-Page SEO: +15 to +25 |
| 5+ meta descriptions added | On-Page SEO: +5 to +10 |
| Organization schema added | Schema: +20 to +30 |
| FAQ schema added | Schema: +10 to +15 |
| Article schema on blog | Schema: +5 to +10 |
| Critical pages noindexed | Technical SEO: +10 to +20 |
| Staging pages noindexed | Technical SEO: +5 to +10 |

Categories not touched get the same score as the baseline.
Be conservative — don't inflate scores. The goal is accuracy, not optimism.
