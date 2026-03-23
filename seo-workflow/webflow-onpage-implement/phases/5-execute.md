# Phase 5 — Execute Changes

Apply all approved changes to Webflow via the MCP connector. Work systematically through
each approved category, logging every change as you go.

## Before Starting

- Confirm which categories were approved in Phase 4
- Have the Webflow snapshot (Phase 2) and implementation plan (Phase 3) in context
- Set up a change log in memory — you'll write this to the report in Phase 6

## Execution Order

Run categories in this order to minimise risk:

1. **Noindex** (Category D) — safest first; protects pages from Google while you work
2. **Title Tags** (Category A) — low risk, high impact
3. **Meta Descriptions** (Category B) — low risk, high impact
4. **Schema Injection** (Category C) — script registration + page assignment
5. **CMS Field Updates** (Category E) — rename fields or update CMS items

---

## Category D — Noindex Execution

For each page to be noindexed:

1. Check if a noindex script is already registered (`data_scripts_tool` → `list_registered_scripts`)
   - If yes: note the script ID and skip to step 3
   - If no: register a new script

2. Register the noindex script (once, site-wide):
```
Tool: data_scripts_tool
Action: add_inline_site_script
id: "noindextag"
displayName: "NoindexTag"
sourceCode: "document.head.insertAdjacentHTML('beforeend','<meta name=\"robots\" content=\"noindex,nofollow\">');"
location: header
version: "1.0.0"
```

3. Apply the script to each target page:
```
Tool: data_scripts_tool
Action: upsert_page_script
pageId: <page_id>
scriptId: "noindextag"
location: header
version: "1.0.0"
```

Log each page as it's applied.

---

## Category A — Title Tag Execution

For each page in the approved title tag list:

```
Tool: data_pages_tool
Action: update_page_settings
page_id: <page_id>
body: {
  "id": "<page_id>",
  "seo": {
    "title": "<new_title>"
  }
}
```

Process in batches of 5 pages. If a page returns an error, log it and continue —
don't stop the whole run for one failure.

---

## Category B — Meta Description Execution

Same pattern as Category A, using `seo.description` instead of `seo.title`.

Can be combined with Category A in a single `update_page_settings` call per page:
```
"seo": {
  "title": "<new_title>",
  "description": "<new_description>"
}
```

---

## Category C — Schema Injection Execution

For each schema script:

1. Register the script site-wide via `add_inline_site_script`
   - Keep each script under 2000 characters
   - If the JSON-LD is too long, minify it (remove whitespace)
   - `displayName` must be alphanumeric (e.g., "OrgSchema", "FaqSchema", "BlogSchema")

2. Apply to target pages via `upsert_page_script`

Schema script IDs to use (if not already registered):
- `orgschema` — Organization + FinancialService on homepage
- `faqschema` — FAQPage on /faqs
- `blogschema` — Article + BreadcrumbList on blog template

For blog Article schema: use `document.title` and `window.location.href` as dynamic
references — do not hardcode per-post values, as this runs on a CMS template.

---

## Category E — CMS Field Updates

### Field renames (display name only):
```
Tool: data_cms_tool
Action: update_collection_field
collection_id: <id>
field_id: <field_id>
request: { "displayName": "<new_name>" }
```

Note: renaming a field's displayName does NOT change the slug or break any template
bindings. It only changes what the editor sees in the CMS editor UI.

### CMS item updates (blog posts, meta fields, etc.):
```
Tool: data_cms_tool
Action: update_collection_items
collection_id: <id>
request: {
  "items": [
    {
      "id": "<item_id>",
      "isDraft": true,
      "fieldData": {
        "meta-title": "<value>",
        "meta-description": "<value>"
      }
    }
  ]
}
```

---

## Logging

After each change, add an entry to your internal change log:

```
✅ /about — title updated: "About - AEHL" → "Meet the Team — Brand"
✅ /faqs — meta description added
✅ noindextag → applied to /landing-page
✅ orgschema → registered and applied to /
❌ /services — title update failed: [error message]
```

At the end of Phase 5, count:
- Pages updated (titles, metas)
- Scripts registered
- Script-to-page applications
- Failures (if any)

## Publishing

After executing all changes, ask the user:
"All changes are applied. Would you like to publish the site now?"

If yes: attempt `publish_site` via `data_sites_tool`.
Note: the Webflow publish API has a rate limit. If it returns 429, tell the user to
publish manually from the Webflow Designer, and note which domains to select
(production domains only, NOT the .webflow.io staging subdomain).

If no: changes are staged in Webflow and will go live on next publish.
