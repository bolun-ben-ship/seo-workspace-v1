---
name: 3blog-seo-first-run
description: >
  Full SEO implementation + 3 blog posts — the complete first-run deliverable for any client.
  Runs entirely from the client workspace. Phases: load historical context → SEO audit →
  GSC + GA4 data + last30days market research (parallel) → keyword research → SEO plan
  (on-page changes) → blog plan → write 3 blogs with tone guide → approval gate → post
  blogs to CMS as drafts → execute on-page title/meta/schema changes via API → full
  before/after implementation report (what changed field-by-field, health score delta,
  what was pushed as drafts, what could not be updated and why). Platform-aware:
  auto-detects Shopline or Webflow from client CLAUDE.md. Always builds on prior work —
  never re-recommends resolved items, never repeats prior blog topics.
  Use when user says "first run", "full run", "run everything", "3blog-seo-first-run",
  "seo run", "run the seo", "do the full seo", or "run everything for this client".
user-invocable: true
argument-hint: "(no arguments — reads all config from CLAUDE.md)"
---

# 3blog-seo-first-run

The single command that runs the complete SEO implementation + content cycle for a client.
Reads all configuration from the client's `CLAUDE.md` — no arguments needed.

---

## What This Produces

```
Content & SEO/outputs/{platform}-{handle}/
├── audit/
│   ├── AUDIT-YYYY-MM-DD.pdf                          ← Phase 1
│   └── POST-IMPLEMENTATION-REPORT-YYYY-MM-DD.pdf     ← Phase 6 (full before/after report)
├── research/
│   ├── GSC-REPORT-YYYY-MM-DD.pdf                     ← Phase 2a
│   ├── GA4-REPORT-YYYY-MM-DD.pdf                     ← Phase 2b
│   └── SOCIAL-TRENDS-YYYY-MM-DD.pdf                  ← Phase 2c
├── keywords/
│   └── KEYWORDS-YYYY-MM-DD.pdf                       ← Phase 3a
├── implementation/
│   ├── SEO-PLAN-YYYY-MM-DD.pdf                       ← Phase 3b
│   └── SNAPSHOT-YYYY-MM-DD.pdf                       ← Phase 5 (before/after record)
├── blog-plans/
│   └── BLOG-PLAN-YYYY-MM-DD.pdf                      ← Phase 3c
└── blogs/
    ├── {post-1-slug}.html                             ← Phase 4
    ├── {post-2-slug}.html
    └── {post-3-slug}.html
```

---

## File Naming Convention

All files use `YYYY-MM-DD` suffix. Never overwrite prior files — always use today's date.

```
audit/AUDIT-YYYY-MM-DD.pdf
audit/POST-IMPLEMENTATION-REPORT-YYYY-MM-DD.pdf
research/GSC-REPORT-YYYY-MM-DD.pdf
research/GA4-REPORT-YYYY-MM-DD.pdf
research/SOCIAL-TRENDS-YYYY-MM-DD.pdf
keywords/KEYWORDS-YYYY-MM-DD.pdf
implementation/SEO-PLAN-YYYY-MM-DD.pdf
implementation/SNAPSHOT-YYYY-MM-DD.pdf
blog-plans/BLOG-PLAN-YYYY-MM-DD.pdf
blogs/{post-slug}.html
```

---

## Phase Overview

| Phase | Name | Saves to |
|---|---|---|
| 0 | Load Historical Context | (in memory only) |
| 1 | SEO Audit | `audit/AUDIT-*.pdf` |
| 2a | GSC Report | `research/GSC-REPORT-*.pdf` |
| 2b | GA4 Report | `research/GA4-REPORT-*.pdf` |
| 2c | Market Research (last30days) | `research/SOCIAL-TRENDS-*.pdf` |
| 3a | Keyword Research | `keywords/KEYWORDS-*.pdf` |
| 3b | SEO Plan (on-page changes) | `implementation/SEO-PLAN-*.pdf` |
| 3c | Blog Plan | `blog-plans/BLOG-PLAN-*.pdf` |
| 4 | Write 3 Blog Posts | `blogs/*.html` |
| ⏸ | **Approval Gate** | — |
| 5 | Execute: Post Blogs + On-page Changes | `implementation/SNAPSHOT-*.pdf` |
| 6 | Full Before/After Implementation Report | `audit/POST-IMPLEMENTATION-REPORT-*.pdf` |

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
Phase 3c (Blog Plan)    → 3 post plan — no topic overlap with prior blogs
       ↓
