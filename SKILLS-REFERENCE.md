# RightClick:AI — Skills Reference

> Master reference for all skills, orchestrators, agents, subagents, and commands.
> Source of truth: `seo-workflow/` — deploy with `bash seo-workflow/install.sh`
> Last updated: 2026-03-23 (24 skills: 4 orchestrators, 2 data, 1 research, 1 routing plugin, 13 specialists, 1 design, 1 planning, 1 reporting)

---

## ⚠️ MASTER FILE INTEGRITY RULE — NON-NEGOTIABLE

```
╔══════════════════════════════════════════════════════════════════════╗
║  EVERY TIME ANY SKILL FILE IS CREATED, CHANGED, OR RENAMED:         ║
║                                                                      ║
║  STEP 1 — Edit the skill                                             ║
║    seo-workflow/{skill}/SKILL.md  ← ONLY edit here                  ║
║    NEVER edit directly in ~/.claude/skills/                          ║
║                                                                      ║
║  STEP 2 — Update ALL of these master files:                          ║
║    ✦ SKILLS-REFERENCE.md (this file) — update the skill entry        ║
║    ✦ seo-workflow/install.sh — add/remove from SKILLS array          ║
║    ✦ client-template/CLAUDE.md — sync commands + output folders      ║
║    ✦ client-template/.claude/commands/start-client.md — sync refs    ║
║    ✦ CLAUDE.md (agency root) — sync commands table                   ║
║    ✦ clients/*/CLAUDE.md — sync commands in ALL client workspaces    ║
║                                                                      ║
║  STEP 3 — Deploy                                                     ║
║    bash seo-workflow/install.sh                                      ║
║    All skills must show ✓                                            ║
║                                                                      ║
║  STEP 4 — Integrity scan (run after every round of changes)          ║
║    Verify: skills in install.sh == folders in seo-workflow/          ║
║    Verify: SKILLS-REFERENCE.md has an entry for every skill          ║
║    Verify: client-template commands match current skill names        ║
║    Verify: no orphaned skill folders in seo-workflow/                ║
║                                                                      ║
║  STEP 5 — EXPLICITLY CONFIRM to the user after EVERY round:         ║
║    "SKILLS-REFERENCE.md updated ✅"                                  ║
║    "client-template updated ✅"                                      ║
║    "install.sh deployed — N/N skills ✅"                             ║
║    "Integrity scan passed ✅"                                        ║
║                                                                      ║
║  NO EXCEPTIONS. Even for a one-line change.                          ║
║  This workspace must be 100% accurate and transfer-ready.            ║
╚══════════════════════════════════════════════════════════════════════╝
```

This rule applies to ALL Claude instances working in this workspace.
Partial updates are worse than no update — they create silent drift.

---

## How to Use This File

- **Running a skill:** Type the skill name as a slash command or describe your task — Claude routes to the right skill
- **Editing a skill:** Edit in `seo-workflow/{skill-name}/SKILL.md` → run install → update this file → confirm to user
- **Adding a skill:** Create `seo-workflow/{new-skill}/SKILL.md` → add to `SKILLS` array in `install.sh` → run install → update this file → update all relevant `CLAUDE.md` files → confirm to user

---

## Platform Routing — Master Reference

All skills that touch a CMS (blog publishing, on-page SEO execution) route through this table.
Skills read `CMS:` from `## Platform` in the client's `CLAUDE.md`.

| Platform value | PLATFORM token | Blog publish method | On-page execute skill | Credential env var |
|---|---|---|---|---|
| `Shopline` | `shopline` | REST API `published: false` | `shopline-onpage-implement` | `SHOPLINE_{CLIENT}_TOKEN` |
| `Webflow` | `webflow` | MCP `isDraft: true` | `webflow-onpage-implement` | `WEBFLOW_{CLIENT}_TOKEN` + MCP |
| `WordPress` | `wordpress` | WP REST API `status: draft` | `wordpress-onpage-implement` *(preview)* | `WP_{CLIENT}_TOKEN` |
| anything else | `unknown` | Save HTML locally | Plan only — no execution | None required |

**Skills using this routing:** `ai-seo-pipeline`, `monthly-seo-run`, `3blog-pipeline`, `seo-implementation-plan`

