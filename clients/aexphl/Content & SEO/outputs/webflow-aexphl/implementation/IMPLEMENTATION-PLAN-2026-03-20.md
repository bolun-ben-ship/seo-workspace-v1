# Implementation Plan — Blog Post CTR Fix
**Date:** 2026-03-20
**Status:** PENDING APPROVAL
**Scope:** 4 blog post meta title + description rewrites via Webflow CMS API

---

## Context

GSC data (last 30 days) shows 4 blog posts collectively generating **~7,800 impressions and ~15 clicks** — an average CTR of 0.19%. All 4 rank on page 1 (positions 2–10). This is entirely a meta title/description problem, not a ranking problem.

Conservative estimate: fixing these to 3% CTR = **~234 clicks/month** from the same impressions. Current = 15 clicks/month. That is a **15x improvement** in organic clicks from copy changes alone.

The POST-IMPLEMENTATION-AUDIT-2026-03-19 did not address these — blog CMS items were explicitly listed as outstanding priority #10.

---

## Changes Proposed

### 1. `/blog/australian-expat-home-loan`
**CMS Item ID:** `66104f746ff4cec5f0bcddee`
**GSC:** Position 2.0 | 3,594 impressions | 11 clicks | 0.3% CTR

| | Current | Proposed |
|---|---|---|
| **meta-title** | Australian Expat Home Loans: 5 Things You Must Know | Australian Expat Home Loans: How to Borrow from Overseas \| AEXPHL |
| **meta-description** | *(auto-pulled from body — not a real description)* | As an Australian expat in Singapore, HK or Dubai, you can still get a home loan in Australia. Deposits, lenders and rates — explained simply. |

**Why:** "5 Things You Must Know" is list-bait that doesn't match searcher intent. At position 2, expected CTR is 15%+. The intent is transactional/informational — people want to know *how*, not a listicle. Adding the geographic specificity (Singapore, HK, Dubai) differentiates from generic bank results.

---

### 2. `/blog/housing-interest-rates-australia`
**CMS Item ID:** `6610502613f26e657abf2667`
**GSC:** Position 8.2 | 2,039 impressions | 2 clicks | 0.1% CTR

| | Current | Proposed |
|---|---|---|
| **meta-title** | Housing Interest Rate in Australia: A Quick Guide - Aussie Expat Home Loans | Australian Interest Rates for Expat Home Loans: 2026 Guide |
| **meta-description** | *(generic body content — not optimised)* | Interest rates for Australian expat home loans explained. What lenders charge overseas borrowers, how to compare, and how to lock in a good rate. |

**Why:** "A Quick Guide" is weak and generic — competing directly with RBA, major banks, and comparison sites on a generic query. Niching to "expat home loans" targets the specific searcher AEXPHL can actually help, improves relevance signal, and differentiates in SERP. Removing brand name from title saves characters for keywords.

---

### 3. `/blog/minimum-house-deposit-australia`
**CMS Item ID:** `6610520150da980371228540`
**GSC:** Position 9.8 | 2,053 impressions | 1 click | 0.05% CTR

| | Current | Proposed |
|---|---|---|
| **meta-title** | How to Prepare the Minimum Deposit for a Home Loan in Australia | Minimum House Deposit in Australia for Expats: 2026 Guide |
| **meta-description** | *(body content repurposed — not a meta description)* | How much deposit do Australian expats need? Most lenders require 20–30%. Here's what expats in Singapore, HK and Dubai need to plan for. |

**Why:** Searchers typing "minimum house deposit australia" want the number — not preparation tips. "How to Prepare" implies an answer that's not what they're looking for, killing CTR. Adding "Expats" and "2026" targets the exact audience and adds freshness signal. This is the lowest CTR on the site (0.05%) — any improvement is a win.

---

### 4. `/blog/australia-home-loan`
**CMS Item ID:** `66104f166305423fcf259fb3`
**GSC:** Position 4.9 | 692 impressions | 1 click | 0.14% CTR

| | Current | Proposed |
|---|---|---|
| **meta-title** | Home Loans Australia: Options, Requirements and Comparisons | Australian Home Loans for Expats: Borrow While Living Overseas \| AEXPHL |
| **meta-description** | Are you looking to purchase a property in Australia? If so, you'll likely need to take out a home loan... | Getting an Australian home loan while living overseas is simpler than you think. AEXPHL specialises in expat lending — check your borrowing capacity today. |

**Why:** Completely generic title competing with CBA, NAB, Canstar. At position 4.9 this should be getting ~5% CTR. Adding "for Expats" narrows to the right audience, filters out non-qualified clicks, and differentiates in SERP. CTA in meta description ("check your borrowing capacity") drives qualified clicks.

---

## What Is NOT Being Changed

- Blog post body content (no changes to article copy)
- Blog post slugs (changing slugs breaks URLs and GSC history)
- Any static pages (already handled in POST-IMPLEMENTATION-AUDIT-2026-03-19)
- Other blog posts not flagged in GSC data

---

## Known Issue — Not in Scope

**HTTP non-www redirect:** `http://www.aexphl.com/` shows 1,637 GSC impressions. This is a server/CDN-level redirect issue (HTTP → HTTPS), not fixable via Webflow CMS API. Recommend raising with Webflow support or checking domain redirect settings in Webflow hosting panel.

---

## Execution Method

- Webflow CMS API via MCP (`update_collection_items` → `publish_collection_items`)
- All changes applied as drafts first, then published in a single batch
- Changes are reversible — previous values documented above

---

## Expected Outcome

| Page | Current CTR | Target CTR | Current Clicks/mo | Expected Clicks/mo |
|---|---|---|---|---|
| australian-expat-home-loan | 0.3% | 3–5% | 11 | 100–180 |
| housing-interest-rates-australia | 0.1% | 2–3% | 2 | 40–60 |
| minimum-house-deposit-australia | 0.05% | 2–3% | 1 | 40–60 |
| australia-home-loan | 0.14% | 3–5% | 1 | 20–35 |
| **Total** | **0.19%** | **~3%** | **15** | **~200–335** |

Results will be measurable in GSC within 2–4 weeks of publishing.
