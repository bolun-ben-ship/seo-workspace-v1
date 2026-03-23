# Phase 2b — Shopline Data Fetch

Fetch the current state of all blog collections, articles, and SEO metafields from the
Shopline store via the Admin REST API. This is the "before" snapshot Phase 3 and Phase 6
will reference.

All API calls use:
```
BASE_URL = https://{STORE_HANDLE}.myshopline.com/admin/openapi/v20251201
Headers:  Authorization: Bearer {ACCESS_TOKEN}
          Content-Type: application/json; charset=utf-8
```

Use Python (via the Bash tool) for all API calls.

---

## ⚠️ Known API Behaviours (confirmed against owllight-sleep)

**1. Articles response key is `"blogs"`, not `"articles"`**
Even though you're calling the articles endpoint, Shopline returns the list under the
key `"blogs"` in the JSON response. Always use `.get("blogs", [])`.

**2. Metafields fall back to shop-level**
If no article-specific metafields exist, `/metafields.json?owner_resource=articles&owner_id=X`
returns the shop-level SEO metafields (`owner_resource: "shop"`) instead of an empty list.
Always check the `owner_resource` field on each returned metafield to determine if it's
article-level or shop-level. If `owner_resource == "shop"`, the article has NO custom SEO set.

**3. Pages endpoint requires `read_page` scope**
`/store/pages.json` returns `"script tag data not found:pages"` if the app token does not
have the `read_page` permission. If this happens, skip pages in the snapshot and flag it
in the plan as needing a token scope upgrade.

---

## Step 1 — Fetch All Blog Collections

```python
import requests, json

BASE_URL = "https://{STORE_HANDLE}.myshopline.com/admin/openapi/v20251201"
HEADERS  = {
    "Authorization": "Bearer {ACCESS_TOKEN}",
    "Content-Type": "application/json; charset=utf-8"
}

r = requests.get(f"{BASE_URL}/store/blogs.json", headers=HEADERS)
blogs = r.json().get("blogs", [])
print(json.dumps(blogs, indent=2))
```

For each blog collection, capture:
- `id` — the BLOG_COLLECTION_ID
- `title` — human name (e.g. "News", "Mattress Comparisons")
- `handle` — URL slug prefix

If there is only one blog collection, store its ID automatically.
If there are multiple, present the list and ask the user which one(s) are used for
SEO blog content. Store all IDs for the snapshot.

---

## Step 2 — Fetch All Articles From Each Blog Collection

```python
all_articles = []  # flat list across all blogs

for blog in blogs:
    blog_id   = blog["id"]
    blog_name = blog["title"]

    r = requests.get(
        f"{BASE_URL}/store/blogs/{blog_id}/articles.json",
        headers=HEADERS,
        params={"limit": 100}
    )
    # ⚠️ KEY IS "blogs" NOT "articles" — confirmed Shopline behaviour
    articles = r.json().get("blogs", [])

    for a in articles:
        a["_blog_name"] = blog_name  # annotate for the snapshot
        all_articles.append(a)

print(f"Total articles across all blogs: {len(all_articles)}")
```

For each article, capture:
- `id`
- `title`
- `handle` — URL slug
- `custom_url.url` — full URL path
- `published_at` — `None` means draft
- `author`
- `digest` — excerpt
- `_blog_name` — annotated blog name

---

## Step 3 — Check SEO Metafields for Each Article

```python
seo_coverage = {}

for a in all_articles:
    article_id = a["id"]

    r = requests.get(
        f"{BASE_URL}/metafields.json",
        headers=HEADERS,
        params={
            "owner_resource": "articles",
            "owner_id": article_id,
            "namespace": "seo"
        }
    )
    metafields = r.json().get("metafields", [])

    # ⚠️ Filter: only article-level metafields count
    # If owner_resource == "shop", the article has NO custom SEO — it's inheriting the store default
    article_mf = [m for m in metafields if m.get("owner_resource") == "articles"]
    seo = {m["key"]: m["value"] for m in article_mf}

    seo_coverage[article_id] = {
        "title":       a.get("title"),
        "blog":        a.get("_blog_name"),
        "url":         a.get("custom_url", {}).get("url", ""),
        "published":   a.get("published_at") is not None,
        "seoTitle":    seo.get("seoTitle"),      # None = not set (inheriting shop default)
        "seoDesc":     seo.get("seoDescription") # None = not set
    }

# Summary
missing_title = [v for v in seo_coverage.values() if not v["seoTitle"]]
missing_desc  = [v for v in seo_coverage.values() if not v["seoDesc"]]
print(f"Articles missing article-level seoTitle: {len(missing_title)}/{len(all_articles)}")
print(f"Articles missing article-level seoDesc:  {len(missing_desc)}/{len(all_articles)}")
```

