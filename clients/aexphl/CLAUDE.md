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
| `/3blog-seo-first-run` | Full run — audit → research → plan → write 3 blogs → approve → execute on-page changes → before/after report |
| `/seo-implementation-plan` | Build a complete before/after SEO plan (no execution) |
| `/seo-final-report` | End-of-engagement comprehensive report |
| `/webflow-onpage-implement` | On-page SEO changes (titles, meta, schema) via Webflow API + MCP |
| `/carousel` | Instagram carousel generator — branded 7-slide HTML preview + export as PNGs |

## Analytics
- GSC site: `https://aexphl.com`
- GA4 property ID: `316786577`
- Google credentials env var: `AEXPHL_GOOGLE_KEY`

## MCP
- Webflow MCP is required for executing CMS changes
- Config: `.mcp.json` in this folder (reads token from `$WEBFLOW_AEXPHL_TOKEN`)

## Env Vars — Two Places Required

Claude Code's Bash tool does NOT source `~/.zshrc`. Any API key set only there will show as `NOT SET`.

**Every key must be in BOTH:**
1. `~/.zshrc` — for terminal sessions
2. `~/.claude/settings.json` under the `env` block — for Claude Code Bash access

Current keys registered for this workspace:
- `WEBFLOW_AEXPHL_TOKEN` — Webflow API (in settings.json ✅)
- `AEXPHL_GOOGLE_KEY` — Google credentials (GSC + GA4)
- `MAILCHIMP_API_KEY` — Mailchimp (in settings.json ✅)
- `MONDAY_API_KEY` — Monday.com (in settings.json ✅)
- `CALENDLY_API_KEY` — Calendly (add when ready — see Mailchimp Sync section)

When adding a new key, update both files immediately.

## Active AI SEO Pipeline

**Campaign:** 2026-03-23 → 2026-06-23 (3 months)
**Webflow collection ID:** `66104d468c50c15134bf0447` (Blog Posts)

Scheduled tasks running (see Scheduled tab in Claude Code sidebar):
- `aexphl-weekly-blogs` — every Monday 9am, writes + pushes 5 blog drafts
- `aexphl-monthly-onpage` — 23rd of each month 9am, full audit + on-page execution
- `aexphl-week1-report` — one-off 2026-03-30
- `aexphl-final-report` — one-off 2026-06-23
- `aexphl-mailchimp-sync` — every hour, syncs Webflow forms + Calendly bookings + Monday CRM delta → Mailchimp

**Required:** `~/.claude/settings.json` must have `Bash`, `Read`, `Write`, `Edit`, `WebSearch`, `WebFetch` in `permissions.allow` — otherwise tasks will prompt for approval on every run.

**Manual items still outstanding:**
- noIndex `/landing-page` and `/landing-page-v2` in Webflow Designer
- 4 schema JSON-LD blocks (see `implementation/IMPLEMENTATION-PLAN-2026-03-23.md` Category F)

**Completed since pipeline launch:**
- Internal linking — 46 links injected across 17 blog posts (6 published + 11 drafts) on 2026-03-24 via Webflow CMS API. Plan + report: `implementation/INTERNAL-LINKS-PLAN-2026-03-24.md` / `INTERNAL-LINKS-REPORT-2026-03-24.md`
- Mailchimp lead sync — set up 2026-03-24; upgraded 2026-03-25 to full 4-source sync: Webflow forms + Calendly (all bookings, phone/location/event populated) + Monday delta sync (ongoing, not one-time) + deduplication by email hash. Audience ID: `bba8715471`

---

## Mailchimp Integration

- **Audience:** AEXPHL (`bba8715471`) — `enquiry@aexphl.com`
- **Sync script:** `scripts/mailchimp-sync.sh`
- **State file:** `scripts/mailchimp-sync-state.json` (tracks last sync timestamp)
- **Log file:** `scripts/mailchimp-sync.log`
- **Scheduled task:** `aexphl-mailchimp-sync` (hourly)

**Tags applied:**
- `source:webflow` — Webflow contactForm submissions
- `source:calendly` — all Calendly bookings
  - `event:borrowing-cap` — "Check your borrowing capacity or Refinance options"
  - `event:next-available` — "Next Available Appointment"
  - `event:discovery-call` — "Schedule Your Discovery Call"
  - `event:loan-consult` — "Loan Consultation" (broker-specific)
  - `event:{slugified-name}` — any other event type
  - `broker:shaun` / `broker:tim` / `broker:charu` — who they booked with
- `source:whatsapp-manychat` + `lead-type:high-intent` — ManyChat completed intake (native MC integration)
- `source:monday-import` — all Monday.com imports (ongoing delta sync)
  - `monday:lead` + `monday-status:{status}` — from Leads board
  - `monday:customer` — from Customers board
  - `broker:shaun` / `broker:tim` — lead owner (Leads board only)

