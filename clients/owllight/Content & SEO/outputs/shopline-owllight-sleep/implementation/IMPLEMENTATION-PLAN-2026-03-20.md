# Implementation Plan — Owllight Sleep
**Date:** 2026-03-20
**Based on:** Audit (37/100), Shopline Snapshot, GA4/GSC Report (Feb 18 – Mar 19 2026)
**Horizon:** 8 weeks (March – May 2026)

---

## Context & Situation

Owllight Sleep is an ad-dependent store (72% paid, 9.4% organic) with strong product differentiation but almost zero organic search presence. The audit found 46 issues; the Shopline snapshot confirmed that **0 of 11 products and 0 of 8 blog posts have individual SEO titles or descriptions** — every page shows Google the same store-default meta tags.

This plan is structured by execution type:
- **API** — changes we can push directly via the Shopline API (no developer required)
- **Theme** — changes requiring Shopline theme editor access (developer or admin)
- **Content** — copywriting tasks (agency)

---

## Priority Logic

Three data sources cross-referenced to set priority order:

1. **Risk of active harm** — priceValidUntil expires in 7 days → product rich results die sitewide
2. **GSC impression volume** — pages with high impressions but low CTR/position are the fastest organic wins
3. **GA4 conversion data** — the pillow page converts best (5 conversions) but sits at pos 11.7 in GSC — top priority to push to page 1

---

## Week 1 — Stop the Bleeding (API + Urgent Manual)

### 1A. Fix priceValidUntil — URGENT (before 2026-03-27)
**Type:** Theme / Developer
**Impact:** Prevents simultaneous loss of Product rich results across all product pages
**Action:** Update `priceValidUntil` in all product schema blocks from `2026-03-27` to `2027-03-20`. Make it a rolling 12-month date going forward.

### 1B. Write and push individual meta titles + descriptions for all 8 blog posts
**Type:** API-executable
**Impact:** Currently every blog post shows Google the same title ("Mattress Promotion Singapore | Owllight Back Care Mattresses") and same meta description. This suppresses click-through for all blog pages.

Prioritised by GSC impression volume:

| Blog Post | GSC Impressions | Target Keywords | Proposed Title (≤60 chars) | Proposed Meta Desc (140–155 chars) |
|---|---|---|---|---|
| Woosa Mattress vs Owllight | 973 | woosa mattress review, woosa reviews | Woosa Mattress Review — vs Owllight Tulip \| Singapore | Independent comparison of Woosa vs Owllight Tulip Hybrid Mattress. Back care, cooling, firmness, price, and 100-night trials compared for Singapore buyers. |
| Sealy vs Simmons at Owllight | 904 | sealy vs simmons, simmons vs sealy | Sealy vs Simmons vs Owllight: Singapore Comparison | How does Owllight stack up against Sealy and Simmons? Back care support, cooling technology, pricing, and trial periods compared for Singapore shoppers. |
| King Koil vs Owllight | ~200 est. | king koil mattress singapore | King Koil vs Owllight Mattress: Singapore 2026 Review | Cooling technology, back care, firmness, and price compared. Find out how King Koil and Owllight Tulip differ for Singapore sleepers with back pain. |
| Sealy vs Owllight | ~200 est. | sealy posturepedic singapore | Sealy Posturepedic vs Owllight: Singapore 2026 Review | Sealy Posturepedic vs Owllight Tulip Hybrid — back care support, foam certifications, customizable firmness, and price compared for Singapore. |
| Hybrid Mattress Dubai Exhibition | ~100 est. | owllight mattress brand | Owllight at Dubai: Hybrid Mattress Brand Goes Global | Owllight Sleep showcases its back care hybrid mattress range at Dubai. CertiPUR-US certified foam, cooling gel layers, and customizable firmness. |
| Lumbar Support Founder Story | ~100 est. | lumbar support mattress singapore | How Owllight's Founder Beat Back Pain with Better Sleep | The founder's personal journey overcoming chronic back pain drove Owllight to build Singapore's most back-focused mattress — the Tulip Hybrid. |
| Toddler Mattress at Owllight | ~50 est. | toddler mattress singapore | Toddler Mattress Singapore: Family Sleep at Owllight | Safe, supportive sleep for toddlers and growing kids. Discover Owllight's family-friendly mattress options for healthy spinal development in Singapore. |

