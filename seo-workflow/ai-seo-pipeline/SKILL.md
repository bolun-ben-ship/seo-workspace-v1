---
name: ai-seo-pipeline
description: >
  Full long-term SEO automation pipeline. Platform-aware: auto-detects Shopline, Webflow,
  or WordPress from client CLAUDE.md and routes all blog publishing and on-page changes
  to the correct API. Runs a guided questionnaire (3/6/12 month duration), then executes
  a complete initial SEO run (audit + GSC/GA4 + last30days + keywords + on-page
  implementation plan + approval gate + execute changes + 5 blog drafts pushed to CMS),
  then schedules weekly blog generation (5 posts per week as CMS drafts) and monthly
  on-page reviews for the full engagement duration. Produces a Week 1 report, monthly
  summary reports, and a final engagement report. Uses Claude Code scheduled tasks.
  Always builds on prior work. Extensible for new platforms.
  Use when user says "ai-seo-pipeline", "automate SEO", "set up automation", "full SEO
  automation", "run the pipeline", "start the SEO campaign", or "set up ongoing SEO".
user-invocable: true
argument-hint: "(no arguments — guided questionnaire at startup)"
---

# AI SEO Pipeline

Full long-term SEO automation. Platform-aware. Reads all config from `CLAUDE.md`.
Guides you through setup, runs the complete initial implementation, then schedules
weekly + monthly automation for the full engagement using Claude Code scheduled tasks.

---

## Platform Detection (ALWAYS run first — before questionnaire)

Read `CLAUDE.md` from the current workspace. Find `## Platform` → `CMS:` field.

```
"Shopline"   → PLATFORM = shopline
"Webflow"    → PLATFORM = webflow
"WordPress"  → PLATFORM = wordpress   (future)
other/missing → PLATFORM = unknown
```

Also extract from `CLAUDE.md`:
```
CLIENT_NAME       ← from ## Client → Name
STORE_HANDLE      ← from ## Platform → Store / Site handle
TOKEN_ENV_VAR     ← from ## Platform → Access token (the env var name)
OUTPUT_PATH       ← from ## Workspace → Outputs path
GSC_SITE          ← from ## Analytics → GSC site
GA4_PROPERTY_ID   ← from ## Analytics → GA4 property ID
GOOGLE_KEY_ENV    ← from ## Analytics → Google credentials env var
PRIMARY_NICHE     ← from context/client-info.md → niche/topic summary
```

Announce: `Detected platform: {PLATFORM} ({STORE_HANDLE})` before proceeding.

If `PLATFORM = unknown`: warn the user — "Platform not recognised. Blog push and
on-page execution will be skipped. All outputs will be saved locally. You can still
run the research, plan, and writing phases." Continue with limited scope.

---

## Platform Routing Table

This table governs every execution decision in this skill:

| Action | Shopline | Webflow | WordPress (future) | Unknown |
|---|---|---|---|---|
| Blog draft push | Shopline REST API | Webflow MCP (`isDraft: true`) | WP REST API (`status: draft`) | Save HTML locally |
| On-page execution | `shopline-onpage-implement` logic | `webflow-onpage-implement` logic | `wordpress-onpage-implement` logic | Plan only |
| On-page approval prompt | "approve on-page changes via Shopline API" | "approve on-page changes via Webflow API + MCP" | "approve on-page changes via WordPress API" | Not applicable |
| CMS destination label | "Shopline" | "Webflow CMS" | "WordPress" | "local HTML" |
| Questionnaire Q2 | Show collection picker | Show CMS collection picker or auto-detect | Show category picker | Skip |

---

## What This Produces

**Each week (automated):**
- 5 blog posts written and pushed to {CMS} as drafts
- Saved HTML to `blogs/` folder

**Each month (automated):**
- Fresh GSC + GA4 + last30days research
- Updated on-page implementation plan
- Approval gate → execute approved changes via {PLATFORM} API
- Monthly summary report

