# Phase 2 — Webflow Data Fetch

Fetch the current state of all pages, CMS collections, and scripts from Webflow via the API.
This is the "before" snapshot that Phase 3 and Phase 6 will reference.

## Goal

Build a complete picture of what is currently in Webflow — page titles, meta descriptions,
existing scripts, CMS structure — so the implementation plan can show accurate before/after values.

## Steps

### 1. Get the site ID

If not already known, call `data_sites_tool` with `list_sites` to find the site.

### 2. Fetch all pages

Call `data_pages_tool` with `list_pages` for the site. For each page capture:
- `id` — needed for targeted updates in Phase 5
- `title` — internal Webflow page name
- `slug` / `publishedPath` — the live URL path
- `seo.title` — current SEO title (blank means Webflow auto-generates)
- `seo.description` — current meta description
- `draft` / `archived` status — draft/archived pages should not be indexed

Store this as a structured list. Separate pages into:
- **Production pages** — live, should be indexed (or evaluated for noindex)
- **Staging / utility pages** — v2 redesigns, landing pages, thank-you pages, duplicates
- **CMS templates** — auto-generated template pages for CMS collections

### 3. Fetch existing scripts

Call `data_scripts_tool` with `list_registered_scripts` to see what custom code
is already registered site-wide. Note:
- Script IDs and display names
- Whether noindex, schema, or other SEO scripts are already applied

Then check per-page script assignments if you need to know which pages have which scripts.

### 4. Fetch CMS collections (if relevant)

Call `data_cms_tool` with `get_collection_list` to identify:
- Blog Posts collection — ID, field schema
- Any other content collections (FAQs, Testimonials, etc.)

If blog-related changes are in scope, also call `get_collection_details` on the Blog Posts
collection to map field slugs (you'll need these exact slugs to push content in Phase 5).

### 5. Snapshot output

Save a snapshot file at:
`Content & SEO/outputs/<domain>/implementation/WEBFLOW-SNAPSHOT.md`

Format:
```
# Webflow Site Snapshot — <domain>
Date: <date>
Site ID: <id>

## Pages
| Page | Path | Current Title | Current Meta Description | Draft? |
|---|---|---|---|---|
| Home | / | ... | ... | No |
...

## Registered Scripts
| Script ID | Display Name | Location |
|---|---|---|
...

## CMS Collections
| Collection | ID | Item Count |
|---|---|---|
...
```

This snapshot is the "before" record Phase 6 will use.