### 1C. Write and push individual meta titles + descriptions for all 10 active products
**Type:** API-executable
**Impact:** 0/10 products have individual meta tags. All showing the same promotional store default in Google.

| Product | GSC Impressions | Target Keywords | Proposed Title (≤60 chars) | Proposed Meta Desc (140–155 chars) |
|---|---|---|---|---|
| 4D Air Light Flow Mattress Topper | 1,211 | mattress topper singapore, firm mattress topper singapore | 4D Air Flow Mattress Topper Singapore \| Owllight | Upgrade your sleep with Owllight's 4D Air Light Flow Topper. Firm support for back care, breathable cooling foam, CertiPUR-US certified. Singapore delivery. |
| Pillow for Neck Pain (Butterfly) | 430 | butterfly pillow singapore, pillow for neck pain | Butterfly Pillow for Neck Pain Singapore \| Owllight | Designed for neck pain relief — Owllight's Butterfly Pillow cradles cervical alignment for side and back sleepers. Free delivery in Singapore. |
| Custom Mattress Singapore | 630 | customised mattress singapore, custom mattress | Custom Mattress Singapore \| Owllight Sleep | Build your own mattress — choose size, thickness, and firmness levels. Owllight's custom mattresses are CertiPUR-US certified with 10-year warranty. |
| Tulip Hybrid Mattress | 272 | cooling back care mattress singapore | Tulip Hybrid Mattress: Cooling Back Care \| Owllight | Singapore's back care hybrid mattress. 5-zone spine support, cooling gel foam, CertiPUR-US certified, 100-night trial, 10-year warranty. Free delivery. |
| 3D Back Care Mattress Topper | ~150 est. | back care mattress topper singapore, firm topper | 3D Back Care Mattress Topper Singapore \| Owllight | Extra firm support for chronic back pain. Owllight's 3D Back Care Topper improves spinal alignment. CertiPUR-US certified. Singapore delivery. |
| Mattress Warehouse Clearance Sale | ~100 est. | mattress sale singapore, mattress warehouse sale | Mattress Warehouse Sale Singapore \| Owllight Sleep | Up to 60% off Owllight mattresses and toppers. Back care hybrid mattresses, cooling toppers, and pillows at clearance prices. Limited stock Singapore. |
| Bedding Sets 2000TC Tencel | ~50 est. | tencel bedding singapore, luxury bedding singapore | Tencel Lyocell Bedding Sets 2000TC Singapore \| Owllight | Ultra-soft 2000 thread count Tencel Lyocell bedding for Singapore's humid climate. Temperature-regulating, hypoallergenic, and hotel-quality comfort. |
| Bedding Sets 1600TC Tencel | ~50 est. | tencel sheets singapore | Tencel Lyocell Bedding Sets 1600TC Singapore \| Owllight | Premium 1600 thread count Tencel Lyocell sheets and pillowcases. Cool, breathable, and sustainably sourced — perfect for Singapore's warm nights. |

---

## Week 2 — Technical Foundation (Theme Fixes)

All items below require access to the Shopline theme editor or the store admin.

### 2A. Fix empty H1 on homepage
**Type:** Theme editor
**Impact:** Critical — homepage sends zero heading signal to Google
**Action:** Add a text H1 to the homepage hero section. Suggested: `"Back Care Mattresses & Sleep Products in Singapore"`

### 2B. Remove duplicate H1 on all product and blog pages
**Type:** Theme editor (single template fix affects all pages)
**Impact:** 8 pages currently have 2 H1s — likely the product/article title is rendered twice in the theme
**Action:** Find the theme template file(s) rendering `{{ product.title }}` or `{{ article.title }}` and remove the duplicate call

