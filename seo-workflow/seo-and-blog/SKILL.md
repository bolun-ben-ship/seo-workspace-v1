---
name: seo-and-blog
description: >
  Full SEO and blog content plugin — 27 skills covering every stage of the pipeline.
  Use for: seo audit, full SEO check, analyze site, technical SEO, crawl issues,
  robots.txt, Core Web Vitals, E-E-A-T, content audit, schema markup, structured data,
  JSON-LD, sitemap, SEO plan, SEO strategy, competitor pages, programmatic SEO,
  hreflang, image optimization, on-page SEO, GEO, AI Overviews, AI citations,
  AI search, write blog, new blog post, create article, draft blog, content brief,
  blog brief, blog outline, editorial calendar, content calendar, blog plan,
  blog strategy, content pillars, analyze blog, audit blog, blog score, blog rewrite,
  blog schema, repurpose blog, keyword research, keyword gap, long-tail keywords,
  PAA, last 30 days, GSC analysis. Always use this plugin for any SEO or blog task.
---

# SEO & Blog Plugin — Routing Orchestrator

This plugin bundles 27 individual SEO and blog skills. When a user requests any SEO
or content task, read this file to identify the right sub-skill, then read that
sub-skill file for detailed execution instructions.

---

## Output Routing (ALWAYS apply this)

All outputs must be saved under the workspace `Content & SEO/` folder, organized by domain:

```
Content & SEO/outputs/<domain>/
├── audit/          ← seo-audit, seo-technical, seo-content, seo-schema, seo-sitemap,
│                     seo-geo, seo-images, seo-page, blog-analyze, blog-audit,
│                     blog-geo, blog-seo-check
├── implementation/ ← seo-plan, seo-competitor-pages, seo-programmatic, seo-hreflang
├── keywords/       ← seo-keywords
├── blogs/          ← blog-write, blog-rewrite, blog-chart, blog-schema
├── blog-plans/     ← blog-brief, blog-outline, blog-calendar, blog-strategy, blog-repurpose
└── research/       ← last30days
```

The workspace root for `Content & SEO/` is at:
`/Users/ben/Antigravity/AEXPHL-claude-workspace/Content & SEO`

When working in Cowork, use the path: `Content & SEO/outputs/<domain>/<subfolder>/`

---

## Prerequisites Check (ALWAYS run for individual skill calls)

Before running any individual skill (anything except seo-audit and seo-plan), check:

1. Does `Content & SEO/outputs/<domain>/audit/` contain an audit report?
2. Does `Content & SEO/outputs/<domain>/implementation/` contain an SEO plan?

If EITHER is missing:
- Inform the user: "I need to run the SEO audit and/or plan first to get full context."
- Run `seo-audit` first → then `seo-plan` → then proceed with the requested skill.

---

## Skill Routing Table

When the user's request matches a task below, read the corresponding sub-skill file
(located in `skills/` relative to this plugin's directory). Follow its instructions
exactly for execution.

### SEO Skills

| Task | Sub-skill file | Output folder |
|------|---------------|---------------|
| Full site audit, health check, "audit my site" | `skills/seo-audit.md` | `audit/` |
| SEO plan, strategy, roadmap, implementation plan | `skills/seo-plan.md` | `implementation/` |
| Technical SEO, crawl, robots.txt, Core Web Vitals | `skills/seo-technical.md` | `audit/` |
| Content quality, E-E-A-T, thin content | `skills/seo-content.md` | `audit/` |
| Schema markup, structured data, JSON-LD | `skills/seo-schema.md` | `audit/` |
| Sitemap analysis or generation | `skills/seo-sitemap.md` | `audit/` |
| GEO, AI Overviews, AI citations, AI search | `skills/seo-geo.md` | `audit/` |
| Image optimization, alt text | `skills/seo-images.md` | `audit/` |
| Single page SEO analysis | `skills/seo-page.md` | `audit/` |
| Competitor pages, create competitor-targeted pages | `skills/seo-competitor-pages.md` | `implementation/` |
| Hreflang, international SEO, multilingual | `skills/seo-hreflang.md` | `implementation/` |
| Programmatic SEO, page templates at scale | `skills/seo-programmatic.md` | `implementation/` |
| Keyword research, keyword gaps, PAA, long-tail | `skills/seo-keywords.md` | `keywords/` |

### Blog Skills

| Task | Sub-skill file | Output folder |
|------|---------------|---------------|
| Write new blog post, create article | `skills/blog-write.md` | `blogs/` |
| Rewrite or improve existing blog post | `skills/blog-rewrite.md` | `blogs/` |
| Add/fix schema on a blog post | `skills/blog-schema.md` | `blogs/` |
| Add data chart to a blog post | `skills/blog-chart.md` | `blogs/` |
| Content brief for a blog post | `skills/blog-brief.md` | `blog-plans/` |
| Blog post outline/structure | `skills/blog-outline.md` | `blog-plans/` |
| Editorial/content calendar | `skills/blog-calendar.md` | `blog-plans/` |
| Blog strategy, content pillars | `skills/blog-strategy.md` | `blog-plans/` |
| Repurpose blog content to other formats | `skills/blog-repurpose.md` | `blog-plans/` |
| Analyze/score a single blog post | `skills/blog-analyze.md` | `audit/` |
| Full-site blog health audit | `skills/blog-audit.md` | `audit/` |
| SEO check for a blog post | `skills/blog-seo-check.md` | `audit/` |
| GEO/AI citation optimization for a blog post | `skills/blog-geo.md` | `audit/` |

### Research

| Task | Sub-skill file | Output folder |
|------|---------------|---------------|
| Last 30 days performance, GSC analysis | `skills/last30days.md` | `research/` |

---

## How to Execute a Skill

1. **Identify the domain** — ask the user if not provided (e.g., "3nm.io")
2. **Run prerequisites check** (see above) unless the task IS seo-audit or seo-plan
3. **Read the sub-skill file** using the path: `skills/<skill-name>.md`
   - The skills/ directory is in the same folder as this SKILL.md
4. **Follow the sub-skill instructions exactly**
5. **Save output** to the correct subfolder per the output routing table above
6. **Reference prior outputs** — when running any skill, load relevant prior outputs first:
   - Audit report from `audit/`
   - SEO plan from `implementation/`
   - Keywords from `keywords/`
   - Blog plan from `blog-plans/`

---

## Notes

- Blog output format: always **HTML** unless user specifies otherwise (Ben's site uses pure HTML on Vercel)
- Domain subfolders use the domain name, e.g., `outputs/3nm.io/` or `outputs/client-name.com/`
- Create the domain subfolder if it doesn't exist yet
- Never save outputs to the root workspace or the root of `Content & SEO/`
