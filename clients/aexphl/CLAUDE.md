# Aussie Expat Home Loans (AEXPHL) — Claude Workspace

## Client
- **Name:** Aussie Expat Home Loans
- **Website:** aexphl.com
- **Market:** Australian expats globally (primary: Singapore, Hong Kong, Dubai)
- **Niche:** Specialist mortgage brokerage for Australian expats buying/refinancing property in Australia

## Platform
- **CMS:** Webflow
- **Site handle:** `aexphl`
- **Access token:** `$WEBFLOW_AEXPHL_TOKEN` (env var — never hardcode)
- **API base:** `https://api.webflow.com/v2`

## Workspace
- **WORKSPACE_ROOT:** `~/Antigravity/RightClickAI-seo-workspace/clients/aexphl`
- **Outputs:** `Content & SEO/outputs/webflow-aexphl/`

## Commands

| Command | What it does |
|---|---|
| `/prime` | Deep context loading — reads all files + full output history, produces comprehensive Prime Brief for intensive work |
| `/start-client` | Loads all client context and produces a Client Briefing — run at the start of every session |
| `/ai-seo-pipeline` | Full automation (3/6/12 months) — guided questionnaire → initial run → weekly blogs → monthly on-page → reports |
| `/monthly-seo-run` | One-shot monthly cycle — audit → research → plan → write 3 blogs → approve → execute → report |
| `/seo-implementation-plan` | Build a complete before/after SEO plan (no execution) |
| `/seo-final-report` | End-of-engagement comprehensive report |
| `/3blog-pipeline` | Write 3 blogs + push to Webflow CMS as drafts |
| `/webflow-onpage-implement` | On-page SEO changes (titles, meta, schema) via Webflow API + MCP |
| `/carousel` | Instagram carousel generator — branded 7-slide HTML preview + export as PNGs |

## Analytics
- GSC site: `https://aexphl.com`
- GA4 property ID: `316786577`
- Google credentials env var: `AEXPHL_GOOGLE_KEY`

## MCP
- Webflow MCP is required for executing CMS changes
- Config: `.mcp.json` in this folder (reads token from `$WEBFLOW_AEXPHL_TOKEN`)

---

## Context Loading Rules

When a task involves SEO, content, marketing, copywriting, or strategy — load these before responding:

| File | When to read |
|---|---|
| `context/client-info.md` | Any business or client-facing task |
| `context/tone-guide.md` | Any writing task — blog posts, copy, emails, CTAs |
| `context/strategy.md` | Content, SEO, growth, or channel strategy tasks |
| `context/personal-info.md` | Copywriting, brand voice, Tim's POV, tone |
| `context/current-data.md` | Stats, web assets, market priorities, baselines |

Read only the files relevant to the task — not all four every time.

---

## Voice & Tone

- Clear, direct, no fluff
- Tim's voice: integrity-first, relationship-driven, anti-fear-marketing
- Audience: ambitious Aussie expat professionals (Singapore, HK, Dubai primary)
- Entry points: borrowing capacity check → refinance → full origination

## Maintain This File

After ANY change to this client workspace, check whether CLAUDE.md needs updating.
Update it immediately if any of the following have changed:

| Change | What to update |
|---|---|
| New `.claude/commands/` file added | Add it to the Commands table |
| New context files added | Add them to the Context Loading Rules table |
| Platform or handle changes | Update Platform section |
| Analytics IDs change | Update Analytics section |
| Voice & tone rules added | Update Voice & Tone section |
| Any skill created, renamed, or changed | Update `SKILLS-REFERENCE.md` in agency root immediately, run `install.sh`, confirm to user |

This file is read by `/start-client` on workspace open.
Keeping it accurate means every session starts with correct context.

---

## Never
- Generic broker tone ("we're here to help you achieve your dream home")
- Fear-based framing
- Hardcode tokens or credentials in any output file
- Execute CMS or file changes without explicit approval
