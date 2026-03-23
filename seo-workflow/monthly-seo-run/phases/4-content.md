# Phase 4 — Write 3 Blog Posts

**Goal:** Write all three blog posts from the Blog Plan, applying the client's tone guide.

---

## Step 1 — Load inputs

Load the following:
1. `blog-plans/BLOG-PLAN-YYYY-MM-DD.md` (today's date) — the 3 post specs from Phase 3c
2. `context/tone-guide.md` — brand voice, writing style, formatting rules (skip silently if absent)
3. `context/client-info.md` — products, audience, brand positioning
4. `HISTORICAL_CONTEXT.prior_blog_topics` — to confirm no overlap

If `tone-guide.md` is absent, note: "No tone guide found — writing to brand context from client-info.md only."

---

## Step 2 — Read the tone guide (if it exists)

Before writing any post, fully internalise the tone guide:
- **Voice** — how the brand speaks (formal/casual, expert/friendly, etc.)
- **Do/Don't list** — explicit style rules
- **Sentence patterns** — length, rhythm, structural preferences
- **Word choices** — preferred and avoided vocabulary
- **Formatting rules** — headers, bullets, CTA style

The tone guide overrides any default writing style. Apply it consistently across all three posts.

---

## Step 3 — Write each post

Write all three posts. Each post must:
- Match its spec from the Blog Plan exactly (title, target keyword cluster, template type, word count)
- Open with a hook that speaks directly to the target audience's problem or question
- Include the primary keyword naturally in: H1, first 100 words, at least one H2, meta description line at bottom
- Include secondary keywords where they fit naturally — never forced
- Follow the tone guide throughout
- End with a clear CTA appropriate for the brand (product link, enquiry form, consultation, etc.)

**HTML format requirements:**
- Full HTML structure: `<article>` wrapper, `<h1>`, `<h2>`, `<h3>`, `<p>`, `<ul>/<ol>`, `<strong>`, `<a href>` for internal links where relevant
- Include `<!-- META: title="..." description="..." -->` comment at top of each file
- Do NOT include `<html>`, `<head>`, or `<body>` tags — CMS-ready fragment only
- Image placeholders: `<img src="PLACEHOLDER" alt="[descriptive alt text]">` where visuals would aid the post

**Word count:** Respect the word count spec from the Blog Plan. Don't pad. Don't truncate.

---

## Step 4 — Self-review each post

Before saving, check each post:
- [ ] Primary keyword in H1, first 100 words, and at least one H2
- [ ] Secondary keywords appear naturally
- [ ] Tone matches the tone guide (or client-info.md if no guide)
- [ ] Word count is within ±10% of spec
- [ ] CTA is present and appropriate
- [ ] No topic overlap with `HISTORICAL_CONTEXT.prior_blog_topics`
- [ ] HTML is well-formed

Fix any issues before saving.

---

## Step 5 — Generate slugs and save

For each post, generate a URL-friendly slug from the title:
- Lowercase, hyphens not underscores
- 3–6 words maximum
- Include primary keyword where natural
- Examples: `best-mattress-back-pain-singapore`, `expat-mortgage-guide-australia`

```bash
mkdir -p "Content & SEO/outputs/{platform}-{handle}/blogs"
```

Save each post to:
`Content & SEO/outputs/{platform}-{handle}/blogs/{post-slug}.html`

---

## Step 6 — Confirm and summarise

After saving all three:

```
Phase 4 complete — 3 blog posts written and saved.

Post 1: [Title]
  Slug:     {post-1-slug}.html
  Keywords: [primary] + [secondary 1], [secondary 2]
  Words:    ~XXXX
  Template: [how-to / comparison / FAQ / case study / listicle]

Post 2: [Title]
  Slug:     {post-2-slug}.html
  Keywords: [primary] + [secondary 1], [secondary 2]
  Words:    ~XXXX
  Template: [type]

Post 3: [Title]
  Slug:     {post-3-slug}.html
  Keywords: [primary] + [secondary 1], [secondary 2]
  Words:    ~XXXX
  Template: [type]
```

---

## Approval Gate

After Phase 4 completes, present the full approval summary before proceeding.

**DO NOT proceed to Phase 5 without explicit user approval.**

Present:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏸  APPROVAL GATE — Monthly SEO Run
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Ready to execute. Please review and approve:

BLOG POSTS (3) — will be posted to CMS:
  1. [Title] → /{slug}
  2. [Title] → /{slug}
  3. [Title] → /{slug}

ON-PAGE CHANGES (N) — will be applied via API:
  [Summary table of top 5 changes from SEO Plan]
  ... and N more (see SEO-PLAN-YYYY-MM-DD.md for full list)

KEYWORD TARGETS — N new keywords tracked from this month

Type "approve" to execute Phase 5, or provide feedback to revise.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
