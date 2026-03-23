# Shopline Store Snapshot — owllight-sleep
Date: 2026-03-20
Store URL: owllight-sleep.myshopline.com → owllight-sleep.com
API Version: v20251201

## Token Scopes Confirmed
- ✅ `read_content` — read blog collections + articles
- ✅ `write_content` — create/update articles + metafields
- ❌ `read_page` / `write_page` — pages endpoint returns error; token needs scope upgrade

---

## Blog Collections (4 total)

| Blog | ID | Articles |
|---|---|---|
| News | `686f553a771a545e09f23934` | 1 |
| Brand Story | `689b052bbdb0ff72d20d2f53` | 2 (1 draft) |
| Mattress Comparisons | `68e8d3d72d9b3812239e99a8` | 4 |
| Owllight Series | `69aff002ec210535546e9a58` | 1 |

---

## Blog Post SEO Coverage (8 articles total)

| Blog | Title | ID | Published | Article seoTitle | Article seoDesc |
|---|---|---|---|---|---|
| News | Hybrid Mattress Brand Owllight Launch in Singapore | `6870cc17bb571a2997e5098d` | ✅ 2025-07-11 | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| Brand Story | Why Mattress Stores Have Warehouse Sales | `68dcf54bba561c4329dd794b` | Draft | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| Brand Story | Lumbar Support Was Not Enough: Owllight's Founder Overcoming Back Pain | `689afdc01edc2472097ba81d` | ✅ 2025-09-23 | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| Mattress Comparisons | Woosa Mattress vs Owllight Tulip Hybrid Mattress | `6912dcb962a9876c32aefdfa` | ✅ 2025-11-17 | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| Mattress Comparisons | Simmons vs Owllight - Back Care, Cooling Mattress, Price and Trials | `69049a2422f3f1740e2601ab` | ✅ 2025-11-06 | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| Mattress Comparisons | King Koil vs Owllight - Cooling Mattress, Price and Trials | `68fa04271ea3ce0d006dede1` | ✅ 2025-10-31 | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| Mattress Comparisons | Sealy vs Owllight - Cooling Mattress, Price and Trials | `68e8d3d72d9b3812239e99a9` | ✅ 2025-10-10 | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| Owllight Series | Toddler Mattress at Owllight: Family-Friendly Support for Healthy Growth | `69afedeace66fe3ff4271cfa` | ✅ 2026-03-10 | ⚠️ Inheriting store default | ⚠️ Inheriting store default |

**SEO Coverage:**
- Articles with article-level seoTitle set: **0 / 8 (0%)**
- Articles with article-level seoDesc set: **0 / 8 (0%)**

**Store-level default SEO (currently showing on ALL 8 posts in Google):**
- seoTitle: `Mattress Promotion Singapore | Owllight Back Care Mattresses`
- seoDesc: `Mattress Promotion Singapore - Get up to 60%OFF. Prioritising Singaporean's Spine & Back Care with an Orthopedic Sleep Experience. Shop now and customize extra firmness with us.`
- seoKeyword: `matress promotion,discount mattress,mattress sale singapore`

⚠️ **Critical**: Google is seeing the same title + description for every blog post. This creates duplicate meta tag issues and means none of the comparison/category pages are ranking with relevant keywords.

---

## Products (11 total — 10 active, 1 draft)

| Title | Handle | Status | seoTitle | seoDesc |
|---|---|---|---|---|
| Mattress Sale Singapore \| Cooling Back Care Hybrid Mattress \| Tulip | mattress-sale-singapore-tulip | active | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| 4D Air Light Flow Mattress Topper Singapore | mattress-topper-singapore-4d | active | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| Pillow for Neck Pain (Butterfly Edition) | pillow-for-neck-pain | active | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| Mattress Warehouse Clearance Sale | mattress-warehouse-sale-singapore | active | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| OWLLIGHT 3D Back care Mattress Topper | extra-firm-mattress-topper | active | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| Medium Firm Mattress Topper | medium-firm-mattress-topper | draft | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| Bedding sets (Tencel Lyocell) Royal 2000TC | bedding-sets-2000 | active | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| Bedding sets (Tencel Lyocell) Grand 1600TC | bedding-sets-1600 | active | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| Owllight Hybrid Mattress (Pocket Spring + Memory Foam) | 11 | active | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| Owllight Medium Firm Hybrid Mattress | long-handle | active | ⚠️ Inheriting store default | ⚠️ Inheriting store default |
| Owllight 25cm Cooling Gel Memory Foam Mattress | cloud-wrap | active | ⚠️ Inheriting store default | ⚠️ Inheriting store default |

**Product SEO Coverage: 0 / 11 (0%)** — all inheriting store default.

---

## Custom Pages
**No custom pages found.** The store uses Shopline theme-level pages (not custom pages via the Pages API).
The Pages API endpoint (`/store/pages.json`) confirms this — returns empty.
Token scopes are confirmed correct (read_page + write_page visible in app settings).
Page-level SEO must be managed via the Shopline theme editor (manual).

---

## Article URL Map

| Title | URL Path |
|---|---|
| Hybrid Mattress Brand Owllight Launch | `/blogs/hybrid-mattress-brand-owllight-news/hybrid-mattress-dubai-exhibition` |
| Why Mattress Stores Have Warehouse Sales (Draft) | `/blogs/lumbar-support-mattress/why-mattress-stores-have-warehouse-sales` |
| Lumbar Support Was Not Enough | `/blogs/lumbar-support-mattress/lumbar-support-mattress` |
| Woosa Mattress vs Owllight | `/blogs/best-mattress-singapore-brands/woosa-mattress-review-owllight` |
| Simmons vs Owllight | `/blogs/best-mattress-singapore-brands/sealy-vs-simmons-at-owllight` |
| King Koil vs Owllight | `/blogs/best-mattress-singapore-brands/king-koil-queen-size-mattress-vs-owllight` |
| Sealy vs Owllight | `/blogs/best-mattress-singapore-brands/sealy-posturepedic-mattress-vs-owllight` |
| Toddler Mattress at Owllight | `/blogs/owllight-series/toddler-mattress-at-owllight-family-friendly-support-for-healthy-growth` |
