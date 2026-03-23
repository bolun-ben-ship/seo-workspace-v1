# Phase 4 — User Approval

Present the implementation plan and get explicit approval before making any changes
to the live Shopline store. Nothing is written via API until approval is received.

## Step 1 — Present the Summary

```
Here's what I'll do. Please review and approve below.

📋 IMPLEMENTATION PLAN — {STORE_HANDLE}.myshopline.com

A) Page SEO Titles        → X pages will be updated
B) Page Meta Descriptions → X pages will be updated
C) Blog Post SEO Titles   → X posts will be updated
D) Blog Post Meta Descs   → X posts will be updated
E) New Blog Posts         → X posts will be created and published
F) Schema in Content      → X posts will have JSON-LD injected
G) Manual (not done)      → X items flagged for your action

All changes are via MetafieldsSet + article create/update calls.
No content will be deleted. All changes are reversible via API.
```

## Step 2 — Approval Question

Use `AskUserQuestion` with these options:

**Question:** "The implementation plan is ready. How would you like to proceed?"

**Options:**
1. ✅ Approve all — apply every change in Categories A–F
2. 🔍 Approve by category — choose which categories to run
3. 📄 Review the plan first — show me the full implementation plan
4. ⏸ Skip for now — don't make any changes yet

If the user chooses **Option 2 (by category)**, ask for each:
"Category [X] — [Name]: Apply [N] changes? Yes / No / Show me details first"

If they ask for details, show the before/after table for that category, then re-ask.

## Step 3 — Edge Cases

**User wants to exclude specific pages or posts:**
Ask: "Are there any pages or blog posts you want to exclude?"
Let them name by title or slug. Remove those from the execution list.

**User wants to review the plan document:**
Give them the path and say: "Ready when you are — just say 'go' or 'approve'."

**User declines:** Save the plan for future reference and stop.

## Step 4 — Confirm Before Executing

```
Got it. I'll now apply:
✅ Category A — X page SEO title updates
✅ Category C — X blog post SEO title updates
✅ Category E — X new blog posts (create + publish)
⏭ Category B — skipped per your instruction

Starting Phase 5 now...
```

## Important

- Never assume approval — always wait for explicit response
- Log which categories were approved so Phase 5 knows what to execute
  and Phase 6 accurately documents what was and wasn't changed
- If `AskUserQuestion` is unavailable, ask in plain text and wait
