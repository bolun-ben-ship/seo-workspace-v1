# Implementation Plan — Tone Guide Workflow

**Date:** 2026-03-22
**Status:** Pending approval

---

## What This Adds

A structured tone guide system so blog writing always reflects the client's voice — not generic SEO copy. Some clients (e.g. AEXPHL) have strong brand voice requirements. This workflow makes that easy to maintain and automatically applies it.

---

## The Workflow

```
Client has context/tone-guide.md
        ↓
/blog-write reads it before writing
        ↓
Every post reflects the client's voice, not generic SEO output
        ↓
Partner shows client → client says "this sounds like us"
        ↓
Partner retains client → RightClick:AI retains partner
```

---

## Files to Create

| File | Notes |
|---|---|
| `client-template/context/tone-guide.md` | Blank template with structure for /onboard to scaffold |
| `clients/aexphl/context/tone-guide.md` | Pre-filled from Tim's personal-info.md + brand rules |
| `clients/owllight/context/tone-guide.md` | Placeholder — to be filled with Owllight voice guidelines |

## Files to Modify

| File | Change |
|---|---|
| `seo-workflow/seo-and-blog/skills/blog-write.md` | Add: "Before writing, check for context/tone-guide.md. If found, read it and apply throughout." |
| `seo-workflow/monthly-seo-run/phases/4-content.md` | Same addition (when monthly-seo-run is built) |
| `client-template/CLAUDE.md` | Add `context/tone-guide.md` to Context Loading Rules table |
| `clients/aexphl/CLAUDE.md` | Add to Context Loading Rules |
| `clients/owllight/CLAUDE.md` | Add to Context Loading Rules |
| `SKILLS-REFERENCE.md` | Note tone-guide in blog-write entry |

---

## Tone Guide File Structure (`context/tone-guide.md`)

```markdown
# [Client Name] — Tone Guide

## Voice in one sentence
[The single clearest description of how this brand sounds]

## Audience
[Who is reading this. What they care about. What they already know.]

## Voice characteristics
- [Characteristic 1 — e.g. "Direct. No filler sentences."]
- [Characteristic 2]
- [Characteristic 3]

## Sentence structure
[How long are sentences? Active or passive? First person or third?]

## Words and phrases we use
- [Word/phrase + why it fits]

## Words and phrases we never use
- [Word/phrase + what to say instead]

## Topics we lead with
[What angle always works for this audience]

## Topics we avoid or handle carefully
[Anything that conflicts with brand values]

## Example: Good vs Bad

**Good:** "[Example sentence that sounds right]"
**Bad:** "[Example sentence that sounds generic or off-brand]"

## Additional rules
[Any client-specific requirements — formatting, disclaimers, CTAs, etc.]
```

---

## AEXPHL Tone Guide (pre-fill from existing context)

Will synthesise from:
- `context/personal-info.md` (Tim's values, the Expat Support Method, who he works with)
- `context/client-info.md` (what differentiates AEXPHL)
- `CLAUDE.md` Voice & Tone section

Key rules that will appear:
- Never: generic broker tone, fear-based framing, "dream home" language
- Always: lived expat experience, clarity over complexity, integrity-first
- Leads with: understanding the expat's specific situation, not product pushing
- Sentence style: direct, confident, no hedging

---

## How Partners Manage This

**To update a tone guide:**
1. Open `clients/{domain}/context/tone-guide.md`
2. Edit the relevant sections
3. Run `/blog-write` — new posts automatically reflect the update

No skill changes needed. Just edit the file.

**To create a tone guide for a new client:**
`/onboard` scaffolds a blank `context/tone-guide.md` from the template.
Fill it in during or after onboarding.

---

## What Does NOT Change

- `blog-write` core logic — just adds a "check for tone-guide" step at the top
- Any existing client outputs
- Clients without a tone-guide.md are unaffected (step is silently skipped)

---

## Awaiting Approval

Present this plan and wait for explicit approval before creating files.
