# {CLIENT_NAME} — Claude Workspace

## Client
- **Name:** {CLIENT_NAME}
- **Website:** {WEBSITE_URL}
- **Market:** {MARKET}
- **Niche:** {NICHE}

## Platform
- **CMS:** {shopline | webflow | wordpress}
- **Store / Site handle:** `{HANDLE}`
- **Access token:** `${PLATFORM}_{CLIENT_SLUG}_TOKEN` (env var — never hardcode)
- **API base:** {API_BASE_URL}

> ⚠️ The `CMS:` value above is read by ALL skills to route blog publishing and on-page execution.
> Must be exactly: `Shopline`, `Webflow`, or `WordPress` — case-sensitive.
> See Platform Routing table in `SKILLS-REFERENCE.md` for what each value triggers.

## Workspace
- **WORKSPACE_ROOT:** `~/Antigravity/RightClickAI-seo-workspace/clients/{CLIENT_SLUG}`
- **Outputs:** `Content & SEO/outputs/{platform}-{handle}/`

## Commands

| Command | What it does |
|---|---|
| `/prime` | Deep context loading — reads all files + full output history, produces comprehensive Prime Brief for intensive work |
| `/start-client` | Loads all client context and produces a Client Briefing — run at the start of every session |
| `/ai-seo-pipeline` | Full automation (3/6/12 months) — guided questionnaire → initial run → weekly blogs → monthly on-page → reports |
| `/3blog-seo-first-run` | Full run — audit → research → plan → write 3 blogs → approve → execute on-page changes → before/after report |
| `/seo-implementation-plan` | Build a complete before/after SEO plan (no execution) — global, works on any platform |
| `/seo-final-report` | End-of-engagement comprehensive report — global, works on any platform |
| `/shopline-onpage-implement` | On-page changes via Shopline API — Shopline clients only |
| `/webflow-onpage-implement` | On-page changes via Webflow API + MCP — Webflow clients only |
| `/wordpress-onpage-implement` | On-page changes via WordPress REST API — WordPress clients only (preview) |
| `/carousel` | Instagram carousel generator — branded 7-slide HTML preview + export as PNGs |

## Analytics
- GSC site: {GSC_SITE_URL or "not yet configured"}
- GA4 property ID: {GA4_PROPERTY_ID or "not yet configured"}
- Google credentials: `{CLIENT_SLUG_UPPER}_GOOGLE_KEY` (env var → path to JSON key file)
  - JSON file lives at: `clients/{CLIENT_SLUG}/{client-slug}-*.json` (gitignored)
  - Set in `~/.zshrc`: `export {CLIENT_SLUG_UPPER}_GOOGLE_KEY="$HOME/.../clients/{CLIENT_SLUG}/{filename}.json"`

---

## Output Folder Structure

```
Content & SEO/outputs/{platform}-{handle}/
├── audit/           ← AUDIT-*.md, POST-IMPLEMENTATION-AUDIT-*.md, FINAL-REPORT-*.md
├── research/        ← GSC-REPORT-*.md, GA4-REPORT-*.md, SOCIAL-TRENDS-*.md
├── keywords/        ← KEYWORDS-*.md
├── implementation/  ← IMPLEMENTATION-PLAN-*.md, SEO-PLAN-*.md, SNAPSHOT-*.md
├── blog-plans/      ← BLOG-PLAN-*.md
├── blogs/           ← *.html blog posts
└── reports/         ← WEEK-1-REPORT-*.md, MONTHLY-REPORT-*.md (from ai-seo-pipeline)

Design/
└── Carousel-YYYY-MM-DD/   ← /carousel output
    ├── carousel.html       ← browser preview
    ├── generate.py
    ├── export.py
    └── slides/             ← slide_1.png … slide_N.png (1080×1350px)
```

---

## Context Loading Rules

When a task involves SEO, content, marketing, copywriting, or strategy — load these before responding:

| File | When to read |
|---|---|
| `context/client-info.md` | Any business or client-facing task |
| `context/tone-guide.md` | Any writing task — blog posts, copy, emails, CTAs |
| `context/strategy.md` | Content, SEO, growth, or channel strategy tasks |
| `context/personal-info.md` | Copywriting, brand voice, founder POV, tone (if exists) |
| `context/current-data.md` | Stats, web assets, market priorities, baselines |

Read only the files relevant to the task — not all every time.

---

## Voice & Tone
{Describe the brand voice, tone, audience, and any hard rules for copy}

---

## ⚠️ Maintain This File — ALL MASTER FILES

After ANY change to this client workspace, check ALL of the following and update immediately:

### Master files that must stay in sync

| Master File | What it controls | When to update |
|---|---|---|
| **This file** (`CLAUDE.md`) | Client config, commands, context rules | Any structural change to this workspace |
| **`SKILLS-REFERENCE.md`** (agency root) | Full skill library reference | Any skill created, renamed, or changed |
| **`client-template/CLAUDE.md`** (agency root) | Template for new clients | Any time THIS file's structure changes |
| **`client-template/.claude/commands/start-client.md`** | Template briefing command | Any time start-client logic changes |
| **`seo-workflow/install.sh`** (agency root) | Skill deployment registry | Any skill added or removed |
| **Agency `CLAUDE.md`** (agency root) | Agency-level commands table | Any new command added to any client |

### Change → action table

| Change | Files to update |
|---|---|
| New `.claude/commands/` file added | This CLAUDE.md commands table + agency CLAUDE.md |
| New context files added | Context Loading Rules table in this file |
| Platform or handle changes | Platform section + env var format |
| Analytics IDs change | Analytics section |
| Voice & tone rules added | Voice & Tone section |
| **Any skill created, renamed, or changed** | `SKILLS-REFERENCE.md` + `install.sh` + `client-template/CLAUDE.md` + all client CLAUDE.md files |
| New output subfolder added by any skill | Output Folder Structure diagram in this file + `client-template/CLAUDE.md` |

### MANDATORY after any skill change
1. Edit in `seo-workflow/{skill}/SKILL.md`
2. Update `SKILLS-REFERENCE.md` — entry must reflect the change
3. Update `client-template/CLAUDE.md` if commands, routing, or output folders changed
4. Update `client-template/.claude/commands/start-client.md` if skill references changed
5. Update `install.sh` SKILLS array
6. Run `bash seo-workflow/install.sh`
7. **Confirm to the user:** "SKILLS-REFERENCE.md updated ✅ | client-template updated ✅ | install.sh deployed ✅"

This file is read by `/start-client` on workspace open.
Keeping it accurate means every session starts with correct context.

---

## Never
- Hardcode tokens or credentials in any output file
- Execute CMS or file changes without explicit approval
- {Add client-specific brand rules here}
