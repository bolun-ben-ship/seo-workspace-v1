---
name: monthly-seo-run
description: >
  Full monthly SEO cycle — the core RightClick:AI deliverable. Runs entirely from the client
  workspace. Phases: load historical context → SEO audit → GSC + GA4 data + last30days market
  research (parallel) → keyword research → SEO plan (on-page changes) → blog plan (no overlap
  with SEO plan) → write 3 blogs with tone guide → approval gate → post blogs to CMS → execute
  on-page title/meta/schema changes via API → full post-implementation monthly report.
  Platform-aware: auto-detects Shopline or Webflow from client CLAUDE.md. Always builds on
  prior months — never re-recommends resolved items, never repeats prior blog topics.
  Use when user says "monthly run", "run the monthly", "full monthly SEO", "monthly SEO cycle",
  "run everything for this client", or "monthly-seo-run".
user-invocable: true
argument-hint: "(no arguments — reads all config from CLAUDE.md)"
---

# Monthly SEO Run

The single command that runs the complete monthly SEO cycle for a client.
Reads all configuration from the client's `CLAUDE.md` — no arguments needed.

---

## What This Produces

```
Content & SEO/outputs/{platform}-{handle}/
├── audit/
│   ├── AUDIT-YYYY-MM-DD.md                      ← Phase 1
│   └── POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.md  ← Phase 6 (monthly report)
├── research/
│   ├── GSC-REPORT-YYYY-MM-DD.md                 ← Phase 2a
│   ├── GA4-REPORT-YYYY-MM-DD.md                 ← Phase 2b
│   └── SOCIAL-TRENDS-YYYY-MM-DD.md              ← Phase 2c
├── keywords/
│   └── KEYWORDS-YYYY-MM-DD.md                   ← Phase 3a
├── implementation/
│   ├── SEO-PLAN-YYYY-MM-DD.md                   ← Phase 3b
│   └── SNAPSHOT-YYYY-MM-DD.md                   ← Phase 5 (before/after record)
├── blog-plans/
│   └── BLOG-PLAN-YYYY-MM-DD.md                  ← Phase 3c
└── blogs/
    ├── {post-1-slug}.html                        ← Phase 4
    ├── {post-2-slug}.html
    └── {post-3-slug}.html
```

---

## File Naming Convention

All files use `YYYY-MM-DD` suffix. Never overwrite prior files — always use today's date.

```
audit/AUDIT-YYYY-MM-DD.md
audit/POST-IMPLEMENTATION-AUDIT-YYYY-MM-DD.md
research/GSC-REPORT-YYYY-MM-DD.md
research/GA4-REPORT-YYYY-MM-DD.md
research/SOCIAL-TRENDS-YYYY-MM-DD.md
keywords/KEYWORDS-YYYY-MM-DD.md
implementation/SEO-PLAN-YYYY-MM-DD.md
implementation/SNAPSHOT-YYYY-MM-DD.md
blog-plans/BLOG-PLAN-YYYY-MM-DD.md
blogs/{post-slug}.html
```

---

## Phase Overview

| Phase | Name | Saves to |
|---|---|---|
| 0 | Load Historical Context | (in memory only) |
| 1 | SEO Audit | `audit/AUDIT-*.md` |
| 2a | GSC Report | `research/GSC-REPORT-*.md` |
| 2b | GA4 Report | `research/GA4-REPORT-*.md` |
| 2c | Market Research (last30days) | `research/SOCIAL-TRENDS-*.md` |
| 3a | Keyword Research | `keywords/KEYWORDS-*.md` |
| 3b | SEO Plan (on-page changes) | `implementation/SEO-PLAN-*.md` |
| 3c | Blog Plan | `blog-plans/BLOG-PLAN-*.md` |
| 4 | Write 3 Blog Posts | `blogs/*.html` |
| ⏸ | **Approval Gate** | — |
| 5 | Execute: Post Blogs + On-page Changes | `implementation/SNAPSHOT-*.md` |
| 6 | Monthly Post-Implementation Report | `audit/POST-IMPLEMENTATION-AUDIT-*.md` |