**Adding a new platform:** Add a row here → add execution blocks in each of the 4 skills above → create `{platform}-onpage-implement` skill → add to `install.sh` → confirm this file updated.

---

## Orchestrators — Full End-to-End Pipelines

Run from the **client workspace** (`clients/{domain}/`).

### `/ai-seo-pipeline` ⭐ Flagship Automation
**What it does:** Full long-term SEO automation. Platform-aware — auto-detects Shopline, Webflow, or WordPress from `CLAUDE.md` and routes all blog publishing and on-page execution to the correct API. Runs a guided questionnaire, executes the complete initial implementation (audit + research + on-page changes + 5 blog drafts), then schedules weekly blog generation and monthly on-page reviews for the full engagement.
**Platform detection:** Reads `CMS:` field from `## Platform` in `CLAUDE.md` → routes to Shopline REST API, Webflow Data API + MCP, or WordPress REST API. Unknown platforms produce plans + local HTML only.
**Questionnaire asks:** Duration (3/6/12 months), blog destination (platform-specific collection/category picker), topic focus, approval mode.
**Weekly (automated):** 5 blog posts written + pushed to {CMS} as drafts.
**Monthly (automated):** Fresh GSC/GA4 + on-page plan + approval gate + execute changes + monthly report.
**Reports:** Week 1 report, monthly reports, final engagement report.
**Extensible:** Adding a new platform = add a row to the routing table + new execution blocks.
**Uses:** Claude Code scheduled tasks.
**Credentials needed:** Platform token (`SHOPLINE_*` / `WEBFLOW_*` / `WP_*`) + `{CLIENT}_GOOGLE_KEY` + `OPENAI_API_KEY`.
**Output files:** All subfolders + `reports/WEEK-1-REPORT-*.md`, `reports/MONTHLY-REPORT-*.md`.

---

### `/monthly-seo-run` ⭐ Monthly One-Shot
**What it does:** The complete monthly SEO cycle — run it once, get everything for that month.
**Phases:**
- Phase 0: Load historical context (prior reports, resolved items, blog history)
- Phase 1: SEO audit (skips if recent audit exists)
- Phase 2a/2b/2c: GSC + GA4 + market research (last30days) — all in parallel
- Phase 3a: Keyword research (4 tables)
- Phase 3b: SEO plan (on-page changes — before/after table)
- Phase 3c: Blog plan (3 posts — no overlap with prior topics)
- Phase 4: Write 3 blog posts (applies tone-guide.md if present)
- ⏸ **Approval gate**
- Phase 5a: Post blogs to CMS (platform-routed)
- Phase 5b: Apply on-page changes via platform API (platform-routed)
- Phase 5c: Save before/after snapshot
- Phase 6: Full monthly POST-IMPLEMENTATION-AUDIT report
**Platform-aware:** Reads `CMS:` from `CLAUDE.md` → routes Phase 5 to Shopline REST API, Webflow Data API + MCP, or WordPress REST API. Unknown platforms complete through Phase 4 only.
**Credentials needed:** `{CLIENT}_GOOGLE_KEY` + platform token (see Platform Routing table above).

---

### `/shopline-onpage-implement`
**What it does:** End-to-end on-page SEO pipeline for Shopline stores.
**Phases:** Historical context → SEO Audit → GSC/GA4 → Shopline store snapshot → market research (last30days) → **Implementation Plan with full before/after table** → **Approval gate** → Execute on-page changes via API → Post-implementation report.
**Before/after coverage:** YES — every proposed change shows current value → proposed value before any execution. Phase 3 produces the full before/after table; Phase 5 executes; Phase 6 saves the snapshot.
**What it changes:** Blog post + product SEO titles, meta descriptions — all via Shopline Admin REST API.
**What it cannot change:** Theme pages, navigation, robots.txt, URL slugs on live pages (flagged as Category G — manual).
**Credentials needed:** `SHOPLINE_{CLIENT}_TOKEN`. Optionally: `{CLIENT}_GOOGLE_KEY`.

---

