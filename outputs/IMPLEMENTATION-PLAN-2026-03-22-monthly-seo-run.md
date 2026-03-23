# Implementation Plan — monthly-seo-run Skill

**Date:** 2026-03-22
**Status:** Pending approval

---

## What This Adds

A new skill `monthly-seo-run` that runs in a client workspace and executes the complete monthly SEO cycle end-to-end:
- Content creation (audit + research + keywords + plan + blogs)
- Blog publishing via client's CMS credentials
- On-page SEO execution (titles, meta, schema) via API
- Post-implementation report

This is the **core deliverable** for the white-label partner model — one command, full monthly output, comprehensive final report.

---

## Why This Is Different From Existing Skills

| | site-automate | orchestrators | monthly-seo-run |
|---|---|---|---|
| SEO audit | ✅ | ✅ | ✅ |
| GSC + GA4 | ✅ | ✅ | ✅ |
| last30days | ✅ | ✅ | ✅ |
| Keywords | ✅ | ✗ | ✅ |
| Blog writing | ✅ | ✗ | ✅ |
| Post blogs to CMS | ✅ (Webflow only) | ✗ | ✅ (both platforms) |
| On-page title/meta changes | ✗ | ✅ | ✅ |
| Post-implementation report | ✗ | ✅ | ✅ |
| Monthly report (full cycle) | ✗ | ✗ | ✅ |
| Platform-aware (auto-detects) | ✗ | Per skill | ✅ |

---

## Files to Create

| File | Notes |
|---|---|
| `seo-workflow/monthly-seo-run/SKILL.md` | Main skill file |
| `seo-workflow/monthly-seo-run/phases/1-audit.md` | Audit phase with historical context |
| `seo-workflow/monthly-seo-run/phases/2-research.md` | GSC/GA4 + last30days in parallel |
| `seo-workflow/monthly-seo-run/phases/3-plan.md` | Keywords + SEO plan synthesis |
| `seo-workflow/monthly-seo-run/phases/4-content.md` | Blog plan + blog writing + tone guide |
| `seo-workflow/monthly-seo-run/phases/5-execute.md` | CMS post + on-page changes (platform-switching logic) |
| `seo-workflow/monthly-seo-run/phases/6-report.md` | Full monthly post-implementation report |

## Files to Modify

| File | Change |
|---|---|
| `seo-workflow/install.sh` | Add `monthly-seo-run` to SKILLS array + audit expected count |
| `CLAUDE.md` | Add to workspace structure + commands table |
| `SKILLS-REFERENCE.md` | Add entry |

---

## Phase Design

### Phase 0 — Load Historical Context
Same as orchestrators — mandatory, cannot be skipped.
- Load most recent POST-IMPLEMENTATION-AUDIT (highest priority)
- Load most recent base AUDIT
- Load most recent SEO-PLAN
- Load most recent KEYWORDS
- Load most recent BLOG-PLAN + scan blogs/ for prior post topics
- Load most recent GSC/GA4 reports
- Build HISTORICAL_CONTEXT object

### Phase 1 — SEO Audit
Read client CLAUDE.md → run seo-audit → save to `audit/AUDIT-YYYY-MM-DD.md`.
If audit is < 30 days old and a POST-IMPLEMENTATION-AUDIT exists, skip fresh crawl and use existing.

### Phase 2 — Research (run in parallel)
**2a — GSC + GA4:** Read credentials from CLAUDE.md, pull 30-day data, save reports.
**2b — Market research:** Run last30days for the client's primary niche topic (from client-info.md).
**2c — Synthesise:** Combine audit + GSC/GA4 + social trends into RESEARCH_SUMMARY.

### Phase 3 — Planning
**3a — Keywords:** Run keyword research using RESEARCH_SUMMARY → save `keywords/KEYWORDS-YYYY-MM-DD.md`
**3b — SEO Plan:** Create implementation plan (on-page changes) → save `implementation/SEO-PLAN-YYYY-MM-DD.md`
**3c — Blog Plan:** Create 3-post plan — MUST NOT overlap with SEO plan tasks — save `blog-plans/BLOG-PLAN-YYYY-MM-DD.md`

### Phase 4 — Content Creation
**4a — Write 3 blogs:** For each post in BLOG-PLAN:
  - Check if `context/tone-guide.md` exists — if so, read and apply
  - Check if `context/personal-info.md` exists — supplement tone
  - Write full SEO-optimised HTML post
  - Save to `blogs/{post-slug}.html`

### Approval Gate ⏸
Present summary table:
- Top 5 SEO on-page changes proposed (with before/after values)
- 3 blog posts ready to publish
- Platform: {Shopline/Webflow}
"Approve to post blogs and execute on-page changes?"

### Phase 5 — Execution (after approval)
**5a — Detect platform:** Read `CLAUDE.md` → CMS field → route to Shopline or Webflow logic
**5b — Post blogs to CMS:**
  - Shopline: POST to `/store/blogs/{id}/articles.json` with `{"blog": {...}}`
  - Webflow: Create CMS collection item via MCP (draft, then publish)
**5c — On-page changes:**
  - Shopline: MetafieldsSet API for blog + product SEO titles/descriptions
  - Webflow: Update `seo.title`, `seo.description` via Data API + MCP

### Phase 6 — Monthly Report
Comprehensive end-of-month report:
- SEO score: before → after
- On-page changes executed (table: page, field, before, after)
- Blogs published (titles, slugs, target keywords)
- GSC/GA4 baseline for next month's comparison
- Resolved items (✅) vs outstanding priorities
- Recommendations for next month's cycle
- Save to `audit/POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.md`

---

## Platform-Switching Logic

```
Read CLAUDE.md → Platform field
  "Shopline" → use Shopline Admin REST API for all execution
  "Webflow"  → check MCP is connected → use Webflow Data API + MCP
  Other      → note platform not yet supported, stop at Phase 4
```

---

## What Does NOT Change

- Existing `seo-blog-implement` skill (kept as-is — different use case)
- Existing orchestrators (kept — they remain useful for targeted runs)
- Any client output files, context files, credentials

---

## Awaiting Approval

Present this plan summary and wait for explicit approval before creating any files.
