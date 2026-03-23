# Phase 6 — Post-Implementation Report

Generate a comprehensive before/after report documenting every change made in Phase 5,
an updated SEO score, and a prioritised list of remaining work.

## Report File

Save as a NEW file — do not overwrite the original audit:
```
{WORKSPACE_ROOT}/outputs/shopline-{STORE_HANDLE}/audit/POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.md
```

---

## Report Structure

---

### Header

```markdown
# SEO Implementation Report — {STORE_HANDLE}.myshopline.com
**Report Type:** Post-Implementation Before/After Audit
**Date:** {date}
**Baseline Score:** {score}/100 (from Phase 1 audit)
**Post-Implementation Score:** {new_score}/100
**Data Source:** Shopline Admin REST API v20251201 + original audit findings
```

---

### Executive Summary

```markdown
| Category | Before | After | Change |
|---|---|---|---|
| Technical SEO | X/100 | X/100 | — |
| Content Quality | X/100 | X/100 | +/- X |
| On-Page SEO | X/100 | X/100 | +/- X |
| Schema / Structured Data | X/100 | X/100 | +/- X |
| Performance (CWV) | X/100 | X/100 | — |
| Images | X/100 | X/100 | — |
| AI Search Readiness | X/100 | X/100 | +/- X |
| **OVERALL** | **X/100** | **X/100** | **+/- X** |
```

Mark categories as "—" if no changes were made there.

---

### Change Log 1 — Page SEO Titles

| Page | Slug | Before | After |
|---|---|---|---|
| About Us | /about-us | (missing) | About Our Team — Brand |

---

### Change Log 2 — Page Meta Descriptions

| Page | Slug | Before | After |
|---|---|---|---|
| About Us | /about-us | (missing) | Compelling meta description here |

---

### Change Log 3 — Blog Post SEO Titles

| Post | Before | After |
|---|---|---|
| My Post Title | (missing) | Keyword-Rich SEO Title — Brand |

Include coverage improvement:
```
Blog SEO coverage: 3/12 posts (25%) → 10/12 posts (83%)
```

---

### Change Log 4 — Blog Post Meta Descriptions

Same format.

---

### Change Log 5 — New Blog Posts Created

For each new post:

```markdown
#### Post: "Full Title of New Blog Post"
- **URL:** /{handle}
- **Article ID:** {id}
- **Published:** Yes — {published_at}
- **seoTitle:** "SEO title here"
- **seoDescription:** "Meta description here"
- **Word count:** ~{count} words
- **Target keyword:** {keyword}
```

---

### Change Log 6 — Schema Injections

For each post where schema was injected:

```markdown
#### Article Schema — "{Post Title}"
- **Article ID:** {id}
- **Schema type:** Article
- **Injected at:** Top of content_html
- **Rich result eligibility:** Article rich result in Google Search
```

---

### Updated Audit Findings (Per Category)

For each of the 7 SEO categories:
- What was resolved in this phase (✅)
- What remains outstanding
- New score justification

---

### Outstanding Priorities — Next Phase

| Priority | Task | Effort | Impact | Can API Do It? |
|---|---|---|---|---|
| Critical | Add Organization schema to homepage | Medium | High | Manual (Theme Editor) |
| High | Fix H1 headings on key pages | Medium | High | Manual (Theme Editor) |
| Medium | Add FAQ schema to FAQ page | Medium | Medium | Manual (Theme Editor) |

Items from Category G (manual work) must appear here with clear instructions.

---

### SEO Metafield Coverage Summary

End with a current state snapshot so the next run can detect regressions:

```markdown
## Current SEO Coverage — {date}

| Resource | Total | seoTitle Set | seoDescription Set | Coverage |
|---|---|---|---|---|
| Blog posts (published) | X | X | X | X% |
| Custom pages | X | X | X | X% |

Next target: 100% coverage on all published blog posts.
```

---

## Score Calculation

Recalculate based only on what changed:

| What changed | Score impact |
|---|---|
| 5+ page SEO titles fixed | On-Page SEO: +10 to +20 |
| 5+ page meta descriptions added | On-Page SEO: +5 to +10 |
| 5+ blog post SEO titles fixed | On-Page SEO: +5 to +10 |
| 5+ blog post meta descriptions | On-Page SEO: +5 |
| New blog posts published (3+) | Content Quality: +5 to +10 |
| Article schema on blog posts | Schema: +5 to +10 |
| Organization schema (manual) | Schema: +20 to +30 (when done) |

Categories not touched keep the same score as the baseline.
Be conservative — accuracy over optimism.