### `/webflow-onpage-implement`
**What it does:** End-to-end on-page SEO pipeline for Webflow sites.
**Phases:** Historical context → SEO Audit → GSC/GA4 → Webflow data fetch → market research → **Implementation Plan with full before/after table** → **Approval gate** → Execute via Webflow Data API + MCP → Post-implementation report.
**Before/after coverage:** YES — same structure as Shopline orchestrator.
**What it changes:** Page SEO title, meta description, noindex settings.
**Credentials needed:** `WEBFLOW_{CLIENT}_TOKEN` + Webflow MCP connected. Optionally: `{CLIENT}_GOOGLE_KEY`.

---

### `/3blog-pipeline`
**What it does:** Full 7-phase content + SEO pipeline for any platform. Writes 3 blog posts and pushes them to CMS as drafts.
**Phases:** Historical context → SEO Audit → Social trends (last30days) → GSC/GA4 → SEO Plan → Keyword Research → Blog Plan → Write 3 blog posts → **Push to CMS as drafts** (platform-routed).
**Platform-aware:** Reads `CMS:` from `CLAUDE.md` → routes blog push to Shopline REST API, Webflow MCP, or WordPress REST API. Unknown platforms save HTML locally.
**Does NOT execute on-page title/meta changes** — use the matching `{platform}-onpage-implement` skill for that.
**Credentials needed:** See Platform Routing table above.
**Output files:** All 7 output folders populated.
**Renamed from:** `seo-blog-implement` (legacy — removed from install).

---

## Global Plan & Report Commands

These are standalone commands that work from any client workspace.

### `/seo-implementation-plan`
**What it does:** Builds a complete SEO implementation plan — stops at the plan, never executes.
**Phases:** Historical context → SEO Audit (if needed) → GSC + GA4 + last30days (parallel) → before/after implementation plan for every proposed change → save → present for approval.
**Platform-aware:** Detects platform from `CLAUDE.md` to correctly label Category G manual items and direct user to the right execution skill. Does NOT execute regardless of platform.
**Output:** `implementation/IMPLEMENTATION-PLAN-YYYY-MM-DD.md`
**Use when:** You want a plan before deciding what to implement, or to feed into manual or scheduled execution.
**Does NOT execute.** To execute, run the platform-matching skill: `/shopline-onpage-implement`, `/webflow-onpage-implement`, or `/wordpress-onpage-implement`.

### `/seo-final-report`
**What it does:** Produces a comprehensive end-of-engagement report for any client workspace.
**Loads:** All prior output files across the entire engagement history.
**Compares:** Starting baseline vs current state — SEO score, traffic, rankings, CTR.
**Includes:** All blogs written, all on-page changes executed, all issues resolved, metric movement.
**Output:** `audit/FINAL-REPORT-YYYY-MM-DD.md`
**Use when:** Wrapping up a campaign, engagement period, or automation run.

---

## Standalone Research Skills

### `/gsc-report`
Pull 30-day Google Search Console data. Top queries (impressions, CTR, position), CTR gap opportunities, top pages by clicks.
**Output:** `research/GSC-REPORT-YYYY-MM-DD.md`

### `/ga4-report`
Pull 30-day Google Analytics 4 data. Sessions by channel, top landing pages, bounce rates, organic traffic baseline.
**Output:** `research/GA4-REPORT-YYYY-MM-DD.md`

### `/last30days`
Research any topic across Reddit, X, YouTube, TikTok, Instagram, Hacker News, Polymarket. Produces expert synthesis.
**Invoke as:** `/last30days sleep products mattress`
**Needs:** `OPENAI_API_KEY` + Python scripts from `github.com/mvanhorn/last30days-skill`

---

## SEO Audit Suite (13 Skills + 6 Subagents)

### `/seo-audit`
Full site audit. Crawls up to 500 pages, detects business type, delegates to 6 specialist subagents in parallel, produces 0–100 health score with prioritised action list.
**Output:** `audit/AUDIT-YYYY-MM-DD.md`
**Subagents spawned:** seo-technical, seo-content, seo-schema, seo-sitemap, seo-performance, seo-visual

### `/seo-technical`
Technical SEO: robots.txt, sitemaps, canonicals, redirect chains, Core Web Vitals, security headers, mobile, JS rendering.