**End of Week 1:**
- WEEK-1-REPORT comparing implementation plan vs what was executed

**End of engagement:**
- `/seo-final-report` — complete journey summary

---

## Output Structure

```
Content & SEO/outputs/{platform}-{handle}/
├── audit/
│   ├── AUDIT-YYYY-MM-DD.md
│   ├── POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.md
│   └── FINAL-REPORT-YYYY-MM-DD.md
├── research/
│   ├── GSC-REPORT-YYYY-MM-DD.md
│   ├── GA4-REPORT-YYYY-MM-DD.md
│   └── SOCIAL-TRENDS-YYYY-MM-DD.md
├── keywords/
│   └── KEYWORDS-YYYY-MM-DD.md
├── implementation/
│   ├── IMPLEMENTATION-PLAN-YYYY-MM-DD.md
│   └── SNAPSHOT-YYYY-MM-DD.md
├── blog-plans/
│   └── BLOG-PLAN-YYYY-MM-DD.md
├── blogs/
│   └── <post-slug>.html
└── reports/
    ├── WEEK-1-REPORT-YYYY-MM-DD.md
    ├── MONTHLY-REPORT-YYYY-MM.md
    └── FINAL-REPORT-YYYY-MM-DD.md
```

---

## Phase 0: Questionnaire

After platform detection, present this intake form. Questions 2 and 4 adapt per platform.
Ask all questions together — wait for all answers before proceeding.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 AI SEO Pipeline — Setup for {CLIENT_NAME}
Platform: {PLATFORM} ({STORE_HANDLE})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Campaign duration:
   [ ] 3 months   (~60 blogs, 3 on-page reviews)
   [ ] 6 months   (~120 blogs, 6 on-page reviews)
   [ ] 12 months  (~240 blogs, 12 on-page reviews)

2. Blog destination: [PLATFORM-SPECIFIC — see below]

3. Blog topic focus areas (optional — leave blank to let
   research determine topics each week):
   _______________________________________________

4. Approval mode for weekly blog drafts:
   [ ] Manual — review each week's 5 blogs before pushing to {CMS}
   [ ] Auto-push — push all 5 as drafts automatically,
       review them in {CMS} admin

5. Approval mode for monthly on-page changes:
   [ ] Manual — show me the plan, wait for approval before executing
   [ ] Auto-execute — run approved categories automatically
       (recommended for meta descriptions and SEO titles only)

6. Start date: Today is {DATE}. Confirm start?
   [ ] Yes, start today and run first weekly batch now
   [ ] No, just set up the schedule — I'll trigger the first run manually
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Question 2 — Platform-Conditional Blog Destination

**If PLATFORM = shopline:**
Fetch available blog collections via `GET {BASE_URL}/store/blogs.json` and list them.
Present as a picker. For owllight-sleep, confirmed collections:
```
   [ ] News              (686f553a771a545e09f23934) — industry news, trends
   [ ] Brand Story       (689b052bbdb0ff72d20d2f53) — brand/founder content
   [ ] Mattress Comparisons (68e8d3d72d9b3812239e99a8) — guides, reviews, comparisons
   [ ] Owllight Series   (69aff002ec210535546e9a58) — product deep dives
   [ ] Rotate across all collections based on content type
```
Store: `BLOG_COLLECTION_NAME` + `BLOG_COLLECTION_ID` (or `rotate`).

**If PLATFORM = webflow:**
Check if Webflow MCP tools are available (`data_cms_tool`). If yes, call
`get_collection_list` and present the blog/posts collections found.
If MCP not connected: ask user to enter the Blog Posts collection ID manually.
Store: `CMS_COLLECTION_ID` (Webflow collection ID).

**If PLATFORM = wordpress:**
Ask: "Which category should new posts be assigned to? (Enter category slug or ID,
or leave blank for uncategorised.)"
Also ask: "SEO plugin in use? Yoast SEO / Rank Math / Other / None"
Store: `WP_CATEGORY` + `WP_SEO_PLUGIN`.

