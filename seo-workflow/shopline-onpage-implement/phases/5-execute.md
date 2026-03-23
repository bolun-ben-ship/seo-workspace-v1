# Phase 5 — Execute Changes

Apply all approved changes to the Shopline store via the Admin REST API.
Work through each approved category in order, logging every change.

All Python scripts run via the Bash tool. Use the `requests` library.
Use these constants throughout:

```python
BASE_URL = "https://{STORE_HANDLE}.myshopline.com/admin/openapi/v20251201"
HEADERS  = {
    "Authorization": "Bearer {ACCESS_TOKEN}",
    "Content-Type": "application/json; charset=utf-8"
}
BLOG_ID  = "{BLOG_COLLECTION_ID}"
```

---

## Execution Order

Run in this order to minimise risk:

1. **Categories A + B** — Page SEO titles and meta descriptions (low risk, reversible)
2. **Categories C + D** — Blog post SEO titles and meta descriptions (low risk, reversible)
3. **Category E** — Create and publish new blog posts
4. **Category F** — Schema injection into existing blog post content

---

## Categories A + B — Page SEO Titles and Meta Descriptions

Use `MetafieldsSet` to write SEO metadata for pages. Batch up to 25 metafields per call.

```python
import requests, json

# Build the metafields payload
metafields = []

for page in approved_pages:
    if page.get("new_seo_title"):
        metafields.append({
            "owner_resource": "pages",
            "owner_id": page["id"],
            "namespace": "seo",
            "key": "seoTitle",
            "type": "single_line_text_field",
            "value": page["new_seo_title"]
        })
    if page.get("new_seo_description"):
        metafields.append({
            "owner_resource": "pages",
            "owner_id": page["id"],
            "namespace": "seo",
            "key": "seoDescription",
            "type": "single_line_text_field",
            "value": page["new_seo_description"]
        })

# Send in batches of 25
for i in range(0, len(metafields), 25):
    batch = metafields[i:i+25]
    resp = requests.post(
        f"{BASE_URL}/metafields_set.json",
        headers=HEADERS,
        json={"metafields": batch}
    )
    result = resp.json()
    if resp.status_code == 200:
        print(f"✅ Batch {i//25 + 1}: {len(batch)} metafields written")
    else:
        print(f"❌ Batch {i//25 + 1} failed: {resp.status_code} — {result}")
```

Log each page as it's processed:
```
✅ About Us (/about-us) — seoTitle set: "(missing)" → "About Our Team — Brand"
✅ Contact (/contact) — seoDescription set
❌ FAQ (/faq) — metafield write failed: [error]
```

---

## Categories C + D — Blog Post SEO Titles and Meta Descriptions

Same `MetafieldsSet` pattern, but with `owner_resource: "articles"`:

```python
metafields = []

for post in approved_posts:
    if post.get("new_seo_title"):
        metafields.append({
            "owner_resource": "articles",
            "owner_id": post["id"],
            "namespace": "seo",
            "key": "seoTitle",
            "type": "single_line_text_field",
            "value": post["new_seo_title"]
        })
    if post.get("new_seo_description"):
        metafields.append({
            "owner_resource": "articles",
            "owner_id": post["id"],
            "namespace": "seo",
            "key": "seoDescription",
            "type": "single_line_text_field",
            "value": post["new_seo_description"]
        })

# Same batch loop as above
```

---

## Category E — Create and Publish New Blog Posts

For each new blog post in the approved list:

### Step 1 — Create the post