### 2C. Add H1 to 5 pages that have none
**Type:** Theme editor / page editor
**Pages:** Showroom, Custom Mattress, Contact/Delivery, Customized Policy, Queen Size Comparisons
**Action:** Add descriptive H1 to each page in the theme or page editor

### 2D. Remove `user-scalable=no` from global viewport meta
**Type:** Theme editor (global `<head>`)
**Impact:** Accessibility violation; Google mobile usability flag
**Action:** Change to `width=device-width, initial-scale=1.0, maximum-scale=5.0`

### 2E. Fix Organization schema `sameAs` — 13 empty strings
**Type:** Theme editor (global schema inject)
**Impact:** Malformed schema on every page — undermines Google's trust in all structured data
**Action:** Either remove the empty array entries or populate with real social URLs (Facebook, Instagram, TikTok, etc.)

### 2F. Remove duplicate Product schema blocks
**Type:** Theme editor (product template)
**Impact:** Every product page renders the JSON-LD block twice
**Action:** Find and remove the duplicate `<script type="application/ld+json">` inclusion in the product template

---

## Week 3 — Schema & Structured Data

### 3A. Fix JSON-LD parse errors on all 6 blog article pages
**Type:** Theme editor (blog article template)
**Impact:** Zero rich result eligibility on all blog pages. Woosa (973 impressions) and Sealy/Simmons (904 impressions) blog posts are generating real GSC traffic but zero schema value.
**Action:** Validate each blog post in Google's Rich Results Test. Fix syntax errors (common causes: unescaped quotes, trailing commas, bad `@context`). Once fixed, add valid `author` and `datePublished` fields.

### 3B. Add FAQPage schema to homepage
**Type:** Theme editor or Shopline metafield injection
**Impact:** 5 Q&As already exist on the homepage — wrapping in FAQPage schema can 3–5× SERP real estate
**Action:** Implement FAQPage JSON-LD block with all 5 existing Q&As

### 3C. Add LocalBusiness schema to showroom page
**Type:** Theme editor or page editor
**Impact:** Showroom page has 416 GSC impressions and a conversion in GA4 — Local schema enables Google Maps eligibility
**Action:** Add LocalBusiness JSON-LD with full address (22 Sin Ming Lane, Singapore), opening hours, phone, geo coordinates, and `sameAs` links to Google Business Profile

---

## Week 4 — On-Page Copy Fixes

All content tasks — no developer required.

### 4A. Shorten over-length title tags (manual, where API meta not set)
Pages requiring manual fix in theme/admin:
- Homepage: 83 chars → target ≤60
- Tulip Mattress: 97 chars → covered by 1C above
- 3D Back Care Topper: 96 chars → covered by 1C above
**Action:** Shorten store name suffix from `– Owllight-sleep` to `– Owllight` sitewide (single theme change)

### 4B. Fix title/content mismatches on 2 blog posts
| Post | Issue | Fix |
|---|---|---|
| Dubai Exhibition | Title says "Launch in Singapore" — content is about Dubai | Update title to "Owllight at the Dubai Exhibition 2025" |
| Simmons comparison | Title/URL says "sealy-vs-simmons" — content compares Simmons vs Owllight | Update title and meta to accurately reflect Simmons vs Owllight content |

### 4C. Fix duplicate H2 numbering in Simmons and Woosa blog posts
**Action:** Review heading structure in both posts — duplicate "2. Pricing" and "3. Sleep Trials" headings need to be renumbered or restructured

### 4D. Fix the `"the the"` typo in toddler mattress meta description
**Type:** API-executable (part of 1B above if meta is being set)

### 4E. Fix meta description for Warehouse Sale product
Currently 4 words. A proper description is being written as part of 1C above.

### 4F. Add meta description for Shipping Policy page (currently missing entirely)
**Action:** Write a 140–155 char meta description for `/policies/shipping-policy`

