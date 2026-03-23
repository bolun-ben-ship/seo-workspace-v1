# Phase 4 — User Approval

Present the implementation plan to the user and get explicit approval before making
any changes to the live Webflow site.

## Goal

The user sees exactly what will happen, category by category, and decides what to approve.
Nothing is changed in Webflow until approval is received.

## Step 1 — Present the Summary

Before using the approval tool, give the user a concise plain-text summary of the plan.
Format it like this:

```
Here's what I'll do. Please review and approve below.

📋 IMPLEMENTATION PLAN — <domain>

A) Title Tags          → X pages will be updated
B) Meta Descriptions   → X pages will be updated
C) Schema Injection    → X scripts across Y pages
D) Noindex Pages       → X pages will be noindexed
E) CMS Field Updates   → X changes
F) Manual (not done)   → X items flagged for your action

Estimated time to execute: ~5–10 minutes via API
No content will be deleted. All changes are reversible via API.
```

Then ask for approval using `AskUserQuestion` with multiple-choice options.

## Step 2 — Approval Question

Use the `AskUserQuestion` tool with the following structure:

**Question:**
"The implementation plan is ready. How would you like to proceed?"

**Options:**
1. ✅ Approve all — apply every change in Categories A–E
2. 🔍 Approve by category — choose which categories to run
3. 📄 Review the plan first — show me the full implementation plan document
4. ⏸ Skip for now — don't make any changes yet

If the user chooses **Option 2 (by category)**, ask a follow-up question for each category:

For each category (A, B, C, D, E), ask:
"Category [X] — [Title]: Apply [N] changes?"
Options: Yes / No / Show me the details first

If the user asks to see details first, summarise that category's changes inline
(before/after table), then re-ask the yes/no question.

## Step 3 — Handle Edge Cases

**If user approves but has concerns about specific pages:**
Ask: "Are there any specific pages you want to exclude from the changes?"
Let them name pages by URL slug. Remove those from the execution list.

**If user wants to review the plan document:**
Tell them the path: `Content & SEO/outputs/<domain>/implementation/IMPLEMENTATION-PLAN.md`
Then ask: "Ready to proceed when you are — just say 'go' or 'approve'."

**If user declines:**
Thank them and save the implementation plan for future reference. Stop here.

## Step 4 — Confirm Before Executing

Once you have approval, confirm what you're about to do:

```
Got it. I'll now apply:
✅ Category A — X title tag updates
✅ Category C — X schema scripts
✅ Category D — X noindex injections
⏭ Category B — skipped per your instruction

Starting Phase 5 now...
```

Then proceed to Phase 5.

## Important

- Never assume approval — always wait for an explicit response
- If the AskUserQuestion tool is unavailable, ask for approval in plain text
  and wait for the user's reply before doing anything
- Log which categories were approved so Phase 5 knows what to execute
  and Phase 6 can accurately document what was and wasn't changed
