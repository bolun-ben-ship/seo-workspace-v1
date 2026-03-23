# /prime

Deep context loading for intensive work sessions. Reads everything — all context files,
full recent outputs, tone guide, strategy, and current metrics — so Claude has a complete
working picture of the client before any task begins.

Use `/start-client` for quick session orientation.
Use `/prime` before deep work: writing campaigns, complex SEO planning, multi-session
strategy, or any task where incomplete context would cause mistakes.

---

## Step 1 — Read client configuration

Read `CLAUDE.md` in full. Extract and hold in memory:
- Client name, website, market, niche
- Platform (CMS), handle, access token env var
- WORKSPACE_ROOT
- Outputs path
- Analytics IDs and credential env var
- All context loading rules
- Voice & tone summary
- All commands

---

## Step 2 — Deep-read ALL context files

Read each file in **full** — do not skim or summarise prematurely. Load the raw content
completely before synthesising.

```
context/client-info.md       — brand, products/services, competitors, target audience
context/tone-guide.md        — brand voice, writing rules, what to avoid
context/strategy.md          — content & growth strategy, current focus areas
context/personal-info.md     — founder voice, personal values, POV (if exists)
context/current-data.md      — live metrics, web assets, baselines, market priorities
```

Note which files are present and which are missing. Missing files = blind spots; flag them
at the end of the brief.

---

## Step 3 — Deep-scan all output history

Replace `{PLATFORM}` and `{HANDLE}` with values from CLAUDE.md.

### List all output folders

```bash
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/" 2>/dev/null || echo "NO_OUTPUTS_YET"
```

### Most recent file in each subfolder

```bash
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/audit/"          2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/research/"        2>/dev/null | sort -r | head -3
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/implementation/"  2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/keywords/"        2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/blog-plans/"      2>/dev/null | sort -r | head -1
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/blogs/"           2>/dev/null | sort -r | head -5
ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/reports/"         2>/dev/null | sort -r | head -3
ls "Design/" 2>/dev/null | sort -r | head -3
```

### Read the key documents in full (or first 150 lines if very large)

**Most recent audit** — read it:
```bash
cat "Content & SEO/outputs/{PLATFORM}-{HANDLE}/audit/$(ls Content\ \&\ SEO/outputs/{PLATFORM}-{HANDLE}/audit/ 2>/dev/null | sort -r | head -1)" 2>/dev/null | head -150
```

**Most recent implementation plan** — read it:
```bash
cat "Content & SEO/outputs/{PLATFORM}-{HANDLE}/implementation/$(ls Content\ \&\ SEO/outputs/{PLATFORM}-{HANDLE}/implementation/ 2>/dev/null | sort -r | grep IMPLEMENTATION | head -1)" 2>/dev/null | head -150
```

**Most recent blog plan** — read it in full:
```bash
cat "Content & SEO/outputs/{PLATFORM}-{HANDLE}/blog-plans/$(ls Content\ \&\ SEO/outputs/{PLATFORM}-{HANDLE}/blog-plans/ 2>/dev/null | sort -r | head -1)" 2>/dev/null
```

**Most recent keyword file** — read it in full:
```bash
cat "Content & SEO/outputs/{PLATFORM}-{HANDLE}/keywords/$(ls Content\ \&\ SEO/outputs/{PLATFORM}-{HANDLE}/keywords/ 2>/dev/null | sort -r | head -1)" 2>/dev/null
```

**Blog titles already written** — extract H1s / titles from recent blogs to avoid duplication:
```bash
for f in $(ls "Content & SEO/outputs/{PLATFORM}-{HANDLE}/blogs/" 2>/dev/null | sort -r | head -5); do
  echo "--- $f"
  grep -m1 "<title>\|<h1>" "Content & SEO/outputs/{PLATFORM}-{HANDLE}/blogs/$f" 2>/dev/null || echo "$f"
done
```

**Most recent monthly report** (if exists):
```bash
cat "Content & SEO/outputs/{PLATFORM}-{HANDLE}/reports/$(ls Content\ \&\ SEO/outputs/{PLATFORM}-{HANDLE}/reports/ 2>/dev/null | sort -r | head -1)" 2>/dev/null | head -100
```

---

## Step 4 — Check credentials

```bash
echo "GOOGLE_KEY: ${!{GOOGLE_KEY_ENV}:+SET}"
echo "GOOGLE_FILE: $([ -f "${!{GOOGLE_KEY_ENV}:-}" ] && echo EXISTS || echo MISSING)"
echo "PLATFORM_TOKEN: ${!{TOKEN_ENV_VAR}:+SET}"
```

---

## Step 5 — Synthesise and output Prime Brief

Output in this exact format:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRIME BRIEF — {CLIENT_NAME}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CLIENT
  Name:       {CLIENT_NAME}
  Site:       {WEBSITE}
  Market:     {MARKET} — {NICHE}
  Platform:   {PLATFORM} / {HANDLE}

CONTEXT STATUS
  client-info.md     [loaded / MISSING]
  tone-guide.md      [loaded / MISSING]
  strategy.md        [loaded / MISSING]
  personal-info.md   [loaded / MISSING — optional]
  current-data.md    [loaded / MISSING]

BRAND SNAPSHOT
  [2–3 sentence synthesis of who this client is, what they sell, who they serve,
   and what makes them distinct — drawn from client-info.md]

VOICE & TONE
  [3–5 bullet points of the most important writing rules from tone-guide.md.
   These are the rules that matter most for any content task.]

STRATEGY FOCUS
  [Current strategic priorities from strategy.md — what we're pushing, what we're
   building toward, what channels matter most right now]

SEO POSITION
  Last audit:        {date} — score: {N}/100 (or "not run yet")
  Top issues:        [top 3 issues from most recent audit, one line each]
  Last plan:         {filename} — [1 line summary of what was proposed]
  Pending items:     [any unresolved items from the plan, or "none identified"]

KEYWORD TERRITORY
  [If keyword file exists: list the top 5–8 primary keywords we're targeting]
  [If not: "No keyword research on file — run /gsc-report or keyword research first"]

CONTENT HISTORY
  Blogs written:     {N} total
  Recent titles:     [list last 3–5 blog titles — these topics should not be repeated]
  Last blog plan:    {date} — [topic clusters planned]
  Active campaign:   [Month N of X / none]

CREDENTIALS
  {GOOGLE_KEY_ENV}:   [SET ✓ / NOT SET ✗]
  {TOKEN_ENV_VAR}:    [SET ✓ / NOT SET ✗]

BLIND SPOTS
  [List any missing context files, gaps in data, or things that would affect
   the quality of work in this session. Be specific. E.g.:
   — tone-guide.md is missing — writing tasks will use best judgement
   — No keyword research on file — SEO targeting will be based on audit alone
   — GA4 credentials not set — cannot pull analytics data]

READY FOR
  [What this prime session is well-equipped to handle given the context loaded.
   E.g.: "Blog writing, content strategy, on-page SEO planning.
   NOT ready for: GA4 pulls (credentials missing), keyword research (no GSC data)."]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Context fully loaded. What are we working on?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Notes

- If a context file is missing, do not skip it silently — flag it as a blind spot.
- If output history is empty, say so clearly and suggest what to run first.
- The Prime Brief is a working document, not a summary. It should contain enough
  detail that any subsequent task in this session can proceed without re-reading files.
- After outputting the brief, Claude should hold all loaded context in active memory
  for the rest of the session.