**Merge fields populated (created 2026-03-24, extended 2026-03-25):**
- `FNAME`, `LNAME`, `PHONE` — standard fields (never overwritten with blank)
- `WHATSAPP` — WhatsApp number (from Monday Leads / Webflow)
- `SERVICES` — Interested services or event type booked
- `LEADSTAT` — Lead status (from Monday Leads)
- `LOCATION` — Country / region (from Calendly Q&A + Monday Leads)
- `CAMPAIGN` — Campaign source (from Monday Leads)
- `LSOURCE` — Lead capture source (calendly / webflow / monday)
- `EMPLOY` — Employment status (from Monday Customers)
- `IMMIGR` — Immigration status (from Monday Customers)
- `BROKER` — Assigned broker name
- `COUNTRY` — Country of residence (from Monday Customers)
- `AGE` — Age (from Monday Customers)
- `MARITAL` — Marital status (from Monday Customers)
- `JOBTITLE` — Job title (from Monday Customers)
- `INCOME` — Annual income AUD (from Monday Customers)
- `CUSTTYPE` — Customer type e.g. High Net Worth (from Monday Customers)
- `MEETDATE` — Original booking / meeting date

**Monday.com boards mapped:**
- `1907973121` Leads — owner-filtered (Shaun Rattray + Tim Raes only), delta sync hourly
- `1917616922` Customers — all entries, delta sync hourly
- `1917636634` Referrers → **SKIPPED** (referral partners, not leads)
- All other boards → **SKIPPED** (operational/internal)

**Deduplication:** All sources use Mailchimp PUT upsert on email hash — duplicates across Monday, Calendly, and Webflow automatically merge on the same contact record. Empty fields are never sent, so existing data is never overwritten with blank.

**Calendly API note:** Token requires `scheduled_events:read` scope (not `users:read`). User URI hardcoded as `ACGBPK2OIQ3QPH3G` (decoded from JWT). Token set in both `~/.zshrc` and `~/.claude/settings.json`.

**To force full re-sync of Monday:**
Set `monday_last_sync` to `"2020-01-01T00:00:00Z"` in `scripts/mailchimp-sync-state.json`, then trigger the sync.

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

## ⚠️ Maintain This File — ALL MASTER FILES

After ANY change to this client workspace, check ALL of the following and update immediately:

### Master files that must stay in sync

| Master File | What it controls | When to update |
|---|---|---|
| **This file** (`CLAUDE.md`) | Client config, commands, context rules | Any structural change to this workspace |
| **`SKILLS-REFERENCE.md`** (agency root) | Full skill library reference | Any skill or command created, renamed, or changed |
| **`client-template/CLAUDE.md`** (agency root) | Template for new clients | Any time THIS file's structure changes |
| **`client-template/.claude/commands/start-client.md`** | Template briefing command | Any time start-client logic changes |
| **`seo-workflow/install.sh`** (agency root) | Skill deployment registry | Any skill added or removed |
| **Agency `CLAUDE.md`** (agency root) | Agency-level commands table | Any new command added to any client |

### Change → action table

| Change | Files to update |
|---|---|
| New `.claude/commands/` file added | This CLAUDE.md commands table + agency CLAUDE.md + SKILLS-REFERENCE.md |
| **Command logic changed** (any `.claude/commands/` file) | `SKILLS-REFERENCE.md` entry for that command + `client-template/.claude/commands/` + ALL `clients/*/. claude/commands/` copies + run `install.sh` |
| New context files added | Context Loading Rules table in this file |
| Platform or handle changes | Platform section + env var format |
| Analytics IDs change | Analytics section |
| Voice & tone rules added | Voice & Tone section |
| **Any skill created, renamed, or changed** | `SKILLS-REFERENCE.md` + `install.sh` + `client-template/CLAUDE.md` + all client CLAUDE.md files |
| New output subfolder added by any skill | Output Folder Structure diagram in this file + `client-template/CLAUDE.md` |

### MANDATORY after any command change
1. Edit `client-template/.claude/commands/{command}.md` (source of truth)
2. Copy to ALL `clients/*/. claude/commands/{command}.md`
3. Update `SKILLS-REFERENCE.md` — entry must reflect the change
4. Run `bash seo-workflow/install.sh` (deploys to `~/.claude/commands/`)
5. Commit all changed files together
6. **Confirm to the user:** "SKILLS-REFERENCE.md updated ✅ | all client copies updated ✅ | install.sh deployed ✅"

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

## API Key Security

**NEVER share API keys, tokens, or credentials in the chat.** If a key is accidentally shared:
1. Immediately go to the platform and revoke/regenerate it
2. Update `~/.zshrc` with the new key
3. Update `~/.claude/settings.json` env block with the new key
4. Restart Claude Code

This applies to: Mailchimp API keys, Webflow tokens, Google credentials, Calendly tokens — everything.

---

## Never
- Generic broker tone ("we're here to help you achieve your dream home")
- Fear-based framing
- Hardcode tokens or credentials in any output file
- Share API keys or tokens in chat — rotate immediately if this happens
- Execute CMS or file changes without explicit approval