```python
import requests
from datetime import datetime, timezone

# ⚠️ CONFIRMED: payload MUST be wrapped in "blog" key AND include "handle"
# Using "article" wrapper returns 422 "title not allow blank" — confirmed 2026-03-20
post_data = {
    "blog": {
        "title": "Full Post Title Here",
        "handle": "full-post-title-here",   # required — without it returns 422
        "content_html": """<p>Full HTML blog content here...</p>
<h2>Section Heading</h2>
<p>More content...</p>""",
        "digest": "Compelling excerpt/summary for the post (1–2 sentences).",
        "author": "Author Name",
        "published": True,
        "published_at": datetime.now(timezone.utc).isoformat()
    }
}

resp = requests.post(
    f"{BASE_URL}/store/blogs/{BLOG_ID}/articles.json",
    headers=HEADERS,
    json=post_data
)
result = resp.json()

if resp.status_code in (200, 201):
    # ⚠️ Response also uses "blog" key (not "article")
    new_article_id = result["blog"]["id"]
    print(f"✅ Created: '{post_data['blog']['title']}' (ID: {new_article_id})")
else:
    print(f"❌ Failed to create post: {resp.status_code} — {result}")
```

### Step 2 — Set SEO metafields on the new post

Immediately after creation, write the SEO title and description:

```python
metafields = [
    {
        "owner_resource": "articles",
        "owner_id": new_article_id,
        "namespace": "seo",
        "key": "seoTitle",
        "type": "single_line_text_field",
        "value": "SEO title for this post — Brand"
    },
    {
        "owner_resource": "articles",
        "owner_id": new_article_id,
        "namespace": "seo",
        "key": "seoDescription",
        "type": "single_line_text_field",
        "value": "Meta description for this post, 140–160 characters."
    }
]

resp = requests.post(
    f"{BASE_URL}/metafields_set.json",
    headers=HEADERS,
    json={"metafields": metafields}
)
if resp.status_code == 200:
    print(f"✅ SEO metafields set for article {new_article_id}")
else:
    print(f"❌ SEO metafields failed: {resp.status_code}")
```

### Step 3 — Repeat for each blog post in the list

Process posts one at a time. Do not bulk-create in parallel — if one fails, log it and continue.

---

## Category F — Schema Injection into Blog Post Content

For posts that need Article or BreadcrumbList schema, prepend JSON-LD to the `content_html`:

```python
schema_script = """<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "{POST_TITLE}",
  "author": {"@type": "Person", "name": "{AUTHOR}"},
  "datePublished": "{PUBLISHED_AT}",
  "dateModified": "{UPDATED_AT}",
  "publisher": {
    "@type": "Organization",
    "name": "{BRAND_NAME}"
  }
}
</script>"""

# Fetch current content first
resp = requests.get(
    f"{BASE_URL}/store/blogs/{BLOG_ID}/articles/{article_id}.json",
    headers=HEADERS
)
current_html = resp.json()["article"]["content_html"]

# Prepend schema
new_html = schema_script + "\n" + current_html

# Update the post
resp = requests.put(
    f"{BASE_URL}/store/blogs/{BLOG_ID}/articles/{article_id}.json",
    headers=HEADERS,
    json={"content_html": new_html}
)
if resp.status_code == 200:
    print(f"✅ Schema injected into article {article_id}")
else:
    print(f"❌ Schema injection failed: {resp.status_code}")
```

---

## Logging

Maintain a running change log as you go:

```
✅ Page: About Us          — seoTitle set
✅ Page: Contact           — seoTitle + seoDescription set
✅ Post: "My Blog Title"   — seoTitle set
✅ Post: "My Blog Title"   — seoDescription set
✅ New post created+published: "New Article Title" (ID: xyz789)
✅ New post SEO set: "New Article Title"
✅ Schema injected: "Existing Post Title"
❌ Page: FAQ — metafield write failed: 401 Unauthorized
```

At the end of Phase 5, count:
- Pages updated (SEO titles, meta descriptions)
- Blog posts updated (SEO titles, meta descriptions)
- New posts created and published
- SEO metafields written on new posts
- Schema injections
- Failures (if any)

---

## Publishing Note

Unlike Webflow, there is no site-level "publish" step needed on Shopline.
Setting `"published": true` on a post makes it live immediately.
Pages are already live — SEO metafield changes take effect immediately with no publish step.

If any post was intentionally created as a draft (`"published": false`), note it in the
change log and remind the user to publish it manually when ready.
