# /initialise

Full workspace setup for a new machine. Run this once after cloning the repo to install
all skills, verify all dependencies, check credentials, and confirm the workspace is
ready to operate.

---

## Step 1 — Deploy all skills and agents

```bash
bash seo-workflow/install.sh
```

Verify output shows all skills ✓ and all agents ✓ before continuing.

---

## Step 2 — Check system tools

```bash
for tool in python3 pip3 node npx git; do
  command -v "$tool" &>/dev/null && echo "$tool ✓" || echo "$tool ✗ — NOT FOUND"
done
```

If any tool is missing, report it with the install command:
- `python3` / `pip3` → `brew install python`
- `node` / `npx` → `brew install node`
- `git` → `xcode-select --install`

---

## Step 3 — Check Python dependencies

```bash
for pkg in google-analytics-data google-api-python-client google-auth requests playwright Pillow; do
  pip3 show "$pkg" &>/dev/null 2>&1 && echo "$pkg ✓" || echo "$pkg ✗ — run: pip3 install $pkg"
done
```

For any missing packages, collect them and provide a single install command:
```
pip3 install google-analytics-data google-api-python-client google-auth requests playwright Pillow
```

---

## Step 4 — Check Playwright browser (required for /carousel PNG export)

```bash
python3 -c "
import subprocess, sys
result = subprocess.run(['python3', '-m', 'playwright', 'install', '--dry-run', 'chromium'],
  capture_output=True, text=True)
if 'chromium' in result.stdout.lower() or result.returncode == 0:
    print('Playwright Chromium ✓')
else:
    print('Playwright Chromium ✗ — run: python3 -m playwright install chromium')
" 2>/dev/null || echo "Playwright not installed — run: pip3 install playwright && python3 -m playwright install chromium"
```

If Chromium is not installed, provide:
```
python3 -m playwright install chromium
```

---

## Step 5 — Check environment variables

Check all known env vars for this workspace. For each one, report SET ✓ or NOT SET ✗.

```bash
# Google credential file vars — must be set AND point to a real file
for var in OWLLIGHT_GOOGLE_KEY AEXPHL_GOOGLE_KEY; do
  val="${!var:-}"
  if [ -z "$val" ]; then
    echo "$var ✗ — not set"
  elif [ ! -f "$val" ]; then
    echo "$var ✗ — set but file not found at: $val"
  else
    echo "$var ✓"
  fi
done

# Token vars — just need to be non-empty
for var in SHOPLINE_OWLLIGHT_TOKEN WEBFLOW_AEXPHL_TOKEN OPENAI_API_KEY; do
  [ -n "${!var:-}" ] && echo "$var ✓" || echo "$var ✗ — not set"
done
```

For every missing env var, output the exact line to add to `~/.zshrc`:

| Var | What it is | Line to add to ~/.zshrc |
|---|---|---|
| `OWLLIGHT_GOOGLE_KEY` | Path to Owllight Google service account JSON | `export OWLLIGHT_GOOGLE_KEY="/path/to/owllight-key.json"` |
| `AEXPHL_GOOGLE_KEY` | Path to AEXPHL Google service account JSON | `export AEXPHL_GOOGLE_KEY="/path/to/aexphl-key.json"` |
| `SHOPLINE_OWLLIGHT_TOKEN` | Shopline Admin API token for Owllight | `export SHOPLINE_OWLLIGHT_TOKEN="your-token-here"` |
| `WEBFLOW_AEXPHL_TOKEN` | Webflow API token for AEXPHL | `export WEBFLOW_AEXPHL_TOKEN="your-token-here"` |
| `OPENAI_API_KEY` | OpenAI API key (used by /last30days) | `export OPENAI_API_KEY="your-key-here"` |

After listing missing vars, remind the user:
```
After editing ~/.zshrc, run: source ~/.zshrc
Then restart Claude Code to pick up the new env vars.
```

---

## Step 6 — Check credential files

```bash
WORKSPACE_ROOT="$(pwd)"
OWLLIGHT_JSON="$WORKSPACE_ROOT/clients/owllight/owllight-claude-seo-project-c389d3b33dd1.json"
[ -f "$OWLLIGHT_JSON" ] && echo "Owllight JSON key ✓" || echo "Owllight JSON key ✗ — not found at: $OWLLIGHT_JSON"
```

If file is missing, tell the user:
> Download the service account JSON key from Google Cloud Console and place it at the expected path shown above.

---

## Step 7 — Check workspace folder structure

Verify the key folders exist:

```bash
WORKSPACE_ROOT="$(pwd)"
for dir in \
  "seo-workflow" \
  "clients/aexphl" \
  "clients/owllight" \
  "client-template" \
  "context" \
  "outputs" \
  ".claude/commands"; do
  [ -d "$WORKSPACE_ROOT/$dir" ] && echo "$dir ✓" || echo "$dir ✗ — MISSING"
done
```

If any folder is missing, flag it as a repo integrity issue (likely incomplete clone).

---

## Step 8 — Print Initialisation Report

Output in this format:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 RightClick:AI — Workspace Initialisation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Skills deployed:    24/24 ✓ / ✗ (N missing — re-run: bash seo-workflow/install.sh)
Agents deployed:    6/6 ✓ / ✗

System tools:
  python3   ✓/✗
  pip3      ✓/✗
  node      ✓/✗
  npx       ✓/✗
  git       ✓/✗

Python packages:
  google-analytics-data        ✓/✗
  google-api-python-client     ✓/✗
  google-auth                  ✓/✗
  requests                     ✓/✗
  playwright                   ✓/✗
  Pillow                       ✓/✗

Playwright Chromium:           ✓/✗

Environment variables:
  OWLLIGHT_GOOGLE_KEY          ✓/✗
  AEXPHL_GOOGLE_KEY            ✓/✗
  SHOPLINE_OWLLIGHT_TOKEN      ✓/✗
  WEBFLOW_AEXPHL_TOKEN         ✓/✗
  OPENAI_API_KEY               ✓/✗

Credential files:
  Owllight JSON key            ✓/✗

Workspace folders:             ✓ all present / ✗ N missing

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RESULT: READY ✓ / ACTION REQUIRED ✗
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If RESULT is ACTION REQUIRED:
- List every issue as a numbered step with the exact command or action to fix it
- End with: "Fix the items above, then re-run /initialise to confirm everything is green."

If RESULT is READY:
- Say: "Workspace is fully initialised. Open a client folder in Claude Code and run /prime to load deep context, or /start-client for a quick briefing."
