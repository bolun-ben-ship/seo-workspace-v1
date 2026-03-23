# /start-client

Load all client context and produce a Client Briefing for this session.

Run this at the start of every AEXPHL session so Claude knows exactly
where this client is in their SEO journey and what's pending.

---

## Step 1 — Read client configuration

Read `CLAUDE.md` and note:
- Client: Aussie Expat Home Loans (AEXPHL) | aexphl.com | Australian expats globally
- Platform: Webflow — aexphl
- Outputs path: `Content & SEO/outputs/webflow-aexphl/`
- Credentials env var: `AEXPHL_GOOGLE_KEY`
- Token env var: `WEBFLOW_AEXPHL_TOKEN`
- MCP: Webflow MCP must be configured via `.mcp.json` for CMS execution

---

## Step 2 — Read all context files

Read each file if it exists. Skip silently if absent — but note it as missing in the briefing.

- `context/client-info.md` — brand, services, competitors, audience
- `context/current-data.md` — live metrics, web assets, baseline data
- `context/strategy.md` — content-led organic growth + GEO strategy
- `context/personal-info.md` — Tim's founder voice, values, the "Expat Support Method"

---

## Step 3 — Scan SEO output history

```bash
ls "Content & SEO/outputs/webflow-aexphl/" 2>/dev/null || echo "NO_OUTPUTS_YET"
ls "Content & SEO/outputs/webflow-aexphl/audit/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/webflow-aexphl/research/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/webflow-aexphl/implementation/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/webflow-aexphl/blogs/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/webflow-aexphl/blog-plans/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/webflow-aexphl/keywords/" 2>/dev/null | sort -r | head -1
```

For each subfolder with files, record the most recent filename. If the most recent audit file exists, read its first 50 lines to extract the SEO health score.

---

## Step 4 — Check credentials

```bash
echo "AEXPHL_GOOGLE_KEY: ${AEXPHL_GOOGLE_KEY:+SET}"
AEXPHL_JSON="${AEXPHL_GOOGLE_KEY:-}"
echo "JSON file: $([ -f "$AEXPHL_JSON" ] && echo EXISTS || echo MISSING)"
echo "WEBFLOW_AEXPHL_TOKEN: ${WEBFLOW_AEXPHL_TOKEN:+SET}"
```

Also check MCP is available — look for Webflow MCP tools (prefixed with the Webflow MCP namespace) in the current session. If not connected, note it in the briefing.

---

## Step 5 — Produce Client Briefing

Output this structured briefing:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Client Briefing — Aussie Expat Home Loans (AEXPHL)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Client:    Aussie Expat Home Loans | aexphl.com | Australian expats globally
Niche:     Specialist mortgage brokerage — Australian expats earning foreign currency
Platform:  Webflow — aexphl
Outputs:   Content & SEO/outputs/webflow-aexphl/
MCP:       Webflow MCP [connected ✓ / not connected ✗ — needed for CMS execution]

Context loaded:
  client-info.md     [loaded / MISSING]
  current-data.md    [loaded / MISSING]
  strategy.md        [loaded / MISSING]
  personal-info.md   [loaded / MISSING]

SEO history:
┌──────────────────┬────────────────────────────────────────┬────────────────┐
│ Folder           │ Most Recent File                       │ Date           │
├──────────────────┼────────────────────────────────────────┼────────────────┤
│ audit/           │ [filename or "empty"]                  │ [date or —]    │
│ research/        │ [filename or "empty"]                  │ [date or —]    │
│ implementation/  │ [filename or "empty"]                  │ [date or —]    │
│ blogs/           │ [filename or "empty"]                  │ [date or —]    │
│ blog-plans/      │ [filename or "empty"]                  │ [date or —]    │
│ keywords/        │ [filename or "empty"]                  │ [date or —]    │
└──────────────────┴────────────────────────────────────────┴────────────────┘

Last SEO score: [N/100 from most recent audit, or "not available"]

Credentials:
  AEXPHL_GOOGLE_KEY:    [SET ✓ / NOT SET ✗ / SET but file not found ✗]
  WEBFLOW_AEXPHL_TOKEN: [SET ✓ / NOT SET ✗]

Voice & tone (Tim's voice):
Integrity-first, relationship-driven, anti-fear-marketing. Clarity over complexity.
Never generic broker tone. Leads with lived expat experience and honest financial advice.

Strategy focus:
Two parallel tracks — (1) topical authority by geography (SG, HK, Dubai, SEA, ROW)
and (2) GEO / AI citation readiness (ChatGPT, Perplexity, Google AI Overviews).

What's pending:
[If SEO plan exists: "Last plan: SEO-PLAN-YYYY-MM-DD.md — review outstanding items before next cycle"]
[If no plan exists: "No SEO plan yet — run /webflow-onpage-implement to start the full pipeline"]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After the briefing, say:

> Ready. What would you like to work on for AEXPHL?

---

## Notes

- If Webflow MCP is not connected: open `.mcp.json` in this folder and ensure `WEBFLOW_AEXPHL_TOKEN` is set in `~/.zshrc`, then restart Claude Code
- If any credential is NOT SET: add it to `~/.zshrc` and restart terminal
- Orchestrator for this platform: `/webflow-onpage-implement`
- Full pipeline: `/seo-blog-implement aexphl.com`
- Tim's personal voice guidelines are in `context/personal-info.md` — always load before writing any content
