# Owllight Sleep — Claude Workspace

## Client
- **Name:** Owllight Sleep
- **Website:** owllight-sleep.com
- **Market:** Singapore
- **Niche:** Mattress / back care / sleep

## Platform
- **CMS:** Shopline
- **Store handle:** `owllight-sleep`
- **Access token:** `$SHOPLINE_OWLLIGHT_TOKEN` (env var — never hardcode)
- **API base:** `https://owllight-sleep.myshopline.com/admin/openapi/v20251201`

## Workspace
- **WORKSPACE_ROOT:** `~/Antigravity/RightClickAI-seo-workspace/clients/owllight`
- **Outputs:** `Content & SEO/outputs/shopline-owllight-sleep/`

## Commands

| Command | What it does |
|---|---|
| `/prime` | Deep context loading — reads all files + full output history, produces comprehensive Prime Brief for intensive work |
| `/start-client` | Loads all client context and produces a Client Briefing — run at the start of every session |
| `/ai-seo-pipeline` | Full automation (3/6/12 months) — guided questionnaire → initial run → weekly 5 blogs → monthly on-page → reports |
| `/monthly-seo-run` | One-shot monthly cycle — audit → research → plan → write 3 blogs → approve → execute → report |
| `/seo-implementation-plan` | Build a complete before/after SEO plan (no execution) |
| `/seo-final-report` | End-of-engagement comprehensive report |
| `/3blog-pipeline` | Write 3 blogs + push to Shopline as drafts |
| `/shopline-onpage-implement` | On-page SEO changes (titles, meta, schema) via Shopline API |
| `/carousel` | Instagram carousel generator — branded 7-slide HTML preview + export as PNGs |

## Analytics
- GSC site: `https://owllight-sleep.com`
- GA4 property ID: `485483885`
- Google credentials: `clients/owllight/owllight-claude-seo-project-c389d3b33dd1.json`
- Credentials env var: `OWLLIGHT_GOOGLE_KEY`

## Context Loading Rules

When a task involves SEO, content, marketing, copywriting, or strategy — load these before responding:

| File | When to read |
|---|---|
| `context/client-info.md` | Any business or client-facing task |
| `context/tone-guide.md` | Any writing task — blog posts, copy, emails, CTAs |
| `context/strategy.md` | Content, SEO, growth, or channel strategy tasks |
| `context/personal-info.md` | Copywriting, brand voice, founder POV, tone |
| `context/current-data.md` | Stats, web assets, market priorities, baselines |

Read only the files relevant to the task — not all five every time.

---

## Voice & Tone

- Singapore audience — mattress, back care, sleep niche
- Fill in `context/tone-guide.md` to define Owllight's brand voice for content generation

---

## Maintain This File

After ANY change to this client workspace, check whether CLAUDE.md needs updating.
Update it immediately if any of the following have changed:

| Change | What to update |
|---|---|
| New `.claude/commands/` file added | Add it to the Commands table |
| New context files added | Add them to the Context Loading Rules table |
| Platform or handle changes | Update Platform section |
| Analytics IDs change | Update Analytics section |
| Any skill created, renamed, or changed | Update `SKILLS-REFERENCE.md` in agency root immediately, run `install.sh`, confirm to user |

This file is read by `/start-client` on workspace open.
Keeping it accurate means every session starts with correct context.

---

## Never
- Hardcode tokens or credentials in any output file
- Execute changes without explicit approval