---

## Week 5-6 — Alt Text & Images

This is the most time-intensive task but has high cumulative impact (images score 12/100).

### 5A. Homepage — 30 images, 0% alt coverage (Priority 1)
Write descriptive alt text for all 30 images. Focus on: hero product shots, certification badges (CertiPUR-US), feature diagrams, lifestyle shots.

### 5B. Custom Mattress page — 27 images, 0% alt coverage (Priority 2)

### 5C. Showroom page — 7 images, 0% alt coverage (Priority 3)

### 5D. Product pages — prioritised by impression volume
1. 4D Topper: 89 images, 29% coverage → write alt for 63 missing (highest GSC impressions)
2. Pillow for neck pain: audit coverage (best converting page in GA4)
3. Tulip Mattress: 74 images, 27% coverage → write alt for 54 missing
4. Bedding 2000TC: 93 images, 39% coverage → write alt for 57 missing
5. 3D Back Care Topper: 76 images, 37% coverage → write alt for 48 missing

**Alt text format:**
- Product shot: `"Owllight Tulip Hybrid Mattress Queen Size — CertiPUR-US certified back care support"`
- Certification badge: `"CertiPUR-US certified foam certification badge"`
- Layer diagram: `"Tulip mattress 5-zone pro spine support foam layer cross-section diagram"`
- Lifestyle: `"Owllight Tulip mattress in a modern Singapore bedroom"`

---

## Week 6-7 — URL & Crawl Issues

### 6A. Fix the `100-nighs` URL typo
**Type:** Developer (redirect + new page)
1. Create `/pages/mattress-trial-singapore-100-nights` (corrected URL)
2. Set up 301 redirect from `/pages/mattress-trial-singapore-100-nighs` → corrected URL
3. Update sitemap to reference corrected URL
4. Update any internal links pointing to the typo URL

### 6B. Implement hreflang for Arabic locale variants
**Type:** Developer (theme `<head>` template)
**Impact:** Arabic pages (`/ar-ar/`, `/en-ar/`) are in the sitemap but have no hreflang tags — Google treats them as duplicate content
**Action:** Add `<link rel="alternate">` hreflang tags for `en-sg`, `ar-ae` (or the actual target market), and `x-default` to all page templates

### 6C. Fix canonical trailing-slash inconsistency on homepage
**Type:** Theme editor
**Action:** Align homepage canonical tag with the actual served URL format (add trailing slash or remove consistently)

### 6D. Resolve orphan products in sitemap
**Products:** `/products/11`, `/products/cloud-wrap`, `/products/mattress-180-*`
**Action:** Either (a) add these to a relevant collection/navigation to build internal links, or (b) remove them from the sitemap if they are discontinued

---

## Week 7-8 — Content Expansion

### 7A. Custom Mattress page — expand from ~133 words to 500+ words
**GSC:** 630 impressions, pos 17.6 — needs content depth to move to page 1
**Angles to cover:** What customization options exist (size, thickness, firmness), use cases (couples with different firmness preferences, medical requirements, unusual room dimensions), process (how to order), turnaround time, warranty coverage

### 7B. Collection pages — add 300–500 words to each of the 5 collection pages
**Current state:** <200 words each, duplicate meta descriptions
**Action:** Write category introductions covering: what the category includes, buying criteria, how Owllight's products differ, key specs to consider (firmness for back care, certifications, trial periods)

**Collections to prioritise:**
1. `/collections` (main) — 595 GA4 sessions, 24 GSC clicks
2. `/collections/mattress-topper-singapore` (if exists)
3. `/collections/bed-set-singapore-owllight` — 35 GSC impressions, pos 17.3

### 7C. Expand thin product pages
1. **Bedding 1600TC** (~180 words) → 400+ words: materials, thread count explained, temperature regulation, care instructions
2. **Bedding 2000TC** (~184 words) → 400+ words: same as above
3. **Butterfly Pillow** (~222 words) → 400+ words: butterfly/cervical pillow mechanics, neck pain relief, who it's for

