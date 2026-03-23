# /start-agency

Load full agency context and produce an Agency Briefing for this session.

Run this at the start of every agency workspace session so Claude knows exactly
what this workspace is, what clients are active, and what capabilities are available.

---

## Step 1 — Read agency configuration

Read these files in this order:
1. `CLAUDE.md` — workspace structure, rules, skill library location
2. `context/agency-info.md` — what RightClick:AI does, skill stack, client types
3. `context/agency-strategy.md` — current strategic priorities and focus
4. `clients.md` — all active clients, platforms, status

---

## Step 2 — Scan installed capabilities

Run these two commands to inventory what's available:

```bash
ls seo-workflow/ | grep -v '^\.' | sort
```
List skill and orchestrator folders (each folder = one deployable skill).

```bash
ls seo-workflow/agents/
```
List subagent files.

```bash
ls .claude/commands/
```
List all available slash commands (each .md file = one command).

---

## Step 3 — Produce Agency Briefing

Output a structured briefing in this exact format:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Agency Briefing — RightClick:AI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

What this workspace is:
[1–2 sentence summary from agency-info.md]

Active Clients:
┌─────────────────────┬──────────┬────────────────┬──────────┐
│ Client              │ Domain   │ Platform       │ Status   │
├─────────────────────┼──────────┼────────────────┼──────────┤
│ [from clients.md]   │ ...      │ ...            │ ...      │
└─────────────────────┴──────────┴────────────────┴──────────┘

Skills installed: N/19
[bullet list of all skill/orchestrator folder names]

Agents installed: N/6
[bullet list of agent filenames]

Available commands:
[bullet list of .md filenames in .claude/commands/]

Strategic focus:
[1–2 sentence summary from agency-strategy.md — or "Not yet configured" if template is unfilled]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After the briefing, say:

> Ready. What would you like to work on?

---

## Notes

- To work on a specific client, open `clients/{domain}/` as a separate Claude Code project and run `/start-client`
- The skill library source of truth is `seo-workflow/` — always edit skills there, then run `bash seo-workflow/install.sh` to deploy
- To onboard a new client: `/onboard domain.com`
