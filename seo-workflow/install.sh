#!/bin/bash
# install.sh — SEO Workflow installer + workspace auditor for Mac/Linux
#
# Usage:
#   bash install.sh           → install all skills and agents, then run audit
#   bash install.sh --audit   → run audit only (no install)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"   # parent of seo-workflow/ = agency root
SKILLS_DIR="$HOME/.claude/skills"
AGENTS_DIR="$HOME/.claude/agents"

AUDIT_ONLY=false
[[ "${1:-}" == "--audit" ]] && AUDIT_ONLY=true

SKILLS=(
  3blog-pipeline
  ai-seo-pipeline
  carousel
  ga4-report
  gsc-report
  last30days
  monthly-seo-run
  seo-and-blog
  seo-audit
  seo-competitor-pages
  seo-content
  seo-final-report
  seo-geo
  seo-hreflang
  seo-images
  seo-implementation-plan
  seo-page
  seo-plan
  seo-programmatic
  seo-schema
  seo-sitemap
  seo-technical
  shopline-onpage-implement
  webflow-onpage-implement
)

AGENTS=(
  seo-content.md
  seo-performance.md
  seo-schema.md
  seo-sitemap.md
  seo-technical.md
  seo-visual.md
)

# ─── INSTALL ─────────────────────────────────────────────────────────────────

if [ "$AUDIT_ONLY" = false ]; then
  echo "SEO Workflow Installer"
  echo "======================"
  echo "Source: $SCRIPT_DIR"
  echo ""

  # --- Skills ---
  echo "Installing skills to $SKILLS_DIR..."
  mkdir -p "$SKILLS_DIR"

  for skill in "${SKILLS[@]}"; do
    if [ -d "$SCRIPT_DIR/$skill" ]; then
      rm -rf "$SKILLS_DIR/$skill"
      cp -r "$SCRIPT_DIR/$skill" "$SKILLS_DIR/$skill"
      echo "  ✓ $skill"
    else
      echo "  ✗ $skill (not found in repo — skipping)"
    fi
  done

  # Remove legacy/renamed skills
  for legacy in seo seo-blog-implement shopline-seo-orchestrator webflow-seo-orchestrator site-automate; do
    if [ -d "$SKILLS_DIR/$legacy" ]; then
      rm -rf "$SKILLS_DIR/$legacy"
      echo "  ✓ Removed legacy skill: $legacy"
    fi
  done

  echo ""

  # --- Agents ---
  echo "Installing subagents to $AGENTS_DIR..."
  mkdir -p "$AGENTS_DIR"

  for agent in "${AGENTS[@]}"; do
    if [ -f "$SCRIPT_DIR/agents/$agent" ]; then
      cp "$SCRIPT_DIR/agents/$agent" "$AGENTS_DIR/$agent"
      echo "  ✓ $agent"
    else
      echo "  ✗ $agent (not found in repo — skipping)"
    fi
  done

  echo ""
  echo "Done. Restart Claude Code to activate all skills."
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⚠️  SKILLS-REFERENCE.md INTEGRITY CHECK"
  echo "   If you added, renamed, or changed any skill:"
  echo "   → Update SKILLS-REFERENCE.md in the agency root NOW"
  echo "   → Confirm to the user: 'SKILLS-REFERENCE.md has been updated ✅'"
  echo "   → Do NOT close the task without this confirmation"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi

# ─── AUDIT ───────────────────────────────────────────────────────────────────

