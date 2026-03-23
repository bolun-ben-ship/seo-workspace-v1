# SEO Workflow — Claude Code Skills & Orchestrators

A complete SEO and content pipeline for Claude Code. Includes 4 orchestrators, 2 data skills, 1 routing plugin, 13 specialist skills, 1 design skill, 1 planning skill, 1 reporting skill, 1 research skill, and 6 subagents — all installable from this repo.

---

## Skill Index

### Orchestrators
| Skill | Trigger | What it does |
|---|---|---|
| `monthly-seo-run` | "monthly SEO run" / "run full monthly cycle" | Full monthly pipeline: audit → GSC/GA4 → plan → write 3 blogs → approve → execute on-page changes |
| `ai-seo-pipeline` | "automate SEO" / "set up SEO automation" | Long-term automation (3/6/12 months): questionnaire → initial run → weekly blogs → monthly on-page → reports |
| `shopline-onpage-implement` | "fix on-page SEO on Shopline" / "implement SEO on Shopline" | Shopline-only: audit → GSC/GA4 → fetch live store → plan → approve → execute via Shopline REST API |
| `webflow-onpage-implement` | "fix on-page SEO on Webflow" / "implement SEO on Webflow" | Webflow-only: audit → GSC/GA4 → fetch live site → plan → approve → execute via Webflow API + MCP |

### Data Skills
| Skill | Trigger | What it does |
|---|---|---|
| `ga4-report` | "GA4 report" / "how is traffic" | Pulls live GA4 30-day summary: sessions, channels, top pages, bounce rates |
| `gsc-report` | "GSC report" / "what are my rankings" | Pulls live GSC 30-day summary: top queries, CTR gaps, ranking movements |

### Research Skills
| Skill | Trigger | What it does |
|---|---|---|
| `last30days` | "last 30 days" / "/last30days {topic}" | Researches any topic from last 30 days across Reddit, X, YouTube, Hacker News, Polymarket |

### Foundation Plugin
| Skill | What it covers |
|---|---|
| `seo-and-blog` | 27-skill routing plugin — handles all SEO and blog sub-tasks; called by orchestrators and directly by trigger phrases |

### Content & Design Skills
| Skill | Trigger | What it does |
|---|---|---|
| `3blog-pipeline` | "write 3 blogs" / "blog pipeline" | Content pipeline: audit → research → keywords → write 3 blogs → push to CMS as drafts (platform-aware) |
| `carousel` | "/carousel" / "instagram carousel" | Branded 7-slide Instagram carousel: questionnaire → HTML preview → export as 1080×1350px PNGs |

### Planning & Reporting Skills
| Skill | Trigger | What it does |
|---|---|---|
| `seo-implementation-plan` | "implementation plan" / "SEO implementation plan" | Builds complete before/after SEO plan (plan only — no execution, all platforms) |
| `seo-final-report` | "final report" / "end of engagement report" | Comprehensive end-of-engagement report comparing full history vs current state |

### Specialist Skills
| Skill | Trigger phrase |
|---|---|
| `seo-audit` | "audit my site" / "full SEO check" / "website health check" |
| `seo-plan` | "SEO plan" / "SEO strategy" / "content strategy" |
| `seo-technical` | "technical SEO" / "crawl issues" / "Core Web Vitals" |
| `seo-content` | "content quality" / "E-E-A-T" / "thin content" |
| `seo-page` | "analyze this page" + single URL |
| `seo-schema` | "schema markup" / "structured data" / "JSON-LD" |
| `seo-sitemap` | "sitemap" / "generate sitemap" |
| `seo-images` | "image optimization" / "alt text" |
| `seo-geo` | "AI Overviews" / "GEO" / "AI search" / "Perplexity" |
| `seo-hreflang` | "hreflang" / "international SEO" |
| `seo-programmatic` | "programmatic SEO" / "pages at scale" |
| `seo-competitor-pages` | "comparison page" / "vs page" / "alternatives page" |

### Subagents (called internally by `seo-audit`)
| Agent | Role |
|---|---|
| `seo-content` | E-E-A-T and content quality analysis |
| `seo-performance` | Core Web Vitals and page load performance |
| `seo-schema` | Schema markup detection and validation |
| `seo-sitemap` | Sitemap validation and generation |
| `seo-technical` | Crawlability, indexability, security, mobile |
| `seo-visual` | Screenshot capture and above-the-fold analysis |

---

## Platform Routing

Skills auto-detect the platform from the client's `CLAUDE.md` (`CMS:` field):

| Platform | Blog push | On-page execution |
|---|---|---|
| `Shopline` | Shopline Admin REST API (`published: false`) | `shopline-onpage-implement` |
| `Webflow` | Webflow Data API via MCP (`isDraft: true`) | `webflow-onpage-implement` |
| `WordPress` | WordPress REST API (`status: draft`) | `wordpress-onpage-implement` (preview) |
| Unknown | Save HTML locally | Manual |

---

## Installation

### Quick install (Mac/Linux)

```bash
git clone https://github.com/bolun-ben-ship/claude-workspace-v2.git
cd claude-workspace-v2
bash seo-workflow/install.sh
```