---

## Step 4 — Fetch All Products + SEO Metafields

```python
r = requests.get(f"{BASE_URL}/products/products.json", headers=HEADERS, params={"limit": 100})
products = r.json().get("products", [])
print(f"Total products: {len(products)}")

product_seo = {}
for p in products:
    pid = p["id"]
    mf_r = requests.get(f"{BASE_URL}/metafields.json", headers=HEADERS, params={
        "owner_resource": "products",
        "owner_id": pid,
        "namespace": "seo"
    })
    mf = mf_r.json().get("metafields", [])
    product_mf = [m for m in mf if m.get("owner_resource") == "products"]
    seo = {m["key"]: m["value"] for m in product_mf}
    product_seo[pid] = {
        "title":    p.get("title"),
        "handle":   p.get("handle"),
        "status":   p.get("status"),  # "active" or "draft"
        "seoTitle": seo.get("seoTitle"),
        "seoDesc":  seo.get("seoDescription")
    }

missing_prod_title = [v for v in product_seo.values() if not v["seoTitle"] and v["status"] == "active"]
print(f"Active products missing seoTitle: {len(missing_prod_title)}/{len([p for p in products if p.get('status')=='active'])}")
```

---

## Step 5 — Fetch Custom Pages

**Known behaviour:** The `/store/pages.json` endpoint returns `"script tag data not found:pages"`
even with `read_page` scope present. This means the store uses Shopline theme-level pages,
not custom Pages API pages. Skip this step and note it in the snapshot.

```python
r = requests.get(f"{BASE_URL}/store/pages.json", headers=HEADERS, params={"limit": 100})
if "script tag data not found" in r.text or r.status_code == 404:
    print("ℹ️  No custom pages — store uses theme pages. Page SEO is manual (Theme Editor).")
    pages = []
```

---


---

## Step 5 — Save the Snapshot

Save to: `{WORKSPACE_ROOT}/outputs/shopline-{STORE_HANDLE}/implementation/SHOPLINE-SNAPSHOT-YYYY-MM-DD.md`

```markdown
# Shopline Store Snapshot — {STORE_HANDLE}
Date: {date}
Token scopes confirmed: write_content ✅ | read_page ❌ (needs upgrade)

## Blog Collections

| Blog | ID | Articles |
|---|---|---|
| News | 686f553a771a545e09f23934 | 1 |
| Brand Story | 689b052bbdb0ff72d20d2f53 | 2 |
| Mattress Comparisons | 68e8d3d72d9b3812239e99a8 | 4 |
| Owllight Series | 69aff002ec210535546e9a58 | 1 |

## Blog Post SEO Coverage

| Blog | Title | URL | Published | seoTitle | seoDesc |
|---|---|---|---|---|---|
| Mattress Comparisons | Woosa Mattress vs Owllight... | /blogs/... | ✅ | ⚠️ Inheriting store default | ⚠️ Inheriting store default |

**SEO Coverage:**
- Posts with article-level seoTitle: 0 / 8 (0%)
- Posts with article-level seoDesc: 0 / 8 (0%)
- All posts currently inherit the store-default SEO — highest priority fix

**Store-level default SEO (currently applied to ALL posts):**
- seoTitle: "Mattress Promotion Singapore | Owllight Back Care Mattresses"
- seoDesc: "Mattress Promotion Singapore - Get up to 60%OFF..."

## Custom Pages
⚠️ Not fetched — token needs read_page scope.
To enable: Add read_page + write_page permissions to the app in Shopline Admin → Apps → Develop Apps.
```

---

## Step 6 — Feed into Phase 3

Before moving on, note in context:

1. **All articles missing article-level seoTitle** — list every post (currently 0/8 set)
2. **All articles missing article-level seoDescription** — same
3. **Draft posts** — any with `published_at == None`
4. **Store-default SEO values** — so Phase 3 can show the before value accurately
5. **Pages unavailable** — flag as prerequisite (scope upgrade needed)
6. **Blog collections confirmed** — all 4 IDs locked in for Phase 5