**If PLATFORM = unknown:**
Skip this question. All blogs saved locally only.

---

**Store all questionnaire answers:**
```
PLATFORM:              shopline | webflow | wordpress | unknown
CAMPAIGN_DURATION:     3 | 6 | 12 (months)
TOTAL_WEEKS:           duration × 4
CAMPAIGN_END_DATE:     today + duration in months
BLOG_DESTINATION:      platform-specific collection/category ID
TOPIC_FOCUS:           {user input or "auto"}
BLOG_APPROVAL:         manual | auto-push
ONPAGE_APPROVAL:       manual | auto-execute
START_NOW:             true | false
```

---

## Phase 1: Initial Full Run

Run immediately (or on first manual trigger if START_NOW = false).

### Step 1a — Load Historical Context

- Scan `Content & SEO/outputs/{platform}-{handle}/` for all prior files
- Load newest per category (audit, implementation, research)
- Build HISTORICAL_CONTEXT: last score, resolved items (✅), outstanding priorities
- Announce: "Found [N] prior reports from [date]. Building on these." or "First run."
- Decide audit freshness: skip if POST-IMPLEMENTATION-AUDIT < 30 days old

### Step 1b — Full Research (run in parallel)

All three simultaneously:
- **SEO Audit** (if needed) → `audit/AUDIT-YYYY-MM-DD.md`
- **GSC + GA4** → `research/GSC-REPORT-*.md` + `research/GA4-REPORT-*.md`
- **last30days** for PRIMARY_NICHE → `research/SOCIAL-TRENDS-*.md`

### Step 1c — Keyword Research

4 tables from audit + GSC + last30days:
1. Primary target keywords (high-intent, achievable)
2. Long-tail transactional
3. Long-tail informational
4. PAA + AI search queries

**Save to:** `keywords/KEYWORDS-YYYY-MM-DD.md`

### Step 1d — Initial Implementation Plan

Run full `seo-implementation-plan` logic (Categories A–G, before/after for every change).
**Save to:** `implementation/IMPLEMENTATION-PLAN-YYYY-MM-DD.md`

### Step 1e — Initial Blog Plan (5 posts for Week 1)

- Based on keywords, last30days trends, content gaps
- No overlap with prior topics
- Mix informational + transactional intent
- Assign to BLOG_DESTINATION (or rotate)
- **Save to:** `blog-plans/BLOG-PLAN-YYYY-MM-DD.md`

### Step 1f — Write 5 Blog Posts

- Apply `context/tone-guide.md` if present
- Answer-first format, TL;DR, statistics, citation capsules, FAQ schema
- Output as HTML
- **Save to:** `blogs/<post-slug>.html` (all 5)

---

**⏸ APPROVAL GATE**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Initial Run Summary — Awaiting Approval
Platform: {PLATFORM}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SEO Audit Score:    {score}/100

On-Page Plan — to execute via {PLATFORM} API:
  Category A — SEO Titles:         {N} items
  Category B — Meta Descriptions:  {N} items
  Category C — Blog SEO Titles:    {N} posts
  Category D — Blog Meta Descs:    {N} posts
  Category F — Schema:             {N} items
  Category G — Manual (not via API): {N} items

Blog Drafts Ready (5 posts for {CMS}):
  1. {Post Title 1}
  2. {Post Title 2}
  3. {Post Title 3}
  4. {Post Title 4}
  5. {Post Title 5}

→ Type "approve all" | "approve on-page only" | "approve blogs only"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Skip relevant gates if ONPAGE_APPROVAL or BLOG_APPROVAL = auto.

---

### Step 1g — Execute On-Page Changes (platform-routed)

Route to the correct implementation logic based on PLATFORM:

---

