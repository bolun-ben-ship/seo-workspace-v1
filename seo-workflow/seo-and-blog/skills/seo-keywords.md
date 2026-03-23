---
name: seo-keywords
description: >
  Keyword research and gap analysis for any website. Generates four structured
  keyword tables: primary targets, long-tail (transactional + informational),
  People Also Ask questions, and AI search (GEO) queries. Analyzes competitor
  keyword gaps and outputs to KEYWORD-RESEARCH.md. Use when user says "keyword
  research", "keyword gap", "keywords", "what keywords", "PAA", "long-tail
  keywords", or "AI search queries".
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - WebFetch
  - WebSearch
---

# SEO Keywords — Keyword Research & Gap Analysis

## Process

### Step 0: Load Existing Outputs

Check for prior work — do NOT re-derive what already exists:

- `Content & SEO/outputs/<domain>/audit/` — load most recent `AUDIT-YYYY-MM-DD.md` or `POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.md`
  - Extract: detected business type, thin content pages, on-page SEO findings, current keyword usage, content gaps
- `Content & SEO/outputs/<domain>/implementation/` — load most recent `SEO-PLAN-YYYY-MM-DD.md`
  - Extract: target audience, competitor list, content pillars, keyword gaps already identified
- `Content & SEO/outputs/<domain>/research/` — load most recent `GSC-REPORT-YYYY-MM-DD.md` or `PERFORMANCE-REPORT-YYYY-MM-DD.md`
  - Extract: queries with impressions but low CTR — these are seed keywords to prioritise

If no audit exists, proceed without it but note the gap and recommend running `/seo audit <url>` afterward.

### Step 1: Analyze the Website

Use `scripts/seo/fetch_page.py` to fetch the homepage and up to 10 key pages (services, products, about, blog).

Extract:
- Current page titles, H1s, meta descriptions — what keywords the site already targets
- Content themes and topic clusters present
- Business type (cross-check or detect): SaaS / local / ecommerce / publisher / agency
- Missing topic areas obvious from the site's own positioning
- Internal link anchor text patterns

### Step 2: Competitor Research

Identify top 5 competitors (use audit output if available; otherwise infer from industry + location signals).

For each competitor, fetch their homepage and key pages. Extract:
- Keywords they prominently target (titles, H1s, headings)
- Topic clusters they cover that the subject site does not
- Content types present (blog, FAQs, case studies, location pages)
- Schema types implemented
- AI-citability signals (structured Q&A, definitions, statistics)

Build a **gap map**: topics/keywords competitors rank for that the subject site does not cover.

### Step 3: Keyword Generation

Using the website analysis + competitor gap map, generate keywords across all four categories below. Use WebSearch to validate current search trends and verify estimated volumes.

**Search intent classification:**
- `[T]` Transactional — user ready to buy / sign up / contact
- `[I]` Informational — user researching, learning
- `[N]` Navigational — branded / direct

**Volume estimation tiers** (use when live data unavailable):
| Tier | Monthly Searches |
|------|-----------------|
| High | 10,000+ |
| Medium | 1,000–9,999 |
| Low | 100–999 |
| Niche | <100 |

See `references/keyword-methodology.md` for intent signals, difficulty estimation, and AI keyword patterns.

### Step 4: Build the Four Keyword Tables

Deduplicate across all four tables before finalizing — no keyword should appear in more than one table.

Rank each table by **Priority Score** = combination of:
1. Search volume (higher = better)
2. Keyword difficulty (lower = better opportunity)
3. Strategic fit (aligns with business goals or fills a clear gap)
4. Competitive advantage (underserved by competitors)

#### Table 1: Primary Keyword Targets

Broad-to-mid keyword targets the site should pursue as core pages or content pillars.

| Priority | Keyword | Intent | Est. Volume | Difficulty | Rationale | Why It Will Work |
|----------|---------|--------|-------------|------------|-----------|-----------------|
| 1 | ... | [T/I/N] | High/Med/Low | High/Med/Low | Gap vs competitors / missing from site / differentiator | ... |

