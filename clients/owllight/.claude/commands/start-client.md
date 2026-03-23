# /start-client

Load all client context and produce a Client Briefing for this session.

Run this at the start of every Owllight session so Claude knows exactly
where this client is in their SEO journey and what's pending.

---

## Step 1 — Read client configuration

Read `CLAUDE.md` and note:
- Client: Owllight Sleep | owllight-sleep.com | Singapore | Mattress / sleep / back care
- Platform: Shopline — owllight-sleep
- Outputs path: `Content & SEO/outputs/shopline-owllight-sleep/`
- Credentials env var: `OWLLIGHT_GOOGLE_KEY`
- Token env var: `SHOPLINE_OWLLIGHT_TOKEN`

---

## Step 2 — Read all context files

Read each file if it exists. Skip silently if absent — but note it as missing in the briefing.

- `context/client-info.md` — brand, products, competitors, audience
- `context/current-data.md` — live metrics, web assets, baseline data
- `context/strategy.md` — content & growth strategy, current focus
- `context/personal-info.md` — founder voice, values (optional)

---

## Step 3 — Scan SEO output history

```bash
ls "Content & SEO/outputs/shopline-owllight-sleep/" 2>/dev/null || echo "NO_OUTPUTS_YET"
ls "Content & SEO/outputs/shopline-owllight-sleep/audit/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/shopline-owllight-sleep/research/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/shopline-owllight-sleep/implementation/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/shopline-owllight-sleep/blogs/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/shopline-owllight-sleep/blog-plans/" 2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/shopline-owllight-sleep/keywords/" 2>/dev/null | sort -r | head -1
```

For each subfolder with files, record the most recent filename. If the most recent audit file exists, read its first 50 lines to extract the SEO health score.

---

## Step 4 — Check credentials

```bash
echo "OWLLIGHT_GOOGLE_KEY: ${OWLLIGHT_GOOGLE_KEY:+SET}"
OWLLIGHT_JSON="${OWLLIGHT_GOOGLE_KEY:-}"
echo "JSON file: $([ -f "$OWLLIGHT_JSON" ] && echo EXISTS || echo MISSING)"
echo "SHOPLINE_OWLLIGHT_TOKEN: ${SHOPLINE_OWLLIGHT_TOKEN:+SET}"
```

---

## Step 5 — Produce Client Briefing

Output this structured briefing:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Client Briefing — Owllight Sleep
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Client:    Owllight Sleep | owllight-sleep.com | Singapore
Niche:     Mattress / sleep health / clinical back care
Platform:  Shopline — owllight-sleep
Outputs:   Content & SEO/outputs/shopline-owllight-sleep/

Context loaded:
  client-info.md     [loaded / MISSING]
  current-data.md    [loaded / MISSING]
  strategy.md        [loaded / MISSING]
  personal-info.md   [loaded / MISSING — optional]

SEO history:
┌──────────────────┬────────────────────────────────────────┬────────────────┐
│ Folder           │ Most Recent File                       │ Date           │
├──────────────────┼────────────────────────────────────────┼────────────────┤
│ audit/           │ [filename or "empty"]                  │ [date or —]    │
│ research/        │ [filename or "empty"]                  │ [date or —]    │
│ implementation/  │ [filename or "empty"]                  │ [date or —]    │
│ blogs/           │ [filename or "empty"]                  │ [date or —]    │
└──────────────────┴────────────────────────────────────────┴────────────────┘

Last SEO score: [N/100 from most recent audit, or "not available"]

Credentials:
  OWLLIGHT_GOOGLE_KEY:    [SET ✓ / NOT SET ✗ / SET but file not found ✗]
  SHOPLINE_OWLLIGHT_TOKEN: [SET ✓ / NOT SET ✗]

Voice & tone:
Clinical credibility with warmth. Focus on sleep science, back care expertise,
and Singapore context. Not just a mattress brand — a sleep health solution.

What's pending:
[If SEO plan exists: "Last plan: SEO-PLAN-YYYY-MM-DD.md — review outstanding items before next cycle"]
[If no plan exists: "No SEO plan yet — run /shopline-onpage-implement to start the full pipeline"]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After the briefing, say:

> Ready. What would you like to work on for Owllight Sleep?

---

## Notes

- If any credential is NOT SET, add it to `~/.zshrc` and restart terminal
- Orchestrator for this platform: `/shopline-onpage-implement`
- Full pipeline: `/seo-blog-implement owllight-sleep.com`
- `context/current-data.md` and `context/strategy.md` are missing — fill these to improve briefing accuracy
