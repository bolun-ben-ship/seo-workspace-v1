# /onboard

Onboard a new client by scraping their website and scaffolding a workspace from the agency template.

Usage: `/onboard domain.com`
The domain becomes the folder name: `clients/domain.com/`

---

## Step 1 — Parse the domain

The argument after `/onboard` is the CLIENT_DOMAIN.
Example: `/onboard owllight-sleep.com` → CLIENT_DOMAIN = `owllight-sleep.com`

If no argument is provided, ask: "What is the client's domain? (e.g. owllight-sleep.com)"

Set:
```
CLIENT_DOMAIN  = the argument (e.g. "owllight-sleep.com")
AGENCY_ROOT    = the current working directory (this workspace)
CLIENT_PATH    = {AGENCY_ROOT}/clients/{CLIENT_DOMAIN}
TEMPLATE_PATH  = {AGENCY_ROOT}/client-template
SITE_URL       = https://{CLIENT_DOMAIN}
```

---

## Step 2 — Check for conflicts

Check if `clients/{CLIENT_DOMAIN}` already exists.
If it does → stop and tell the user: "A client folder for `{CLIENT_DOMAIN}` already exists. Open `clients/{CLIENT_DOMAIN}/` directly in Claude Code to continue working on this client."

---

## Step 3 — Scrape the website

Fetch and analyse the following pages (use WebFetch tool, skip silently if a page 404s):

| Page | What to extract |
|---|---|
| `https://{CLIENT_DOMAIN}` | Brand name, tagline, headline, main value proposition, product/service categories |
| `https://{CLIENT_DOMAIN}/about` or `/about-us` | Founder story, mission, brand history, why they started |
| `https://{CLIENT_DOMAIN}/products` or `/shop` or `/services` | Product/service names, prices if visible, key features |
| `https://{CLIENT_DOMAIN}/blog` | Blog exists? Topics covered, categories |
| `https://{CLIENT_DOMAIN}/sitemap.xml` | Full page list — use to discover key pages not found above |

From the scraped content, extract and store:

```
BRAND_NAME         = detected brand/company name
BRAND_TAGLINE      = tagline or hero headline
NICHE              = inferred (e.g. "Mattress / back care / sleep")
MARKET             = inferred location/market (e.g. "Singapore", "Australia", "Global")
PRODUCTS_SERVICES  = list of key products or services with any visible prices
TARGET_AUDIENCE    = inferred from copy (who they're talking to)
COMPETITORS_FOUND  = any competitor names mentioned on the site
BLOG_EXISTS        = yes/no + blog URL if found
KEY_PAGES          = list of important pages found
```

If a value can't be confidently inferred, mark it as `[could not detect — fill in manually]`.

---

## Step 4 — Ask for the remaining details

These cannot be scraped — ask all at once:

```
I've scraped {CLIENT_DOMAIN} and pre-filled what I could. I need a few more details:

1. Platform? shopline / webflow / wordpress / other
2. Store or site handle? (the subdomain or slug used in the API — e.g. "owllight-sleep" for owllight-sleep.myshopline.com)
3. GSC site URL? (leave blank if not yet configured)
4. GA4 property ID? (leave blank if not yet configured)
```

From the platform + handle, generate:
```
TOKEN_ENV_VAR = {PLATFORM_UPPER}_{HANDLE_UPPER_UNDERSCORED}_TOKEN
               e.g. SHOPLINE_OWLLIGHT_SLEEP_TOKEN
               e.g. WEBFLOW_AEXPHL_TOKEN

API_BASE_URL  = platform default:
  shopline   → https://{handle}.myshopline.com/admin/openapi/v20251201
  webflow    → https://api.webflow.com/v2
  wordpress  → https://{CLIENT_DOMAIN}/wp-json/wp/v2
```

---

## Step 5 — Scaffold the workspace