**Rationale column must include one of:**
- "Competitor gap" — top competitors rank for this, subject site does not
- "Missing from site" — clearly relevant to the business but absent from current content
- "Differentiator" — unique angle the site has that competitors don't exploit
- "High intent, low competition" — volume opportunity with weak incumbent results

#### Table 2: Long-Tail Keywords

Specific, lower-volume, higher-conversion-rate phrases. Split into two sections.

**Transactional (buy / hire / book / sign up intent):**

| Priority | Keyword | Est. Volume | Difficulty | Rationale |
|----------|---------|-------------|------------|-----------|

**Informational (learn / how / what / why intent):**

| Priority | Keyword | Est. Volume | Difficulty | Rationale |
|----------|---------|-------------|------------|-----------|

#### Table 3: People Also Ask (PAA) Questions

Questions that appear in Google's PAA boxes for the site's primary topic area. These drive featured snippets and answer-box placements.

| Priority | Question | Parent Topic | Est. PAA Frequency | Content Format to Target |
|----------|----------|-------------|-------------------|--------------------------|
| 1 | "How do I...?" | [topic] | High/Med/Low | Definition / Step-by-step / Comparison |

Content format guidance:
- **Definition** — 40-60 word direct answer paragraph
- **Step-by-step** — numbered list, 3-7 steps
- **Comparison** — pros/cons table or side-by-side
- **List** — bullet list of items/options

#### Table 4: AI Search (GEO) Keywords

Queries optimized for AI Overview inclusion, ChatGPT web search, and Perplexity citations. These differ from traditional keywords — they are question-first, entity-dense, and favor structured factual content.

| Priority | Query Phrase | AI Platform Target | Query Type | Citability Strategy |
|----------|-------------|-------------------|------------|---------------------|
| 1 | "What is the best...?" | AI Overviews / Perplexity / ChatGPT | Comparison / Definition / How-to | Add FAQ schema / Add statistics / Use definition format |

Query types:
- **Comparison** — "X vs Y", "best X for Y" — target with structured comparison content
- **Definition** — "What is X" — target with clear, quotable definitions
- **How-to** — "How to X" — target with step-by-step structured content
- **Recommendation** — "Best X" — target with ranked lists and supporting evidence

### Step 5: Output

Before saving, create the output subfolder:
```bash
mkdir -p "Content & SEO/outputs/<domain>/keywords"
```

Save to `Content & SEO/outputs/<domain>/keywords/KEYWORDS-YYYY-MM-DD.md` (use today's date).
Never overwrite prior files — always use today's date in the filename.

## Output Structure

```
Content & SEO/outputs/<domain>/keywords/KEYWORDS-YYYY-MM-DD.md
```

### Report Sections

1. **Executive Summary** — business type, total keywords identified, top 3 opportunities, sources used (audit / plan / live analysis)
2. **Competitive Landscape** — brief summary of competitor keyword strategies and the most significant gaps found
3. **Table 1: Primary Keyword Targets** — core pages and pillars to build or optimize
4. **Table 2: Long-Tail Keywords** — transactional and informational split
5. **Table 3: People Also Ask** — question targets for featured snippets
6. **Table 4: AI Search Keywords** — GEO-optimized query targets
7. **Implementation Notes** — which keywords map to existing pages (optimize) vs. need new pages (create), and quick-win recommendations

## Quality Rules

- Tables must be deduplicated across all four — scan for overlap before finalizing
- Every keyword in Table 1 must have a filled Rationale and "Why It Will Work" column
- Minimum keyword counts: Table 1 = 15+, Table 2 = 20+ (10 per type), Table 3 = 10+, Table 4 = 10+
- Do not include branded competitor keywords (e.g., "[CompetitorName] alternative" belongs in seo-competitor-pages, not here)
- Volume estimates must use the tier system if live data is unavailable — never leave blank
- AI keywords (Table 4) must be phrased as natural language queries, not keyword fragments

## Reference

See `references/keyword-methodology.md` for:
- Detailed search intent classification signals
- Keyword difficulty estimation methodology
- AI search query pattern library
- Volume estimation cross-reference guide