run_audit() {
  echo ""
  echo "=== Workspace Audit ==="
  echo ""

  ISSUES=()

  # --- System tools ---
  TOOL_STATUS=""
  for tool in python3 node npx pip3; do
    if command -v "$tool" &>/dev/null; then
      TOOL_STATUS+="$tool ✓  "
    else
      TOOL_STATUS+="$tool ✗  "
      ISSUES+=("$tool not found in PATH — install it before running API-dependent skills")
    fi
  done
  printf "System tools:   %s\n" "$TOOL_STATUS"

  # --- Skills ---
  SKILLS_FOUND=0
  SKILLS_TOTAL=${#SKILLS[@]}
  for skill in "${SKILLS[@]}"; do
    [ -d "$SKILLS_DIR/$skill" ] && ((SKILLS_FOUND++)) || true
  done
  if [ "$SKILLS_FOUND" -eq "$SKILLS_TOTAL" ]; then
    printf "Skills:         %d/%d deployed ✓\n" "$SKILLS_FOUND" "$SKILLS_TOTAL"
  else
    printf "Skills:         %d/%d deployed ✗\n" "$SKILLS_FOUND" "$SKILLS_TOTAL"
    ISSUES+=("Only $SKILLS_FOUND/$SKILLS_TOTAL skills deployed — run: bash install.sh")
  fi

  # --- Agents ---
  AGENTS_FOUND=0
  AGENTS_TOTAL=${#AGENTS[@]}
  for agent in "${AGENTS[@]}"; do
    [ -f "$AGENTS_DIR/$agent" ] && ((AGENTS_FOUND++)) || true
  done
  if [ "$AGENTS_FOUND" -eq "$AGENTS_TOTAL" ]; then
    printf "Agents:         %d/%d deployed ✓\n" "$AGENTS_FOUND" "$AGENTS_TOTAL"
  else
    printf "Agents:         %d/%d deployed ✗\n" "$AGENTS_FOUND" "$AGENTS_TOTAL"
    ISSUES+=("Only $AGENTS_FOUND/$AGENTS_TOTAL agents deployed — run: bash install.sh")
  fi

  # --- Python dependencies ---
  PY_STATUS=""
  for dep in google-analytics-data google-api-python-client google-auth requests; do
    if pip3 show "$dep" &>/dev/null 2>&1; then
      PY_STATUS+="$dep ✓  "
    else
      PY_STATUS+="$dep ✗  "
      ISSUES+=("Python package '$dep' not installed — run: pip3 install $dep")
    fi
  done
  printf "Python deps:    %s\n" "$PY_STATUS"

  # --- Environment variables ---
  ENV_STATUS=""

  # Google key vars: must be set AND point to an existing file
  check_file_env() {
    local varname="$1"
    local val="${!varname:-}"
    if [ -z "$val" ]; then
      ENV_STATUS+="$varname ✗(not set)  "
      ISSUES+=("$varname not set — add to ~/.zshrc: export $varname=\"/path/to/key.json\"")
    elif [ ! -f "$val" ]; then
      ENV_STATUS+="$varname ✗(file missing)  "
      ISSUES+=("$varname is set but JSON file not found at: $val")
    else
      ENV_STATUS+="$varname ✓  "
    fi
  }

  # Token vars: just check if set (non-empty)
  check_token_env() {
    local varname="$1"
    local val="${!varname:-}"
    if [ -z "$val" ]; then
      ENV_STATUS+="$varname ✗  "
      ISSUES+=("$varname not set — add to ~/.zshrc: export $varname=\"your-token\"")
    else
      ENV_STATUS+="$varname ✓  "
    fi
  }

  check_file_env  "OWLLIGHT_GOOGLE_KEY"
  check_file_env  "AEXPHL_GOOGLE_KEY"
  check_token_env "SHOPLINE_OWLLIGHT_TOKEN"
  check_token_env "WEBFLOW_AEXPHL_TOKEN"
  check_token_env "OPENAI_API_KEY"
  printf "Env vars:       %s\n" "$ENV_STATUS"

  # --- Known credential files (direct path check) ---
  CREDS_STATUS=""
  OWLLIGHT_JSON="$WORKSPACE_ROOT/clients/owllight/owllight-claude-seo-project-c389d3b33dd1.json"
  if [ -f "$OWLLIGHT_JSON" ]; then
    CREDS_STATUS+="owllight JSON ✓  "
  else
    CREDS_STATUS+="owllight JSON ✗  "
    ISSUES+=("owllight JSON key not found — expected at: $OWLLIGHT_JSON")
  fi
  CREDS_STATUS+="aexphl JSON: see AEXPHL_GOOGLE_KEY above"
  printf "Credentials:    %s\n" "$CREDS_STATUS"

  # --- Summary ---
  echo ""
  if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "Issues found: 0 — all checks passed ✓"
    echo ""
    echo "Next: restart Claude Code to activate all skills."
  else
    printf "Issues found: %d\n" "${#ISSUES[@]}"
    for issue in "${ISSUES[@]}"; do
      echo "  - $issue"
    done
    echo ""
    echo "Fix the issues above, then re-run: bash seo-workflow/install.sh --audit"
  fi
  echo ""
}

run_audit
