# Phase 1 — SEO Audit

**Do not start this phase without completing Phase 0 first.**
Phase 0 sets `HISTORICAL_CONTEXT` and determines whether a fresh audit is needed.
Read that decision before doing anything here.

---

## Step 1 — Check Phase 0's audit decision

Phase 0 produces one of three decisions:

### Decision A: Skip audit — use POST-IMPLEMENTATION-AUDIT as baseline

Condition: `POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.md` exists AND is < 30 days old.

Action:
- Do NOT run a new audit
- Load the post-implementation audit as `ACTIVE_AUDIT`
- Tell the user:
  ```
  Using post-implementation audit from [date] (score: X/100) as baseline.
  Skipping fresh audit — last run was [N] days ago.
  Proceeding to Phase 2a (performance data).
  ```
- Proceed directly to Phase 2a

---

### Decision B: Skip audit — use base AUDIT as baseline

Condition: `AUDIT-YYYY-MM-DD.md` exists AND is < 30 days old, but no POST-IMPLEMENTATION-AUDIT.

Action:
- Do NOT run a new audit
- Load the base audit as `ACTIVE_AUDIT`
- Tell the user:
  ```
  Using audit from [date] (score: X/100) as baseline.
  No implementation has been run yet against this store.
  Proceeding to Phase 2a.
  ```
- Proceed directly to Phase 2a

---

### Decision C: Run a fresh audit

Condition: No audit file exists, OR the most recent audit (any type) is > 30 days old.

Proceed with Steps 2–5 below.

---

## Step 2 — Read the seo-and-blog routing table

Read `seo-and-blog/SKILL.md` to understand which sub-skills are available.

---

## Step 3 — Run the audit

Cover at minimum:

| Sub-skill | What it covers |
|---|---|
| `seo-technical` | Crawlability, indexation, redirects, robots.txt, canonicals |
| `seo-content` | E-E-A-T, thin content, blog alignment, readability |
| `seo-schema` | Existing schema, missing schema, rich result eligibility |
| `seo-geo` | AI search readiness, citability signals |
| `seo-images` | Alt text gaps, format issues |
| `seo-sitemap` | Sitemap presence and quality |

**Cross-reference with HISTORICAL_CONTEXT while auditing:**
- Do not list items already in `RESOLVED_ITEMS` as new findings
- If a resolved item has regressed, flag it explicitly: "⚠️ Regression: [item] was resolved on [date] but has regressed"
- Use `OUTSTANDING_PRIORITIES` from prior reports as a checklist — verify whether each is still outstanding

---

## Step 4 — Score and save

Generate the full audit report:
- Overall SEO Health Score (0–100) using the 7-category weighted scorecard
- Top 5 critical issues (new only — skip anything in `RESOLVED_ITEMS`)
- Top 5 quick wins
- Detailed findings per category
- Section at the bottom: "Carried Forward from Prior Audit" listing still-outstanding items from `OUTSTANDING_PRIORITIES`

Run `mkdir -p` for the `audit/` subfolder before saving.
Save to: `{WORKSPACE_ROOT}/outputs/shopline-{STORE_HANDLE}/audit/AUDIT-YYYY-MM-DD.md`

Set this as `ACTIVE_AUDIT`.

---

## Step 5 — Output for Phase 2

Before moving on, summarise in context:
- The overall score and whether it improved vs last run (if applicable)
- The 3–5 most impactful changes possible via the Shopline API
- Blog post SEO gaps (missing seoTitle / seoDescription metafields)
- Page SEO gaps
- Schema gaps
- Any regressions detected

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