Read each phase file before executing. Do not skip ahead.

---

## Execution Flow

```
Phase 0 (History)       → HISTORICAL_CONTEXT loaded into memory

Phase 1 (Audit)         → audit findings, SEO health score
       ↓
Phase 2a (GSC)          → top queries, CTR gaps        ┐
Phase 2b (GA4)          → traffic baseline, top pages  ├─ run in parallel
Phase 2c (Trends)       → social + market signals      ┘
       ↓
Phase 2 Synthesis       → RESEARCH_SUMMARY combining all three
       ↓
Phase 3a (Keywords)     → keyword targets derived from RESEARCH_SUMMARY
Phase 3b (SEO Plan)     → on-page change plan (titles, meta, schema)
Phase 3c (Blog Plan)    → 3 post plan — no topic overlap with SEO plan or prior blogs
       ↓
Phase 4 (Blogs)         → 3 posts written with tone guide applied
       ↓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏸  APPROVAL GATE — present summary, wait for explicit "approve"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
       ↓
Phase 5a (Post blogs)   → publish 3 posts to CMS (platform-specific)
Phase 5b (On-page)      → apply SEO title/meta/schema changes via API
Phase 5c (Snapshot)     → save before/after record
       ↓
Phase 6 (Report)        → full monthly POST-IMPLEMENTATION-AUDIT-*.md
```

**Stop at the Approval Gate. Never execute changes without explicit user approval.**

---

## Platform Detection

Read `CLAUDE.md` in the current working directory. Find `## Platform` → `CMS:` field.
Set PLATFORM before doing anything else. Announce detected platform to user.

```
"Shopline"   → PLATFORM = shopline
"Webflow"    → PLATFORM = webflow
"WordPress"  → PLATFORM = wordpress
other/missing → PLATFORM = unknown
```

## Platform Routing Table

All CMS execution in Phase 5 routes through this table. Do not hardcode any platform.

| Action | Shopline | Webflow | WordPress (preview) | Unknown |
|---|---|---|---|---|
| Post blogs to CMS | REST API `published: false` | MCP `isDraft: true` | WP REST API `status: draft` | Save HTML locally, skip push |
| Execute on-page changes | `shopline-onpage-implement` logic | `webflow-onpage-implement` logic + MCP | WP REST API + SEO plugin meta | Save plan only, no execution |
| Approval prompt wording | "approve changes via Shopline API" | "approve changes via Webflow API + MCP" | "approve changes via WordPress API" | Not applicable |
| Required credential | `SHOPLINE_{CLIENT}_TOKEN` | `WEBFLOW_{CLIENT}_TOKEN` + MCP connected | `WP_{CLIENT}_TOKEN` (app password) | None |

If `PLATFORM = unknown`: complete Phases 0–4 (research, plan, write blogs). Skip Phase 5 execution. Tell user to apply changes manually.
If `PLATFORM = wordpress`: mark as preview — confirm SEO plugin field names on staging before executing.

---

## Reading Client Config

Before starting Phase 1, read `CLAUDE.md` and extract:

| Config key | Used in |
|---|---|
| `CMS` (Platform field) | Phase 5 platform switching |
| `Store / Site handle` | Output folder path |
| `Access token` env var | Phase 5 API calls |
| `Outputs` path | All file saves |
| `GSC site` | Phase 2a |
| `GA4 property ID` | Phase 2b |
| `Credentials env var` | Phase 2a + 2b |

Also read `context/client-info.md` to extract the primary niche/topic for Phase 2c last30days query.

---

## Sub-skill Reference Paths

Phase files reference sub-skills from the seo-and-blog plugin:
`.skills/skills/seo-and-blog/skills/<skill-name>.md`

Fallback to individual installed skills:
`.skills/skills/<skill-name>/SKILL.md`

If neither found, execute the skill logic from first principles using the skill name as guidance.