**If PLATFORM = shopline:**
```
BASE_URL     = https://{STORE_HANDLE}.myshopline.com/admin/openapi/v20251201
ACCESS_TOKEN = os.environ[TOKEN_ENV_VAR]
HEADERS      = Authorization: Bearer {ACCESS_TOKEN}
               Content-Type: application/json; charset=utf-8
```
For each approved change → `POST {BASE_URL}/metafields_set.json`
with `owner_resource: "articles"` or `"products"`, `namespace: "seo"`,
keys `seoTitle` / `seoDescription`.

On 401: stop immediately, report invalid token. On 429: wait 2s, retry once.

---

**If PLATFORM = webflow:**
Check Webflow MCP tools are connected. If not → abort execution, tell user to
connect Webflow MCP and re-run, save plan for manual execution.

For each approved change, call Webflow Data API or MCP:
- Page SEO title → update `seo.title`
- Page meta description → update `seo.description`
- noindex setting → update `seo.noIndex`

Follow `webflow-onpage-implement` phases/5-execute.md logic.

---

**If PLATFORM = wordpress:**
```
WP_API_BASE = {SITE_URL}/wp-json/wp/v2
AUTH        = Application Password or JWT token from TOKEN_ENV_VAR
```
Update post/page SEO via:
- **Yoast SEO:** `yoast_title`, `yoast_desc` via `POST /wp/v2/posts/{id}`
  with `meta: { _yoast_wpseo_title: "...", _yoast_wpseo_metadesc: "..." }`
- **Rank Math:** `rank_math_title`, `rank_math_description` via post meta
- **None/Other:** Update `title` and `excerpt` fields as fallback;
  flag that a SEO plugin is needed for proper meta control

*(WordPress support is in preview — verify plugin field names before executing)*

---

**If PLATFORM = unknown:**
Skip execution. Save plan file. Tell user to apply changes manually.

---

Save before/after snapshot → `implementation/SNAPSHOT-YYYY-MM-DD.md`

---

### Step 1h — Push 5 Blog Drafts to CMS (platform-routed)

Route to the correct push method based on PLATFORM:

---

**If PLATFORM = shopline:**
```python
import requests, os

BASE_URL = f"https://{STORE_HANDLE}.myshopline.com/admin/openapi/v20251201"
HEADERS = {
    "Authorization": f"Bearer {os.environ[TOKEN_ENV_VAR]}",
    "Content-Type": "application/json; charset=utf-8"
}

for post in posts:
    # Create draft
    payload = {"blog": {
        "title": post.title,
        "handle": post.slug,        # required — lowercase-hyphens
        "content_html": post.html,  # strip <html>/<head>/<body> wrappers
        "published": False           # draft
    }}
    resp = requests.post(
        f"{BASE_URL}/store/blogs/{BLOG_COLLECTION_ID}/articles.json",
        headers=HEADERS, json=payload
    )
    new_id = resp.json()["blog"]["id"]  # key is "blog", not "article"

    # Set SEO metafields
    requests.post(f"{BASE_URL}/metafields_set.json", headers=HEADERS, json={
        "metafields": [
            {"owner_resource":"articles","owner_id":new_id,
             "namespace":"seo","key":"seoTitle","value":post.seo_title,"value_type":"string"},
            {"owner_resource":"articles","owner_id":new_id,
             "namespace":"seo","key":"seoDescription","value":post.meta_desc,"value_type":"string"}
        ]
    })
    print(f"Draft created: {post.title} (ID: {new_id})")
```

Quirks (confirmed for owllight-sleep):
- Payload MUST use `{"blog": {...}}` wrapper — NOT `{"article": {...}}`
- `"handle"` field is required — omitting causes 422
- Response key is `"blog"` → `resp.json()["blog"]["id"]`

---

**If PLATFORM = webflow:**
Confirm Webflow MCP is connected. If not → skip, tell user to copy HTML manually.

