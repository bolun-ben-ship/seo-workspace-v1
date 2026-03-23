# Phase 1 — SEO Audit

Run a comprehensive SEO audit using the seo-and-blog skill bundle.

## Goal

Produce a scored, prioritised audit report covering all 7 SEO categories. This report
becomes the source of truth for what needs to change in Phase 3.

## Steps

### 1. Read the seo-and-blog routing table
Read `seo-and-blog/SKILL.md` to understand which sub-skills are available and their output paths.

### 2. Check for an existing audit
Before running, check if `Content & SEO/outputs/<domain>/audit/` contains any file
matching `AUDIT-YYYY-MM-DD.md` generated within the last 30 days.
Sort by date in filename descending — use the most recent match.

- If a recent audit exists: load it into context and skip to Phase 2. Tell the user:
  "I found a recent audit from [date] — using that as the baseline."
- If no audit exists or it's older than 30 days: run a fresh audit.

### 3. Run the audit

Follow the seo-audit sub-skill instructions. At minimum, cover:

| Sub-skill | What it covers |
|---|---|
| `seo-technical` | Crawlability, indexation, redirects, robots.txt, canonicals |
| `seo-content` | E-E-A-T, thin content, blog alignment, readability |
| `seo-schema` | Existing schema, missing schema, rich result eligibility |
| `seo-geo` | AI search readiness, citability signals |
| `seo-images` | Alt text gaps, format issues |
| `seo-sitemap` | Sitemap presence and quality |

### 4. Score and save

Generate the full audit report with:
- Overall SEO Health Score (0–100) using the standard 7-category weighted scorecard
- Top 5 critical issues
- Top 5 quick wins
- Detailed findings per category

Run `mkdir -p` for the `audit/` subfolder before saving.
Save to: `Content & SEO/outputs/<domain>/audit/AUDIT-YYYY-MM-DD.md`
(e.g. `AUDIT-2026-03-20.md` — always use today's date, never overwrite prior audits)

### 5. Output for Phase 2

Before moving on, summarise in context:
- The overall score
- The 3–5 most impactful changes that can be made via the Webflow API
- Any critical noindex issues (indexed pages that shouldn't be)
- Schema gaps (missing Organization, FAQ, Article schema)

---

## Scoring Weights

| Category | Weight |
|---|---|
| Technical SEO | 25% |
| Content Quality | 25% |
| On-Page SEO | 20% |
| Schema / Structured Data | 10% |
| Performance (CWV) | 10% |
| Images | 5% |
| AI Search Readiness | 5% |
