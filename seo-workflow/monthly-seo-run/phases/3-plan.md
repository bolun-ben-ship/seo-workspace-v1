# Phase 3 — Planning (Keywords → SEO Plan → Blog Plan)

Run 3a first, then 3b and 3c can run in parallel since they draw from different inputs.

---

## Phase 3a — Keyword Research

**Goal:** Identify the specific keyword targets for this month's content and on-page work.

**Inputs:** Load `RESEARCH_SUMMARY` from Phase 2 + `HISTORICAL_CONTEXT.prior_keywords`

**Generate four keyword tables:**

1. **Primary target keywords** — high-intent, achievable (not already ranking top 3)
   - Prioritise keywords appearing in GSC with impressions but position 4–20
   - These are "almost there" — small optimisations can move the needle

2. **Long-tail transactional keywords** — buying intent, specific product/service queries

3. **Long-tail informational keywords** — questions and how-to terms, blog targets

4. **People Also Ask + AI search queries** — "how does X work", "what is the best X for Y"

**Rules:**
- Do NOT repeat keywords already in `HISTORICAL_CONTEXT.prior_keywords` that are performing well
- DO include keywords from last30days social research that map to real search volume
- Identify 3–5 competitor keyword gaps worth targeting this month

```bash
mkdir -p "Content & SEO/outputs/{platform}-{handle}/keywords"
```

Save to: `Content & SEO/outputs/{platform}-{handle}/keywords/KEYWORDS-YYYY-MM-DD.md`

Confirm save, then proceed to 3b and 3c in parallel.

---

## Phase 3b — SEO Plan (On-Page Changes)

**Goal:** Build a prioritised list of on-page changes to execute in Phase 5.
This plan covers everything the API CAN change: titles, meta descriptions, schema.

**Inputs:** Load `RESEARCH_SUMMARY` + `HISTORICAL_CONTEXT` + `KEYWORDS-YYYY-MM-DD.md`

**Prioritisation order:**
1. CTR gap pages — ranking ≤10 but CTR <3% → title/meta fix → highest ROI
2. Pages with no SEO title set → fill in
3. Pages with generic/short titles → improve with keyword targeting
4. Schema gaps on high-traffic pages → add FAQ, Article, Product schema
5. `OUTSTANDING_PRIORITIES` from last month carried forward

**Format — every change must have:**

| Page/Item | Field | Current Value | Proposed Value | Reason |
|---|---|---|---|---|
| /mattress-guide | SEO Title | "Mattress Guide" | "Best Mattress for Back Pain Singapore 2026 — Owllight" | CTR gap: 2.1% at position 4 |

**Rules:**
- NEVER include anything from `HISTORICAL_CONTEXT.RESOLVED_ITEMS`
- DO flag regressions as `[REGRESSION]` — these get highest priority
- Limit to changes that CAN be executed via API (see platform constraints in SKILL.md)
- Target 10–25 changes per month — enough to move the needle, not so many it's noisy

```bash
mkdir -p "Content & SEO/outputs/{platform}-{handle}/implementation"
```

Save to: `Content & SEO/outputs/{platform}-{handle}/implementation/SEO-PLAN-YYYY-MM-DD.md`

---

## Phase 3c — Blog Plan

**Goal:** Plan exactly 3 blog posts. These MUST NOT overlap with the SEO plan.

**The distinction:**
- SEO Plan (Phase 3b) = fixing existing pages
- Blog Plan (Phase 3c) = creating new content

**Inputs:** Load `KEYWORDS-YYYY-MM-DD.md` + `RESEARCH_SUMMARY` + `HISTORICAL_CONTEXT.prior_blog_topics`

**For each of the 3 posts, define:**
- **Title** — SEO-optimised, audience-first
- **Target keyword cluster** — primary + 2–3 secondary keywords from KEYWORDS file
- **Content angle** — what makes this post different from what already exists (information gain)
- **Template type** — how-to guide / comparison / FAQ / case study / listicle
- **Word count** — 800–2,500 depending on topic complexity
- **Source of this topic** — from last30days (social demand), GSC (search gap), or keyword research

**Rules:**
- NEVER repeat any topic in `HISTORICAL_CONTEXT.prior_blog_topics`
- Space posts at least 7 days apart in the suggested publish schedule
- Mix informational and transactional intent across the 3 posts
- At least one post should target a question surfaced in last30days research
- Topics must NOT duplicate what the SEO plan is optimising (different pages, different angles)

```bash
mkdir -p "Content & SEO/outputs/{platform}-{handle}/blog-plans"
```

Save to: `Content & SEO/outputs/{platform}-{handle}/blog-plans/BLOG-PLAN-YYYY-MM-DD.md`

Confirm all three saves, then proceed to Phase 4.