Phase 4 (Blogs)         → 3 posts written with tone guide applied
       ↓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏸  APPROVAL GATE — present summary, wait for explicit "approve"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
       ↓
Phase 5a (Post blogs)   → publish 3 posts to CMS as drafts (platform-specific)
Phase 5b (On-page)      → apply SEO title/meta/schema changes via API
Phase 5c (Snapshot)     → save before/after record
       ↓
Phase 6 (Report)        → full POST-IMPLEMENTATION-REPORT-*.pdf
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

## PDF Conversion — Apply After Every Phase Save

After writing each phase output file (AUDIT, GSC-REPORT, GA4-REPORT, SOCIAL-TRENDS, KEYWORDS, SEO-PLAN, SNAPSHOT, BLOG-PLAN, POST-IMPLEMENTATION-REPORT), write the file as `.md` first then immediately run this Python script via Bash:

```python
import subprocess, sys, os
subprocess.run([sys.executable, '-m', 'pip', 'install', 'markdown', '-q'], capture_output=True)
import markdown as md_lib

md_path = "<THE_EXACT_PATH_WRITTEN_ABOVE>"  # ← set to the actual path
html_path = md_path[:-3] + "_tmp.html"
pdf_path  = md_path[:-3] + ".pdf"

with open(md_path) as f:
    body = f.read()
html_body = md_lib.markdown(body, extensions=["tables", "fenced_code"])
html = f"""<!DOCTYPE html><html><head><meta charset="utf-8">
<style>body{{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;max-width:920px;margin:40px auto;padding:0 48px;color:#1a1a2e;line-height:1.65}}h1{{font-size:2em;border-bottom:3px solid #e0e0e8;padding-bottom:12px}}h2{{font-size:1.4em;color:#2d2d50;border-bottom:1px solid #eee;padding-bottom:6px;margin-top:36px}}h3{{color:#444;margin-top:24px}}table{{border-collapse:collapse;width:100%;margin:16px 0;font-size:.9em}}th{{background:#f0f0f8;font-weight:600;padding:10px 14px;border:1px solid #d0d0e0}}td{{padding:8px 14px;border:1px solid #d0d0e0}}tr:nth-child(even){{background:#f8f8fc}}code{{background:#f4f4f8;padding:2px 6px;border-radius:3px;font-family:monospace;font-size:.88em}}pre{{background:#f4f4f8;padding:16px;border-radius:6px}}pre code{{background:none;padding:0}}hr{{border:none;border-top:2px solid #eee;margin:28px 0}}</style>
</head><body>{html_body}</body></html>"""
with open(html_path, "w") as f:
    f.write(html)
chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
subprocess.run([chrome, "--headless", "--disable-gpu", "--no-sandbox",
                f"--print-to-pdf={pdf_path}", "--print-to-pdf-no-header",
                html_path], check=True, capture_output=True)
os.remove(html_path)
os.remove(md_path)
print(f"✅ PDF saved: {pdf_path}")
```

Do NOT convert `.html` blog files — those stay as `.html`.

---

## Sub-skill Reference Paths

Phase files reference sub-skills from the seo-and-blog plugin:
`.skills/skills/seo-and-blog/skills/<skill-name>.md`

Fallback to individual installed skills:
`.skills/skills/<skill-name>/SKILL.md`

If neither found, execute the skill logic from first principles using the skill name as guidance.