### `/seo-content`
E-E-A-T analysis, readability, thin content, duplicate content, AI citation readiness.

### `/seo-schema`
Detect, validate, generate Schema.org structured data (JSON-LD). Article, Product, FAQ, BreadcrumbList, LocalBusiness, Organization, HowTo.

### `/seo-sitemap`
Validate or generate XML sitemaps. Detects missing pages, blocked URLs, orphaned content.

### `/seo-images`
Image SEO: alt text coverage, file sizes, WebP/AVIF formats, responsive images, lazy loading, CLS prevention.

### `/seo-hreflang`
International SEO: validate or generate hreflang tags. Detects missing x-default, incorrect locale codes, circular references.

### `/seo-geo`
AI search optimisation (GEO): AI Overview eligibility, ChatGPT/Perplexity citation signals, `llms.txt` compliance, passage-level citability, brand mention signals.

### `/seo-page`
Deep single-page analysis: title, meta, H1-H6, canonical, OG tags, schema, image alt, links, word count, readability.
**Invoke as:** `/seo-page https://domain.com/page-url`

### `/seo-plan`
Strategic SEO planning. Industry templates, competitive gap analysis, content strategy, 4-week sprint roadmap.

### `/seo-keywords`
4 keyword tables: primary (high-intent), long-tail transactional, long-tail informational, PAA + AI search queries. Competitor keyword gaps.

### `/seo-competitor-pages`
Generate "X vs Y" comparison pages, "alternatives to X" pages, feature matrices, conversion CTAs, schema.

### `/seo-programmatic`
Programmatic SEO strategy: template engines, URL patterns, internal linking automation, thin content safeguards, index bloat prevention.

---

## Content Skills

### `/blog-write` (via seo-and-blog)
Write complete blog articles — answer-first, TL;DR box, sourced statistics, citation capsules, FAQ schema, internal linking.
**Reads:** `context/tone-guide.md` — applies brand voice.
**Output:** `blogs/{post-slug}.html`

### `/blog-calendar` (via seo-and-blog)
28-day blog content calendar. 3 posts spaced ≥7 days apart. Avoids prior topic overlap.
**Output:** `blog-plans/BLOG-PLAN-YYYY-MM-DD.md`

---

## Design Skills

### `/carousel`
Instagram carousel generator. Collects brand details via in-chat questionnaire, auto-detects client logo from `context/` folder, accepts multiple image uploads (base64-embedded), derives a 6-token color palette from a single brand color, generates a branded 7-slide (5–10 configurable) swipeable HTML preview, then exports each slide as a 1080×1350px PNG via Playwright.
**Phases:** Read client context → detect logo → questionnaire → generate HTML → preview & iterate → export PNGs
**Output:** `Design/Carousel-YYYY-MM-DD/carousel.html` + `Design/Carousel-YYYY-MM-DD/slides/slide_N.png`
**Needs:** `playwright` Python package + Chromium (`pip3 install playwright && playwright install chromium`)
**Invoke as:** `/carousel` (questionnaire will ask for topic and all brand details)

---

## Agency Commands (agency root only)

### `/initialise`
Full workspace setup for a new machine. Run once after cloning the repo. Deploys all skills via `install.sh`, checks system tools (python3, node, git), verifies all Python deps (including playwright + Pillow), checks Playwright Chromium, reports every missing env var with the exact `export` line to add to `~/.zshrc`, verifies credential JSON files, checks workspace folder structure. Prints a pass/fail report with numbered fix steps. If everything passes: "READY ✓". If not: numbered action list.
**Run from:** agency root (`RightClickAI-seo-workspace/`)
**When to use:** First time on a new machine, or after pulling major repo changes.

### `/start-agency`
Load agency context and produce Agency Briefing. Reads CLAUDE.md, agency-info.md, agency-strategy.md, clients.md, skills.

### `/onboard domain.com`
Onboard a new client. Scrapes site, asks 4 questions, scaffolds `clients/{domain}/`, updates `clients.md`. Tells you what to add to `~/.zshrc`.

---

## Client Commands (client workspace only)

