# Post-Implementation Audit — Blog CTR Fix
**Date:** 2026-03-20
**Status:** COMPLETE
**Approved by:** Tim
**Executed via:** Webflow CMS API (MCP)

---

## What Was Changed

### 1. `/blog/australian-expat-home-loan`
| | Before | After |
|---|---|---|
| **meta-title** | Australian Expat Home Loans: 5 Things You Must Know | Australian Expat Home Loans: How to Borrow from Overseas \| AEXPHL |
| **meta-description** | *(body content — not a real description)* | As an Australian expat in Singapore, HK or Dubai, you can still get a home loan in Australia. Deposits, lenders and rates — explained simply. |
| **GSC baseline** | 3,594 impressions, 11 clicks, 0.3% CTR, pos 2.0 | Measure in 2–4 weeks |

### 2. `/blog/housing-interest-rates-australia`
| | Before | After |
|---|---|---|
| **meta-title** | Housing Interest Rate in Australia: A Quick Guide - Aussie Expat Home Loans | Australian Interest Rates for Expat Home Loans: 2026 Guide |
| **meta-description** | *(generic body content)* | Interest rates for Australian expat home loans explained. What lenders charge overseas borrowers, how to compare, and how to lock in a good rate. |
| **GSC baseline** | 2,039 impressions, 2 clicks, 0.1% CTR, pos 8.2 | Measure in 2–4 weeks |

### 3. `/blog/minimum-house-deposit-australia`
| | Before | After |
|---|---|---|
| **meta-title** | How to Prepare the Minimum Deposit for a Home Loan in Australia | Minimum House Deposit in Australia for Expats: 2026 Guide |
| **meta-description** | *(body content repurposed)* | How much deposit do Australian expats need? Most lenders require 20–30%. Here's what expats in Singapore, HK and Dubai need to plan for. |
| **GSC baseline** | 2,053 impressions, 1 click, 0.05% CTR, pos 9.8 | Measure in 2–4 weeks |

### 4. `/blog/australia-home-loan`
| | Before | After |
|---|---|---|
| **meta-title** | Home Loans Australia: Options, Requirements and Comparisons | Australian Home Loans for Expats: Borrow While Living Overseas \| AEXPHL |
| **meta-description** | Are you looking to purchase a property in Australia? If so... | Getting an Australian home loan while living overseas is simpler than you think. AEXPHL specialises in expat lending — check your borrowing capacity today. |
| **GSC baseline** | 692 impressions, 1 click, 0.14% CTR, pos 4.9 | Measure in 2–4 weeks |

---

## What Was NOT Changed
- Blog post slugs (preserves URL integrity and GSC history)
- Blog post body content
- Static pages (handled in POST-IMPLEMENTATION-AUDIT-2026-03-19)
- All other blog posts

---

## Outstanding Issues
- **HTTP non-www redirect** (`http://www.aexphl.com/` — 1,637 GSC impressions): Needs Webflow hosting panel or DNS-level fix. Out of scope for CMS API.

---

## Expected Impact
| Page | Impressions/mo | Old CTR | Target CTR | Old Clicks | Expected Clicks |
|---|---|---|---|---|---|
| australian-expat-home-loan | 3,594 | 0.3% | 3–5% | 11 | 100–180 |
| housing-interest-rates-australia | 2,039 | 0.1% | 2–3% | 2 | 40–60 |
| minimum-house-deposit-australia | 2,053 | 0.05% | 2–3% | 1 | 40–60 |
| australia-home-loan | 692 | 0.14% | 3–5% | 1 | 20–35 |
| **Total** | **~7,800** | **0.19%** | **~3%** | **15** | **~200–335** |

Check GSC in 2–4 weeks for CTR movement on these 4 URLs.
