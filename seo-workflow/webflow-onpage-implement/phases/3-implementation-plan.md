# Phase 3 — Implementation Plan

Cross-reference the audit findings (Phase 1) with the Webflow snapshot (Phase 2b),
GSC/GA4 data (Phase 2a), and market signals (Phase 2c — SOCIAL-TRENDS) to produce
a clear, categorised implementation plan. This plan is what the user will approve in Phase 4.

**Load before starting:**
- `audit/AUDIT-YYYY-MM-DD.md` — SEO findings
- `research/GSC-REPORT-YYYY-MM-DD.md` and/or `GA4-REPORT-YYYY-MM-DD.md` — performance gaps
- `research/SOCIAL-TRENDS-YYYY-MM-DD.md` — what the audience is talking about right now
- `implementation/SHOPLINE-SNAPSHOT-YYYY-MM-DD.md` or Webflow fetch data — current site state

## Goal

A document that shows:
- Exactly what will change (before → after, for every single field)
- Which category each change falls into
- What CANNOT be done via API (so the user knows what to handle manually)
- A risk/impact note for any change that touches live-indexed pages

## Structure

Organise changes into these categories. Only include categories that have actual changes.

---

### Category A — Title Tags

For every production page where the title is missing, generic, uses brand acronyms
(e.g., "AEHL"), or doesn't contain the primary keyword target:

| Page | Current Title | Proposed Title | Reason |
|---|---|---|---|
| /about | About - AEHL | Meet the Team — [Brand] | Keyword-rich, removes acronym |

**Title tag rules:**
- Lead with the primary keyword, not the brand name (except homepage)
- Brand name at the end, separated by em dash (—)
- 50–60 characters
- Use the full canonical brand name consistently (never acronyms)
- Expat-specific where the audience is expats

---

### Category B — Meta Descriptions

For every production page where the description is missing or auto-generated:

| Page | Current Description | Proposed Description |
|---|---|---|
| /faqs | (auto-generated) | Answers to the most common questions... |

**Meta description rules:**
- 140–160 characters
- Action-oriented — tell the user what they'll get
- Include a soft keyword signal
- Do not stuff keywords

---

### Category C — Schema Injection

For pages missing structured data that would benefit from it:

| Page | Schema Type | Why |
|---|---|---|
| / (Homepage) | Organization + FinancialService | Entity establishment, sameAs links |
| /faqs | FAQPage | Rich result eligibility in SERP |
| Blog template | Article + BreadcrumbList | E-E-A-T signal, AI citation readiness |

Provide the exact JSON-LD for each schema, pre-validated and under 2000 characters.
Reference the script injection pattern from SKILL.md.

---

### Category D — Noindex Pages

List every page that should be removed from Google's index:

| Page | Path | Reason |
|---|---|---|
| Landing page | /landing-page | Paid ads page — dilutes organic authority |
| Staging pages | /landing-page-v2 etc. | v2 redesign not ready for index |

**Noindex decision criteria:**
- Paid ads landing pages → always noindex
- Thank-you / confirmation pages → always noindex
- Staging / v2 redesign pages → noindex until officially launched
- Duplicate or "copy" pages → noindex or delete
- Individual broker booking pages (when a main booking page exists) → noindex

---

### Category E — CMS Field Updates (Blog Posts)

If blog meta titles/descriptions, category assignments, or field renames are in scope:

| Change | Description |
|---|---|
| Category renames | Field display name update (cosmetic, doesn't affect slugs) |
| Blog meta fields | Per-post SEO title and description via CMS API |

---

### Category F — Cannot Be Done Via API (Manual Work Required)

This section is critical. Always include it, even if short. Users need to know what
the API cannot touch so they can plan manual work in the Webflow Designer.

**These require the Webflow Designer or additional API scopes:**

| Item | Why It Can't Be Done | Manual Action Required |
|---|---|---|
| H1/H2 headings on static pages | Requires Design API or Designer canvas | Edit in Webflow Designer > Page Settings |
| Body copy on static pages | Requires Design API | Edit in Webflow Designer |
| Image alt text (non-CMS) | Requires Asset API with Designer open | Edit each image in Designer |
| robots.txt | Requires Site Config API scope | Edit in Webflow > Site Settings > SEO |
| Sitemap configuration | Requires Site Config API | Edit in Webflow > Site Settings > SEO |
| URL slug changes | API can change slugs but risks breaking live links | Plan carefully; update internal links after |
| Page redirect rules | Requires Site Config API | Add in Webflow > Site Settings > Redirects |

---

## Output

Run `mkdir -p` for the `implementation/` subfolder before saving.
Save the implementation plan to:
`Content & SEO/outputs/<domain>/implementation/IMPLEMENTATION-PLAN-YYYY-MM-DD.md`
(e.g. `IMPLEMENTATION-PLAN-2026-03-20.md` — always use today's date, never overwrite prior plans)

After saving, present a concise summary table in chat and wait for explicit user approval before Phase 4 (execution). Do not touch any Webflow pages until approved.

The plan must be specific enough that a non-technical user can read it and understand
exactly what will happen to their site. No vague bullet points — every change must have
a before and after value.

At the end of the plan, add a summary count:
```
## Summary
- Title tags to update: X pages
- Meta descriptions to update: X pages
- Schema scripts to inject: X scripts across Y pages
- Pages to noindex: X pages
- CMS field renames: X fields
- Manual actions required: X items (see Category F)
```