### `/prime`
Deep context loading for intensive work sessions. Reads ALL context files in full, reads the most recent audit + implementation plan + blog plan + keyword file + monthly report in full, extracts blog titles already written (to prevent repetition), checks credentials, then produces a comprehensive Prime Brief covering: brand snapshot, voice & tone rules, strategy focus, SEO position, keyword territory, content history, blind spots, and what the session is/isn't ready for.
**Use when:** About to do deep work — writing campaigns, complex SEO planning, multi-session strategy, or any task where incomplete context would cause mistakes.
**vs `/start-client`:** start-client = quick orientation (2 min). prime = full context saturation (reads everything).

### `/start-client`
Load full client context and produce Client Briefing. Reads CLAUDE.md, all context files, scans output history, checks credentials.

---

## Subagents (auto-spawned by seo-audit)

| Agent | Role |
|---|---|
| `seo-content` | E-E-A-T analysis, content quality, AI citation readiness |
| `seo-performance` | Core Web Vitals, page speed, CLS, LCP, FID |
| `seo-schema` | Structured data detection and validation |
| `seo-sitemap` | Sitemap structure and coverage |
| `seo-technical` | Crawlability, indexability, redirects, canonicals |
| `seo-visual` | Screenshots, above-fold analysis, mobile rendering |

---

## Skill Dependency Map

```
ai-seo-pipeline (long-term automation — platform-aware)
  └─ detects platform from CLAUDE.md → shopline | webflow | wordpress | unknown
  └─ initial run uses → seo-implementation-plan, blog-write × 5
  └─ blog push routes → Shopline REST API | Webflow MCP | WordPress REST API | local HTML
  └─ on-page routes   → shopline-onpage-implement | webflow-onpage-implement | wordpress-onpage-implement (future)
  └─ monthly uses     → seo-implementation-plan + platform execute
  └─ end uses         → seo-final-report
  └─ scheduling via   → Claude Code scheduled tasks

monthly-seo-run (one-shot monthly)
  └─ uses → seo-audit, gsc-report, ga4-report, last30days, seo-keywords, seo-plan, blog-calendar, blog-write
  └─ executes → Shopline Admin REST API (or Webflow Data API + MCP)

shopline-onpage-implement
  └─ uses → seo-audit, gsc-report, ga4-report, last30days, seo-plan
  └─ executes → Shopline Admin REST API

webflow-onpage-implement
  └─ uses → seo-audit, gsc-report, ga4-report, last30days, seo-plan
  └─ executes → Webflow Data API + MCP

3blog-pipeline (formerly seo-blog-implement)
  └─ uses → seo-audit, gsc-report, ga4-report, last30days, seo-plan, seo-keywords, blog-calendar, blog-write
  └─ CMS push → Shopline API (drafts) or Webflow MCP (drafts)

seo-implementation-plan
  └─ uses → seo-audit, gsc-report, ga4-report, last30days
  └─ stops at plan — does NOT execute

seo-final-report
  └─ uses → all prior output files + gsc-report + ga4-report

seo-audit
  └─ spawns → seo-technical, seo-content, seo-schema, seo-sitemap, seo-performance, seo-visual

seo-and-blog (27 sub-skill router)
  └─ routes to → all individual SEO + blog skills
```

---

## Prerequisites Checklist

```bash
bash seo-workflow/install.sh        # install + audit
bash seo-workflow/install.sh --audit  # audit only
```

| Requirement | Used by |
|---|---|
| `SHOPLINE_{CLIENT}_TOKEN` env var | shopline-onpage-implement, 3blog-pipeline, ai-seo-pipeline |
| `WEBFLOW_{CLIENT}_TOKEN` env var | webflow-onpage-implement |
| `{CLIENT}_GOOGLE_KEY` env var → path to JSON key file | gsc-report, ga4-report, all orchestrators |
| `OPENAI_API_KEY` env var | last30days |
| Webflow MCP connected (`.mcp.json`) | webflow-onpage-implement |
| Python packages: `google-analytics-data`, `google-api-python-client`, `google-auth`, `requests` | gsc-report, ga4-report |
| Python scripts from `github.com/mvanhorn/last30days-skill` | last30days |
| `python3`, `node`, `npx`, `pip3` in PATH | various |