1. Call `data_cms_tool` → `get_collection_list` → find Blog Posts collection
2. Call `get_collection_details` to map exact field slugs
3. For each post, call `create_collection_items` with `isDraft: true`:
   - `name` (PlainText) → post title
   - `slug` (PlainText) → URL slug
   - `content` (RichText) → HTML body (strip outer tags)
   - `meta-title` (PlainText) → SEO title
   - `meta-description` (PlainText, max 160 chars)
   - `date-of-entry` (DateTime) → ISO datetime

Never guess field names — always map from `get_collection_details` response first.

---

**If PLATFORM = wordpress:**
```
POST {WP_API_BASE}/posts
Auth: Basic (base64 "user:application_password")
Body: {
  "title": "{post_title}",
  "content": "{html_body}",
  "status": "draft",
  "categories": [{WP_CATEGORY_ID}],
  "meta": {
    "_yoast_wpseo_title": "{seo_title}",         // if Yoast SEO
    "_yoast_wpseo_metadesc": "{meta_description}" // if Yoast SEO
  }
}
Response: post.id, post.link (draft permalink)
```
*(WordPress support is in preview — confirm API auth method and SEO plugin meta keys before running)*

---

**If PLATFORM = unknown:**
All 5 HTML files are already saved to `blogs/`. Tell user:
"Blog HTML saved locally. Copy each file to your CMS manually."

---

## Phase 2: Schedule Recurring Tasks

After Phase 1 completes, create 4 scheduled tasks using Claude Code scheduled tasks.

### Task 1: Weekly Blog Generation

**Frequency:** Every 7 days from today
**Count:** TOTAL_WEEKS - 1 remaining runs (week 1 ran now)
**Label:** `{CLIENT}-weekly-blogs`

**Task instruction:**
```
Weekly blog run for {CLIENT_NAME} — platform: {PLATFORM}.

1. Load CLAUDE.md — confirm platform is still {PLATFORM}, get API credentials.
2. Load context/tone-guide.md and context/client-info.md.
3. Load blogs/ folder — list all prior post slugs/titles — do NOT repeat any topic.
4. Run last30days research for "{PRIMARY_NICHE}" — find this week's trending angles.
5. Load keywords/KEYWORDS-*.md (most recent) for keyword targeting.
6. Write 5 new SEO-optimised blog posts (HTML, answer-first, TL;DR, FAQ schema).
   - No topic overlap with prior posts
   - Mix informational + transactional intent
   - Apply tone guide
7. Save each to blogs/<post-slug>.html.
8. Push all 5 to {CMS} as drafts using PLATFORM = {PLATFORM}:
   - Shopline: REST API, blog collection "{BLOG_DESTINATION}", published: false
   - Webflow: MCP create_collection_items, isDraft: true
   - WordPress: WP REST API, status: draft
   - Unknown: save HTML only
9. If BLOG_APPROVAL = manual: present posts for review first.
10. Report: 5 titles + CMS IDs (or file paths if unknown platform).
```

### Task 2: Monthly On-Page Review

**Frequency:** Every 30 days from today
**Count:** CAMPAIGN_DURATION runs
**Label:** `{CLIENT}-monthly-onpage`

**Task instruction:**
```
Monthly on-page SEO review for {CLIENT_NAME} — platform: {PLATFORM}.

1. Load all context from CLAUDE.md and all prior output files.
2. Pull fresh GSC + GA4 data (last 30 days).
3. Run last30days for "{PRIMARY_NICHE}".
4. Identify: new CTR gaps, regressions vs prior snapshot, new keyword opportunities.
5. Run seo-implementation-plan — produce updated before/after plan.
6. If ONPAGE_APPROVAL = manual: present plan and wait for approval.
7. Execute approved changes via {PLATFORM} API:
   - Shopline: metafields_set REST API
   - Webflow: Webflow Data API + MCP
   - WordPress: WP REST API + SEO plugin meta
   - Unknown: save plan only, no execution
8. Save SNAPSHOT-YYYY-MM-DD.md and POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.md.
9. Write monthly report to reports/MONTHLY-REPORT-YYYY-MM.md.
```