Restart Claude Code. All skills and subagents appear automatically.

### Manual install (Mac/Linux)

```bash
# Skills
cp -r seo-workflow/monthly-seo-run seo-workflow/ai-seo-pipeline \
      seo-workflow/shopline-onpage-implement seo-workflow/webflow-onpage-implement \
      seo-workflow/3blog-pipeline seo-workflow/carousel \
      seo-workflow/seo-implementation-plan seo-workflow/seo-final-report \
      seo-workflow/ga4-report seo-workflow/gsc-report seo-workflow/last30days \
      seo-workflow/seo-and-blog seo-workflow/seo-audit seo-workflow/seo-plan \
      seo-workflow/seo-technical seo-workflow/seo-content seo-workflow/seo-page \
      seo-workflow/seo-schema seo-workflow/seo-sitemap seo-workflow/seo-images \
      seo-workflow/seo-geo seo-workflow/seo-hreflang seo-workflow/seo-programmatic \
      seo-workflow/seo-competitor-pages \
      ~/.claude/skills/

# Subagents
cp seo-workflow/agents/*.md ~/.claude/agents/
```

---

## Repo Structure

```
claude-workspace-v2/
├── seo-workflow/
│   ├── install.sh                    ← Mac/Linux one-command installer
│   ├── README.md
│   │
│   ├── agents/                       ← Subagent definitions (→ ~/.claude/agents/)
│   │   ├── seo-content.md
│   │   ├── seo-performance.md
│   │   ├── seo-schema.md
│   │   ├── seo-sitemap.md
│   │   ├── seo-technical.md
│   │   └── seo-visual.md
│   │
│   ├── monthly-seo-run/              ← Orchestrators
│   ├── ai-seo-pipeline/
│   ├── shopline-onpage-implement/
│   ├── webflow-onpage-implement/
│   │
│   ├── ga4-report/                   ← Data skills
│   ├── gsc-report/
│   ├── last30days/                   ← Research skill
│   │
│   ├── seo-and-blog/                 ← Routing plugin (27 sub-skills)
│   │   ├── SKILL.md
│   │   └── skills/
│   │
│   ├── 3blog-pipeline/               ← Content & design
│   ├── carousel/
│   │
│   ├── seo-implementation-plan/      ← Planning & reporting
│   ├── seo-final-report/
│   │
│   ├── seo-audit/                    ← Specialist skills (13)
│   ├── seo-plan/
│   │   └── assets/                  ← Industry templates
│   │       ├── agency.md
│   │       ├── ecommerce.md
│   │       ├── generic.md
│   │       ├── local-service.md
│   │       ├── publisher.md
│   │       └── saas.md
│   ├── seo-technical/
│   ├── seo-content/
│   ├── seo-page/
│   ├── seo-schema/
│   ├── seo-sitemap/
│   ├── seo-images/
│   ├── seo-geo/
│   ├── seo-hreflang/
│   ├── seo-programmatic/
│   └── seo-competitor-pages/
│
├── client-template/                  ← Template for new client workspaces
├── context/                          ← Agency-level context
├── CLAUDE.md                         ← Agency workspace config
└── SKILLS-REFERENCE.md               ← Master skill registry
```

Each skill folder contains a `SKILL.md` that Claude Code reads automatically — no config files or registration needed.

---

## Prerequisites

### All orchestrators and data skills
- Google service account JSON key file (GA4 + GSC access)
- Credentials env var pointing to the JSON file path
- `google-analytics-data`, `google-api-python-client`, `google-auth` Python packages

### `shopline-onpage-implement` and Shopline blog push
- `$SHOPLINE_{CLIENT}_TOKEN` env var
- Shopline Admin REST API v20251201

### `webflow-onpage-implement` and Webflow blog push
- `$WEBFLOW_{CLIENT}_TOKEN` env var
- Webflow MCP server installed and configured in `.mcp.json`

### `carousel`
- `playwright` Python package + Chromium: `python3 -m playwright install chromium`
- `Pillow` Python package

### Output folder
Skills save reports to a path defined in each client's `CLAUDE.md`:
```
Content & SEO/outputs/{platform}-{handle}/
  audit/           ← AUDIT-YYYY-MM-DD.md
  implementation/  ← IMPLEMENTATION-PLAN-*.md, SNAPSHOT-*.md
  research/        ← GSC-REPORT-*, GA4-REPORT-*
  keywords/        ← KEYWORDS-YYYY-MM-DD.md
  blog-plans/      ← BLOG-PLAN-YYYY-MM-DD.md
  blogs/           ← HTML blog posts
  reports/         ← WEEK-*-REPORT-*, MONTHLY-REPORT-* (from ai-seo-pipeline)
```

---

## Updating

To pull the latest version and re-install:

```bash
git pull
bash seo-workflow/install.sh
```

Restart Claude Code after updating.

---

## Verify Installation

After restarting Claude Code, type any trigger phrase and the skill activates. To verify directly:

```bash
ls ~/.claude/skills/    # should show 24 folders
ls ~/.claude/agents/    # should show 6 .md files
```
