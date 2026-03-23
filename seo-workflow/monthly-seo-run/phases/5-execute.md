# Phase 5 — Execute (Post Blogs + On-Page Changes)

**Only runs after explicit user approval at the Approval Gate.**

---

## Step 1 — Confirm approval received

If the user has not typed "approve" (or a clear equivalent), stop immediately.
Do not execute any changes until approval is explicit.

---

## Step 2 — Detect platform

Read `CLAUDE.md` → `## Platform` section:

| Value found | Action |
|---|---|
| `Shopline` | Execute using Shopline Admin REST API |
| `Webflow` | Execute using Webflow Data API via MCP |
| Anything else | Skip Phase 5 — note platform not supported for automated execution. Complete through Phase 4 only. |

---

## Phase 5a — Post Blogs to CMS

Post all 3 blog posts from `Content & SEO/outputs/{platform}-{handle}/blogs/`.

### Shopline

Read `CLAUDE.md` → Access token env var (e.g. `SHOPLINE_OWLLIGHT_TOKEN`).

For each `.html` file in the blogs folder:
1. Read the file
2. Extract the `<!-- META: title="..." description="..." -->` comment
3. POST to Shopline Blog API:
   - Blog ID: read from `CLAUDE.md` → `Blog ID` field (if set), else list blogs and use the primary/first blog
   - `title` → from META comment
   - `body_html` → full file contents (strip META comment before posting)
   - `published` → `true`
   - `metafields`: `description_tag` → from META comment description

Log each result:
```
✅ Posted: [Title] → /{slug} (article ID: XXXXX)
❌ Failed: [Title] — error: [message]
```

---

### Webflow

Confirm Webflow MCP is connected. If not: note it, skip blog posting, continue to Phase 5b.

For each `.html` file in the blogs folder:
1. Read the file
2. Extract the `<!-- META: title="..." description="..." -->` comment
3. Use Webflow MCP to create CMS item in the Blog collection:
   - `name` → post title
   - `slug` → derived from filename (strip `.html`)
   - `post-body` → file contents (strip META comment)
   - `seo-title` → from META comment title
   - `meta-description` → from META comment description
   - `published-on` → today's date

Log each result.

---

## Phase 5b — Apply On-Page SEO Changes

Execute all changes from `Content & SEO/outputs/{platform}-{handle}/implementation/SEO-PLAN-YYYY-MM-DD.md` (today's date).

### Pre-execution snapshot

Before making any changes, save current values for every affected page/item.

```bash
mkdir -p "Content & SEO/outputs/{platform}-{handle}/implementation"
```

Save snapshot to: `Content & SEO/outputs/{platform}-{handle}/implementation/SNAPSHOT-YYYY-MM-DD.md`

Format:
```
| Page/Item | Field | Value Before |
|---|---|---|
| /mattress-guide | SEO Title | Mattress Guide |
| /mattress-guide | Meta Description | (empty) |
```

---

### Shopline on-page changes

Read `CLAUDE.md` → Access token env var.

For each row in the SEO Plan:
- Determine resource type: page, product, blog post, or collection
- Use the appropriate Shopline Admin API endpoint:
  - Pages: `PUT /admin/pages/{id}.json`
  - Products: `PUT /admin/products/{id}.json`
  - Blog posts: `PUT /admin/articles/{id}.json`
- Fields to update: `title` (SEO title), `metafields` for `description_tag`, schema injection into `body_html` if applicable

Log each change:
```
✅ Updated: /mattress-guide → SEO Title: "Best Mattress for Back Pain Singapore 2026 — Owllight"
❌ Failed: /pillows → error: [message]
```

---

### Webflow on-page changes

Confirm Webflow MCP is connected.

For each row in the SEO Plan:
- Use Webflow MCP to update the item
- Fields: `seo-title`, `meta-description`, schema injection into rich text field if applicable

Log each change.

---

## Phase 5c — Save Snapshot (After)

Append the post-execution values to the snapshot file:

Format:
```
| Page/Item | Field | Value Before | Value After |
|---|---|---|---|
| /mattress-guide | SEO Title | Mattress Guide | Best Mattress for Back Pain Singapore 2026 — Owllight |
```

Include:
- All blog post URLs (new)
- All on-page changes (before/after)
- Any failures with error detail

---

## Phase 5 Summary

After all execution completes:

```
Phase 5 complete.

Blogs posted:
  ✅ [Title 1] → [URL]
  ✅ [Title 2] → [URL]
  ✅ [Title 3] → [URL]

On-page changes applied: N/N
  ✅ N succeeded
  ❌ N failed (see SNAPSHOT for details)

Snapshot saved: implementation/SNAPSHOT-YYYY-MM-DD.md
```

If any failures occurred, list them explicitly so they can be retried manually.

Proceed to Phase 6 (monthly report).