### Task 3: Week 1 Report

**Run once:** 7 days from today
**Label:** `{CLIENT}-week1-report`

**Task instruction:**
```
Week 1 Report for {CLIENT_NAME}.
1. Load implementation/IMPLEMENTATION-PLAN-{START_DATE}.md (initial plan).
2. Load implementation/SNAPSHOT-{START_DATE}.md (what was executed).
3. List the 5 blog HTML files from the initial run.
4. Check which planned items were completed vs skipped vs deferred.
5. Pull current GSC impressions for newly pushed posts (if indexed yet).
6. Write WEEK-1-REPORT using the standard format.
7. Save to reports/WEEK-1-REPORT-{DATE}.md.
```

### Task 4: Final Report

**Run once:** On CAMPAIGN_END_DATE
**Label:** `{CLIENT}-final-report`

**Task instruction:**
```
Final Report for {CLIENT_NAME} — end of {CAMPAIGN_DURATION}-month engagement.
Run /seo-final-report to produce the complete engagement summary.
```

---

### Confirm Scheduled Tasks

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ AI SEO Pipeline — Automation Active
Client:    {CLIENT_NAME}
Platform:  {PLATFORM} ({STORE_HANDLE})
Duration:  {CAMPAIGN_DURATION} months
Period:    {START_DATE} → {CAMPAIGN_END_DATE}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Scheduled Tasks:
  Week 1 Initial Run:    ✅ Complete (today)
  Week 1 Report:         {DATE + 7 days}
  Weekly Blogs:          Every 7 days — {TOTAL_WEEKS - 1} runs remaining
    Next run:            {DATE + 7 days}
    Total blogs planned: {TOTAL_WEEKS × 5} drafts → {CMS}
  Monthly On-Page:       Every 30 days — {CAMPAIGN_DURATION} runs
    Next run:            {DATE + 30 days}
  Final Report:          {CAMPAIGN_END_DATE}

Blog destination:        {BLOG_DESTINATION}
Blog approval:           {manual | auto-push}
On-page approval:        {manual | auto-execute}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Week 1 Report Format

Save to: `reports/WEEK-1-REPORT-YYYY-MM-DD.md`

```markdown
# Week 1 Report — {CLIENT_NAME}
**Platform:** {PLATFORM}
**Period:** {START_DATE} → {START_DATE + 7 days}
**Produced by:** RightClick:AI / AI SEO Pipeline

## 1. Initial Plan vs Execution

### On-Page Changes
| Category | Planned | Executed | Notes |
|---|---|---|---|
| SEO Titles | N | N | via {PLATFORM} API |
| Meta Descriptions | N | N | |
| Blog SEO Titles | N | N | |
| Blog Meta Descs | N | N | |
| Schema | N | N | |

### Planned But Not Executed
| Item | Reason |
|---|---|

### Manual Items (Category G — require CMS UI)
| Item | Status |
|---|---|

### Blogs Published as Drafts
| # | Title | Destination | Draft ID/Link |
|---|---|---|---|

## 2. Starting Baseline
- SEO Health Score: {N}/100
- Organic sessions (30d): {N}
- Top 5 queries: [list]

## 3. What's Coming
- Week 2 blogs: {DATE}
- Month 1 on-page review: {DATE}
```

---

## Monthly Report Format

Save to: `reports/MONTHLY-REPORT-YYYY-MM.md`

