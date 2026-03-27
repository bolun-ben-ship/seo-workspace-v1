---
name: update-everywhere
description: >
  Post-session propagation skill. After any working session, detects every file that
  changed (via git status + diff), classifies each change against the workspace
  propagation matrix, scans all dependent targets (SKILLS-REFERENCE.md, install.sh,
  README.md, workspace CLAUDE.md, client-template, all clients/*/CLAUDE.md and command
  folders, orchestrator SKILL.md files), builds a full before/after update plan, gets
  explicit approval, then executes every required propagation, runs install.sh, and
  verifies no stale references remain. Use after any session where skills, commands,
  orchestrators, output filenames, platform routing, or workspace structure changed.
user-invocable: true
argument-hint: "(no arguments — reads git diff to detect session changes)"
---

# update-everywhere

## Purpose

This skill is the workspace consistency enforcer. It answers the question:
*"What changed this session, and what needs to be updated everywhere as a result?"*

It does not guess — it reads git, reads the actual changed files, cross-references
the propagation rules, and produces a precise plan before touching anything.

---

## Propagation Matrix (reference)

Before building the plan, classify every changed file against this matrix:

| Change type | Required propagations |
|---|---|
| Skill `SKILL.md` modified (logic, description, output filenames changed) | Update SKILLS-REFERENCE.md entry; if output filenames changed → grep all files for old filename, fix every match |
| New skill folder created in `seo-workflow/` | Add to `install.sh` SKILLS array; add entry to SKILLS-REFERENCE.md; add to CLAUDE.md Workspace Structure diagram; add to `seo-workflow/README.md` Skill Index; update skill count in CLAUDE.md and SKILLS-REFERENCE.md header |
| Skill renamed or deleted | Remove/rename in `install.sh` SKILLS array; add old name to legacy removal list in install.sh; update SKILLS-REFERENCE.md; update README.md; update CLAUDE.md; grep entire `seo-workflow/` for old name → fix all matches in Sub-skill Reference Paths sections of orchestrators; grep all `clients/*/CLAUDE.md` for old name → fix matches |
| Command file (`.claude/commands/*.md`) modified | Update SKILLS-REFERENCE.md entry for that command; copy updated file to every `clients/*/.claude/commands/` folder; run install.sh |
| New command file added | Same as modified + add to CLAUDE.md Commands table |
| `install.sh` modified directly | Verify SKILLS array matches actual `seo-workflow/` subdirectories (no orphans, no missing) |
| `CLAUDE.md` (workspace root) modified | Check `client-template/CLAUDE.md` for consistency with changed sections |
| Platform routing table changed in any orchestrator | Check all other orchestrators (ai-seo-pipeline, 3blog-seo-first-run, shopline-onpage-implement, webflow-onpage-implement) for consistency |
| New orchestrator added | Add to SKILLS-REFERENCE.md Orchestrators section; check seo-and-blog router description; update Skill Dependency Map in SKILLS-REFERENCE.md |
| Output filename convention changed | Grep `seo-workflow/` and repo root for old filename pattern; fix every match across all SKILL.md files, SKILLS-REFERENCE.md, and any CLAUDE.md that references output paths |
| New client added or client folder modified | Update `clients.md`; verify client folder has all required files from client-template |

---

## Phase 1 — Detect Session Changes

Run these two commands and capture the full output:

```bash
git -C /path/to/workspace status
git -C /path/to/workspace diff HEAD
```

The workspace root is the directory containing `CLAUDE.md` and `seo-workflow/`. If running
from the workspace root already, use `.` as the path.

Also check for untracked new files:
```bash
git -C /path/to/workspace ls-files --others --exclude-standard
```

Produce a structured change list:
```
MODIFIED:
  M  seo-workflow/gsc-report/SKILL.md
  M  SKILLS-REFERENCE.md

ADDED (new files, untracked):
  ?? seo-workflow/update-everywhere/SKILL.md

DELETED:
  D  seo-workflow/old-skill/SKILL.md
```

If git reports no changes at all (clean working tree with no untracked files),
tell the user: "No changes detected since last commit. Nothing to propagate."
and stop.

---

## Phase 2 — Deep-Read All Changed Files

For every file in the change list:
1. Read the full current content of the file from disk
2. If the file was modified (not new), also read `git diff HEAD -- {file}` to see exactly
   what changed (added/removed lines)

Additionally, always read the current state of all propagation targets — these need
to be checked regardless of what changed:
- `SKILLS-REFERENCE.md`
- `seo-workflow/install.sh`
- `seo-workflow/README.md` (if it exists)
- `CLAUDE.md` (workspace root)
- `client-template/CLAUDE.md` (if it exists)
- All `clients/*/CLAUDE.md` files (glob: `clients/*/CLAUDE.md`)
- All `clients/*/.claude/commands/*.md` files
- Any orchestrator SKILL.md files that may reference changed skills:
  `seo-workflow/ai-seo-pipeline/SKILL.md`,
  `seo-workflow/3blog-seo-first-run/SKILL.md`,
  `seo-workflow/shopline-onpage-implement/SKILL.md`,
  `seo-workflow/webflow-onpage-implement/SKILL.md`,
  `seo-workflow/seo-and-blog/SKILL.md`

---

## Phase 3 — Classify and Cross-Reference

For each changed file, apply the Propagation Matrix to determine what needs updating.

For each classification, check whether the required update is already done or still needed:
- Read the target file and look for the relevant section
- If already up to date → mark as ✅ (no action needed)
- If outdated or missing → mark as ⚠️ (action required) and note exactly what needs changing

Group findings into two buckets:
- **Already consistent** (no action needed)
- **Requires propagation** (will be updated)

Special checks to always run regardless of what changed:
1. **install.sh integrity** — verify every folder in `seo-workflow/` (excluding `agents/`)
   that contains a `SKILL.md` is present in the SKILLS array in `install.sh`, and vice versa.
   Any mismatch is a required propagation.
2. **SKILLS-REFERENCE.md completeness** — verify every skill in the SKILLS array has an entry
   in SKILLS-REFERENCE.md. Any missing entry is a required propagation.
3. **Stale skill name grep** — if any skill was renamed or deleted, grep `seo-workflow/`
   for the old name to catch orphaned references in Sub-skill Reference Paths sections.

---

## Phase 4 — Build Propagation Plan

Present the plan as a table:

```
## Propagation Plan — {N} updates required

| # | File to update | Section / location | What changes | Why |
|---|---|---|---|---|
| 1 | SKILLS-REFERENCE.md | `/gsc-report` entry | Update output filename from X to Y | gsc-report SKILL.md changed output path |
| 2 | seo-workflow/install.sh | SKILLS array | Add `update-everywhere` at line 42 | New skill folder created |
| 3 | clients/aexphl/.claude/commands/start-client.md | Full file replace | Sync with updated client-template version | Command logic changed |
...

Already consistent (no action needed):
- CLAUDE.md Workspace Structure — already reflects current skill set ✅
- client-template/CLAUDE.md — no command changes ✅
```

Also state:
- How many client folders will be affected by command propagation (e.g. "2 client folders")
- Whether install.sh will be re-run
- Whether any grep/fix passes are needed for renamed output files

---

## Phase 5 — Approval Gate

⏸ **APPROVAL GATE**

Present the full propagation plan. Do not proceed until the user explicitly approves.

Say:
```
Ready to execute {N} propagation updates across {M} files.
Type "yes", "proceed", or "go" to execute — or tell me what to change first.
```

If the user says "skip", "cancel", or "nothing to do", stop here.

---

## Phase 6 — Execute All Propagations

Work through the plan table in order. For each item:

1. Read the target file (required before any edit)
2. Make the precise edit using the Edit tool — never rewrite whole files unless
   absolutely necessary
3. Mark the item complete in your running count

For multi-client command propagation, loop through every `clients/*/` folder:
- Check if `.claude/commands/` exists in that client folder
- If yes, copy the updated command file content into it (read source, write to target)

For grep/fix passes on renamed output filenames:
- Grep `seo-workflow/` for the old filename pattern
- Read each match file
- Edit to replace old filename with new filename

For install.sh SKILLS array additions:
- Insert the new skill name in alphabetical order within the array

For SKILLS-REFERENCE.md:
- Find the correct section (Orchestrators, Research, Audit Suite, etc.) based on skill type
- Add the new entry with the standard format:
  ```
  ### `/{skill-name}`
  **What it does:** {description}
  **Output:** {output files if any}
  ```
- Update the skill count in the header line

---

## Phase 7 — Deploy

Run install.sh to deploy all changes:

```bash
bash seo-workflow/install.sh
```

Confirm the output shows all skills as ✓. If any skill shows ✗, investigate and fix.

---

## Phase 8 — Verify

Re-read all modified files and run a final consistency check:

1. **install.sh ↔ seo-workflow/ sync check** — list all `seo-workflow/*/SKILL.md` files,
   compare against SKILLS array in install.sh. Report any mismatches.

2. **SKILLS-REFERENCE.md completeness** — confirm every skill in the SKILLS array has
   an entry in SKILLS-REFERENCE.md.

3. **Stale reference check** — if any skill was renamed/deleted, grep one more time for
   the old name across `seo-workflow/` and `clients/`. Report any remaining matches.

4. **Client command sync check** — if any commands were propagated, verify the file content
   in `clients/*/.claude/commands/` matches the source in `client-template/.claude/commands/`.

Report the verification result:

```
Verification complete:
✅ install.sh ↔ seo-workflow/ — 24/24 skills synced
✅ SKILLS-REFERENCE.md — all 24 skills have entries
✅ No stale references found for renamed/deleted skills
✅ Client commands synced across 2 client folders
✅ install.sh deployed — 24/24 skills ✓

All propagations complete. Workspace is consistent.
```

If any check fails, fix it before reporting complete.

---

## Phase 9 — Commit and Push

After verification passes, stage all changes and push to git.

1. **Stage all modified files:**
   ```bash
   git add -A
   ```

2. **Show what will be committed:**
   ```bash
   git status
   ```
   Present the staged file list to the user so they can see exactly what is going in.

3. **Write the commit message** — summarise what changed this session based on the
   classified changes from Phase 3. Format:

   ```
   chore: propagate session changes

   - {change 1 description}
   - {change 2 description}
   ...

   Updated: SKILLS-REFERENCE.md, install.sh, {other files}
   ```

   Examples of good change lines:
   - `add update-everywhere skill`
   - `rename seo-keywords → keyword-research`
   - `update gsc-report output filename convention`
   - `sync start-client command to 2 client folders`

4. **Commit:**
   ```bash
   git commit -m "{commit message}"
   ```

5. **Push:**
   ```bash
   git push
   ```

6. **Confirm** — report the push result including the remote branch and commit hash:
   ```
   ✅ Pushed to origin/main — abc1234
      "chore: propagate session changes"
   ```

If `git push` fails (e.g. remote has diverged), do NOT force push. Report the error
and tell the user to resolve the conflict manually before pushing.

---

## Notes

- This skill operates on the **agency workspace root**, not a client folder.
  Run it from `RightClickAI-seo-workspace/`, not from inside `clients/{domain}/`.
- If you're unsure whether a change is "fundamental enough" to propagate, propagate it.
  Over-propagation is safe. Under-propagation causes silent drift.
- The skill reads the conversation's effect through git, not the conversation itself.
  All detection is based on actual file system state.
- Never skip the approval gate — even for small changes. The plan must be reviewed
  before execution so the user can catch any misclassifications.
