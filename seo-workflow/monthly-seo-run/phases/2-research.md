# Phase 2 — Research (run 2a, 2b, 2c in parallel, then synthesise)

**Goal:** Pull live performance data and market signals before building the plan.
All three sub-phases run simultaneously. Synthesise results before Phase 3.

---

## Phase 2a — GSC Report

Read credentials from `CLAUDE.md`:
- `GSC site` → the site URL for GSC queries
- `Credentials env var` → the env var holding the path to the JSON key file

If credentials are missing or env var is not set → skip this sub-phase, note it in the synthesis.

**Pull from Google Search Console (last 30 days):**
- Top queries by impressions — identify what the site is ranking for
- CTR gap opportunities: position ≤10, CTR <3% → these are title/meta fix priorities
- Top pages by clicks — identify best-performing organic content
- Pages with high impressions but low clicks — content/title mismatch candidates

Compare against `HISTORICAL_CONTEXT.organic_baseline` if available.

```bash
mkdir -p "Content & SEO/outputs/{platform}-{handle}/research"
```

Save to: `Content & SEO/outputs/{platform}-{handle}/research/GSC-REPORT-YYYY-MM-DD.md`

---

## Phase 2b — GA4 Report

Read from `CLAUDE.md`:
- `GA4 property ID` → numeric property ID
- `Credentials env var` → same JSON key as GSC

If not configured → skip, note in synthesis.

**Pull from Google Analytics 4 (last 30 days):**
- Sessions by channel (organic, direct, paid, referral) — organic baseline
- Top landing pages by sessions + bounce rate
- Compare organic session count vs `HISTORICAL_CONTEXT.organic_baseline` for month-over-month delta

Save to: `Content & SEO/outputs/{platform}-{handle}/research/GA4-REPORT-YYYY-MM-DD.md`

---

## Phase 2c — Market Research (last30days)

Read `context/client-info.md` — extract the primary niche/topic for this client.
(e.g. "mattress sleep health singapore" for Owllight, "australian expat mortgage singapore" for AEXPHL)

Run `last30days` research for this niche:
- What is the target audience talking about, searching for, sharing right now?
- Emerging questions and pain points not yet covered on the site
- Competitor mentions and trending angles
- Seasonal or timely content opportunities

Save to: `Content & SEO/outputs/{platform}-{handle}/research/SOCIAL-TRENDS-YYYY-MM-DD.md`

---

## Phase 2 Synthesis

After all three complete, build a `RESEARCH_SUMMARY` combining:

**From audit (Phase 1):**
- Current health score + delta vs last month
- Top critical issues
- Quick wins available

**From GSC (Phase 2a):**
- Top CTR gap keywords (high impressions, low CTR) — these become title/meta priorities in Phase 3b
- Top performing pages — protect and build on these
- Keyword opportunities the site is close to ranking for

**From GA4 (Phase 2b):**
- Organic session delta (up/down vs last month)
- Top landing pages — flag any with high bounce rate
- Channel health

**From last30days (Phase 2c):**
- Top audience themes not yet covered → blog opportunities for Phase 3c
- Trending angles that map to existing content → update opportunities for Phase 3b
- Competitor insights

**Synthesise key questions:**
1. Which existing pages have high ranking potential but poor CTR? → title/meta fixes
2. Which topics are people searching for that the site doesn't cover? → new blog targets
3. What has improved vs last month? → celebrate and protect
4. What has regressed? → prioritise in Phase 3b

Confirm all three report saves, then proceed to Phase 3.