```markdown
# Monthly Report — {MONTH YEAR} — {CLIENT_NAME}
**Month {N} of {CAMPAIGN_DURATION} | Platform: {PLATFORM}**
**Produced by:** RightClick:AI / AI SEO Pipeline

## 1. Blogs Published This Month
| Week | Post Title | Destination | Status |
|---|---|---|---|

Total this month: {N} | Total to date: {N}

## 2. On-Page Changes This Month
| Category | Changes Made | API Used |
|---|---|---|
| SEO Titles | N | {PLATFORM} API |

## 3. Performance Movement
| Metric | Last Month | This Month | Change |
|---|---|---|---|
| Organic sessions (30d) | | | |
| SEO Health Score | /100 | /100 | |
| Avg position (top 10) | | | |

## 4. Top Keyword Movements
| Query | Position Change | CTR Change |
|---|---|---|

## 5. Outstanding Items
| Priority | Item |
|---|---|

## 6. Next Month Plan
- Blog topics queued: [list]
- On-page priorities: [list]
```

---

## Platform API Reference

### Shopline (REST API)

```
BASE_URL  = https://{STORE_HANDLE}.myshopline.com/admin/openapi/v20251201
AUTH      = Authorization: Bearer {JWT_TOKEN}

Create draft article:
  POST {BASE_URL}/store/blogs/{BLOG_ID}/articles.json
  Body: {"blog": {"title":"...","handle":"...","content_html":"...","published":false}}
  Response: resp.json()["blog"]["id"]  ← key is "blog", not "article"
  Quirks: "handle" field required; "blog" wrapper required (not "article")

Set SEO metafields:
  POST {BASE_URL}/metafields_set.json
  Body: {"metafields":[{"owner_resource":"articles","owner_id":ID,
         "namespace":"seo","key":"seoTitle","value":"...","value_type":"string"},...]}

Error handling:
  401 → stop immediately, report invalid token
  429 → wait 2s, retry once
```

### Webflow (Data API + MCP)

```
API base: https://api.webflow.com/v2
AUTH: Authorization: Bearer {WEBFLOW_TOKEN}
MCP tools: data_cms_tool, data_pages_tool

Create draft blog post:
  data_cms_tool → create_collection_items with isDraft: true
  Map fields from get_collection_details first — never guess field slugs

Update page SEO:
  data_pages_tool → update page with seo.title, seo.description, seo.noIndex

Error handling:
  MCP not connected → abort execution, tell user to connect Webflow MCP
```

### WordPress (future — preview support)

```
API base: {SITE_URL}/wp-json/wp/v2
AUTH: Basic Auth — base64("username:application_password")
      OR JWT token via JWT Authentication plugin

Create draft post:
  POST /wp/v2/posts
  Body: {"title":"...","content":"...","status":"draft",
         "categories":[ID],"meta":{SEO_META}}

SEO meta keys (depends on plugin):
  Yoast SEO:  _yoast_wpseo_title, _yoast_wpseo_metadesc
  Rank Math:  rank_math_title, rank_math_description

Note: Verify plugin-specific field names before running.
WordPress support is in preview — test on staging first.
```

---

## Adding a New Platform

When a new platform is added (e.g., Squarespace, Wix, Framer):

1. Add a row to the **Platform Routing Table** above
2. Add a new **If PLATFORM = {new}** block in:
   - Step 1g (on-page execution)
   - Step 1h (blog draft push)
   - Task 1 and Task 2 scheduled task instructions
3. Add an API reference section at the bottom of this file
4. Update `install.sh` SKILLS array if a new `{platform}-onpage-implement` skill is created
5. Update SKILLS-REFERENCE.md and CLAUDE.md platform routing table
6. **Confirm to the user that SKILLS-REFERENCE.md has been updated**

---

## Sub-skill Reference Paths

`.skills/skills/seo-and-blog/skills/<skill-name>.md` (try first)
`.skills/skills/<skill-name>/SKILL.md` (fallback)
`.skills/skills/seo-implementation-plan/SKILL.md`
`.skills/skills/seo-final-report/SKILL.md`
`.skills/skills/3blog-pipeline/SKILL.md`
`.skills/skills/shopline-onpage-implement/SKILL.md`
`.skills/skills/webflow-onpage-implement/SKILL.md`