```bash
cp -r "{TEMPLATE_PATH}" "{CLIENT_PATH}"
mkdir -p "{CLIENT_PATH}/Content & SEO/outputs/{platform}-{handle}/audit"
mkdir -p "{CLIENT_PATH}/Content & SEO/outputs/{platform}-{handle}/implementation"
mkdir -p "{CLIENT_PATH}/Content & SEO/outputs/{platform}-{handle}/research"
mkdir -p "{CLIENT_PATH}/Content & SEO/outputs/{platform}-{handle}/keywords"
mkdir -p "{CLIENT_PATH}/Content & SEO/outputs/{platform}-{handle}/blog-plans"
mkdir -p "{CLIENT_PATH}/Content & SEO/outputs/{platform}-{handle}/blogs"
```

The `cp -r` copies the full template including `.claude/commands/start-client.md`.
The placeholder replacements in Step 6 will fill it in.

---

## Step 6 — Populate CLAUDE.md and start-client.md

Replace all placeholders in **both** of these files:
- `{CLIENT_PATH}/CLAUDE.md`
- `{CLIENT_PATH}/.claude/commands/start-client.md`

| Placeholder | Replace with |
|---|---|
| `{CLIENT_NAME}` | BRAND_NAME |
| `{WEBSITE_URL}` | SITE_URL |
| `{MARKET}` | MARKET |
| `{NICHE}` | NICHE |
| `{shopline \| webflow \| wordpress}` | Selected platform |
| `{HANDLE}` | Store/site handle |
| `{PLATFORM}_{CLIENT_SLUG}_TOKEN` | TOKEN_ENV_VAR |
| `{API_BASE_URL}` | API_BASE_URL |
| `{GSC_SITE_URL or "not yet configured"}` | GSC URL or "not yet configured" |
| `{GA4_PROPERTY_ID or "not yet configured"}` | GA4 ID or "not yet configured" |
| `{client}-claude-workspace` | `clients/{CLIENT_DOMAIN}` |
| `{platform}-{handle}` | e.g. `shopline-owllight-sleep` |
| `{PLATFORM}` | platform (lowercase) — e.g. `shopline` |
| `{CREDENTIALS_ENV_VAR}` | e.g. `OWLLIGHT_GOOGLE_KEY` |
| `{TOKEN_ENV_VAR}` | TOKEN_ENV_VAR |
| `{OUTPUTS_PATH}` | `Content & SEO/outputs/{platform}-{handle}/` |

---

## Step 7 — Populate context files

Write scraped data into the context files:

**`context/client-info.md`** — replace template placeholders with:
- Brand name, tagline, niche, market
- Products/services list (names, prices, handles if found)
- Key pages list
- Target audience description
- Competitors found (or `[none detected — fill in manually]`)
- Blog status

**`context/current-data.md`** — replace `{CLIENT_NAME}` with BRAND_NAME, leave stats as `—` (no data yet)

---

## Step 8 — Update clients.md

Add a new row to `{AGENCY_ROOT}/clients.md`:

```
| {BRAND_NAME} | {Platform} | `clients/{CLIENT_DOMAIN}` | {handle} | {TOKEN_ENV_VAR} | Active |
```

---

## Step 9 — Final summary

Print:

```
✅ {BRAND_NAME} ({CLIENT_DOMAIN}) onboarded successfully.

Workspace: clients/{CLIENT_DOMAIN}/
Platform:  {platform} — {handle}
Outputs:   Content & SEO/outputs/{platform}-{handle}/

What was auto-filled from the website:
  ✅ Brand name, tagline, niche, market
  ✅ Products / services list
  ✅ Target audience
  {✅ or ⚠️} Competitors ({n} found / none detected)
  {✅ or ⚠️} Blog ({found at URL / not found})

Review and correct if needed:
  clients/{CLIENT_DOMAIN}/context/client-info.md

One thing left for you to do — add this to ~/.zshrc then run `source ~/.zshrc`:
  export {TOKEN_ENV_VAR}="paste-token-here"

Then open clients/{CLIENT_DOMAIN}/ as a new Claude Code project and run:
  /start-client          ← load context and get a full briefing
  /{platform}-seo-orchestrator  ← start the SEO pipeline when ready
```
