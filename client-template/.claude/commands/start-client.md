# /start-client

Load all client context and produce a Client Briefing for this session.

Run this at the start of every client workspace session so Claude knows exactly
who this client is, where they are in their SEO journey, and what's pending.

---

## Step 1 — Read client configuration

Read `CLAUDE.md` from the current workspace and extract:
- Client name, website, market, niche
- **Platform (CMS)** — exactly: `Shopline`, `Webflow`, or `WordPress`
- Store / Site handle
- Access token env var name
- Outputs path
- Analytics: GSC site, GA4 property ID, Google credentials env var
- Context Loading Rules
- Voice & Tone guidelines

Note the platform — it governs which skills are available and how they route CMS calls.

---

## Step 2 — Read all context files

Read each file if it exists. Skip silently if absent — note missing files in the briefing.

- `context/client-info.md` — brand, products/services, competitors, audience
- `context/current-data.md` — live metrics, web assets, baseline data
- `context/strategy.md` — content & growth strategy, current focus
- `context/tone-guide.md` — brand voice, writing rules
- `context/personal-info.md` — founder voice, values (if exists)

---

## Step 3 — Scan SEO output history

Replace `{PLATFORM}` and `{HANDLE}` with the values read from CLAUDE.md.

```bash
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/" 2>/dev/null || echo "NO_OUTPUTS_YET"
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/audit/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/research/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/implementation/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/blogs/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/blog-plans/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/keywords/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/reports/" 2>/dev/null | sort -r | head -1
ls "Design/" 2>/dev/null | sort -r | head -3
```

Record: subfolder name → most recent filename (or "empty").
For Design/: list the most recent 3 Carousel folders (or "none").

If the most recent audit file exists, read the first 50 lines to extract the SEO health score.
If a `reports/MONTHLY-REPORT-*.md` file exists, note the most recent month.

---

## Step 4 — Check credentials

Replace `{GOOGLE_KEY_ENV}` and `{TOKEN_ENV_VAR}` with the actual env var names from CLAUDE.md.

```bash
echo "GOOGLE_KEY: ${!GOOGLE_KEY_ENV:+SET}"
echo "GOOGLE_FILE: $([ -f "${!GOOGLE_KEY_ENV:-}" ] && echo EXISTS || echo MISSING)"
echo "PLATFORM_TOKEN: ${!TOKEN_ENV_VAR:+SET}"
```

Report: `[SET ✓]` / `[NOT SET ✗]` / `[SET but file not found ✗]` for each.

---

## Step 5 — Produce Client Briefing

Output in this exact format:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Client Briefing — {CLIENT_NAME}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Client:    {CLIENT_NAME} | {WEBSITE} | {MARKET}
Niche:     {NICHE}
Platform:  {PLATFORM} — {HANDLE}
Outputs:   Content & SEO/outputs/{PLATFORM}-{HANDLE}/

Context loaded:
  client-info.md     [loaded / MISSING]
  current-data.md    [loaded / MISSING]
  strategy.md        [loaded / MISSING]
  tone-guide.md      [loaded / MISSING]
  personal-info.md   [loaded / MISSING — optional]

SEO history:
┌──────────────────┬────────────────────────────────────────┬────────────────┐
│ Folder           │ Most Recent File                       │ Date           │
├──────────────────┼────────────────────────────────────────┼────────────────┤
│ audit/           │ AUDIT-YYYY-MM-DD.md                   │ YYYY-MM-DD     │
│ research/        │ GSC-REPORT-YYYY-MM-DD.md              │ YYYY-MM-DD     │
│ implementation/  │ IMPLEMENTATION-PLAN-YYYY-MM-DD.md     │ YYYY-MM-DD     │
│ keywords/        │ KEYWORDS-YYYY-MM-DD.md                │ YYYY-MM-DD     │
│ blog-plans/      │ BLOG-PLAN-YYYY-MM-DD.md               │ YYYY-MM-DD     │
│ blogs/           │ [post-slug].html                       │ YYYY-MM-DD     │
│ reports/         │ MONTHLY-REPORT-YYYY-MM.md             │ YYYY-MM        │
└──────────────────┴────────────────────────────────────────┴────────────────┘
[Show "No outputs yet" if folder is empty or missing]

Last SEO score:   [N/100 from most recent audit, or "not available"]
Active campaign:  [Month N of X — from most recent MONTHLY-REPORT, or "none"]

Credentials:
  {GOOGLE_KEY_ENV}:   [SET ✓ / NOT SET ✗ / SET but file not found ✗]
  {TOKEN_ENV_VAR}:    [SET ✓ / NOT SET ✗]

Voice & tone:
[1–2 sentence summary from CLAUDE.md Voice & Tone section]

Available commands for {PLATFORM}:
  /ai-seo-pipeline          Full automation (3/6/12 months)
  /monthly-seo-run          One-shot monthly cycle
  /seo-implementation-plan  Build plan only (no execution)
  /seo-final-report         End-of-engagement report
  /3blog-pipeline           Write 3 blogs → push as drafts
  /{PLATFORM}-onpage-implement  Execute on-page changes via {PLATFORM} API
  /carousel                 Instagram carousel → HTML preview + PNG slides

What's pending:
[If active campaign: "Campaign running — Month N. Next scheduled: blogs {DATE}, on-page review {DATE}"]
[If SEO plan exists: "Last plan: IMPLEMENTATION-PLAN-YYYY-MM-DD.md — review outstanding items"]
[If no plan exists: "No SEO plan yet — run /seo-implementation-plan to start"]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After the briefing, say:

> Ready. What would you like to work on for {CLIENT_NAME}?

---

## Notes

- If any credential is NOT SET: remind the user to add it to `~/.zshrc`, run `source ~/.zshrc`, restart Claude Code
- If context files are MISSING: run `/onboard` from the agency root to auto-populate from the live site, or fill manually
- Platform routing: all CMS skills read the `CMS:` value from `## Platform` in CLAUDE.md:
  - `Shopline` → REST API + `SHOPLINE_{CLIENT}_TOKEN`
  - `Webflow` → Data API + MCP + `WEBFLOW_{CLIENT}_TOKEN`
  - `WordPress` → WP REST API + `WP_{CLIENT}_TOKEN` (preview)