### 7D. Upgrade token scope for static pages
**Current state:** Token has `read_content`/`write_content` but not `read_page`/`write_page` — the showroom, custom mattress, trial, and contact pages cannot be accessed via API
**Action:** Add `read_page` and `write_page` scopes to the `SHOPLINE_OWLLIGHT_TOKEN` in Shopline app settings

---

## Backlog (Post Week 8)

| Task | Why It Matters |
|---|---|
| Create dedicated `/about` page (currently 301s to homepage) | Brand entity building for AI search and Knowledge Panel |
| Create dedicated `/faq` page (currently 301s to homepage) | Ranks for FAQ queries; canonical target for FAQ schema |
| Implement review collection strategy for Tulip product (2 reviews only) | AggregateRating schema signal |
| Populate social media profiles + update sameAs in Organization schema | Brand entity completeness |
| Audit robots.txt to permit AI crawlers (GPTBot, PerplexityBot, ClaudeBot) | AI search citation eligibility |
| Update BreadcrumbList on product pages to include collection level | Structured data completeness |
| Build "Best Mattress Singapore" hub page linking to all comparison posts | Content cluster for high-intent category queries |
| Review PageSpeed / Core Web Vitals on pages with 80–93 images | LCP and TBT risk on product pages |

---

## Execution Summary by Type

| Type | Tasks | Who | Effort Est. |
|---|---|---|---|
| **API-executable now** | Blog meta tags (8 posts), Product meta tags (10 products) | RightClick / Claude | 2–3 hrs |
| **Theme editor** | Empty H1, duplicate H1 fix, viewport meta, sameAs fix, duplicate schema, FAQPage schema, LocalBusiness schema | Developer | 4–6 hrs |
| **Content writing** | Alt text (400+ images), thin page expansion, collection copy, title/meta corrections | RightClick / Content | 12–18 hrs |
| **Developer + redirect** | URL typo fix, hreflang, canonical fix, orphan products | Developer | 4–6 hrs |

**Total estimated effort: 22–33 hours over 8 weeks**

---

## Quick Wins — Do This First (Week 1)

In order of impact-to-effort:

1. ✅ Push individual meta titles and descriptions to all 8 blog posts via API
2. ✅ Push individual meta titles and descriptions to all 10 products via API
3. ⚠️ Update `priceValidUntil` to 2027-03-20 before 2026-03-27 (7 days)
4. Fix empty H1 on homepage (15 minutes in theme editor)
5. Remove 13 empty strings from Organization `sameAs` (15 minutes)

Items 1 and 2 alone will fix the single biggest issue identified in the Shopline snapshot (0% individual SEO coverage) and directly address the 6,222 GSC impressions that are currently converting at only 2.1% CTR.

---

## GSC Targets (6 Months — September 2026)

| Page | Current Position | Target Position | Rationale |
|---|---|---|---|
| /products/mattress-topper-singapore-4d | 12.9 | ≤7 | 1,211 impressions — highest volume page off page 1 |
| /blogs/…/woosa-mattress-review | 7.7 | ≤5 | 973 impressions, valid schema will help |
| /blogs/…/sealy-vs-simmons | 7.1 | ≤5 | 904 impressions, fix meta + schema |
| /products/pillow-for-neck-pain | 11.7 | ≤5 | Best GA4 converter, 430 impressions |
| /pages/custom-mattress-singapore | 17.6 | ≤10 | 630 impressions, content depth needed |
| /pages/showroom-22-sin-ming-lane | 6.9 | ≤4 | 416 impressions, LocalBusiness schema + meta |

Achieving top-5 positions on these 6 pages at current impression volumes would increase organic clicks by approximately **3–5× current baseline** (from ~133 clicks/month to ~400–600+), assuming CTR improvements from better meta descriptions compound with position gains.
