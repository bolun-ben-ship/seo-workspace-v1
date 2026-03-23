# install.ps1 — SEO Workflow installer for Windows
# Run from PowerShell: .\install.ps1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsDir = "$env:USERPROFILE\.claude\skills"
$AgentsDir = "$env:USERPROFILE\.claude\agents"

Write-Host "SEO Workflow Installer"
Write-Host "======================"
Write-Host "Source: $ScriptDir"
Write-Host ""

# --- Skills ---
Write-Host "Installing skills to $SkillsDir..."
New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null

$Skills = @(
    "ga4-report",
    "gsc-report",
    "seo-and-blog",
    "seo-audit",
    "seo-competitor-pages",
    "seo-content",
    "seo-geo",
    "seo-hreflang",
    "seo-images",
    "seo-page",
    "seo-plan",
    "seo-programmatic",
    "seo-schema",
    "seo-sitemap",
    "seo-technical",
    "site-automate",
    "webflow-seo-orchestrator"
)

foreach ($skill in $Skills) {
    $src = Join-Path $ScriptDir $skill
    $dst = Join-Path $SkillsDir $skill
    if (Test-Path $src) {
        if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
        Copy-Item -Recurse $src $dst
        Write-Host "  OK $skill"
    } else {
        Write-Host "  SKIP $skill (not found in repo)"
    }
}

# Remove legacy seo/ skill if present
$legacySeo = Join-Path $SkillsDir "seo"
if (Test-Path $legacySeo) {
    Remove-Item -Recurse -Force $legacySeo
    Write-Host "  OK Removed legacy seo/ skill"
}

Write-Host ""

# --- Agents ---
Write-Host "Installing subagents to $AgentsDir..."
New-Item -ItemType Directory -Force -Path $AgentsDir | Out-Null

$Agents = @(
    "seo-content.md",
    "seo-performance.md",
    "seo-schema.md",
    "seo-sitemap.md",
    "seo-technical.md",
    "seo-visual.md"
)

foreach ($agent in $Agents) {
    $src = Join-Path $ScriptDir "agents\$agent"
    $dst = Join-Path $AgentsDir $agent
    if (Test-Path $src) {
        Copy-Item $src $dst
        Write-Host "  OK $agent"
    } else {
        Write-Host "  SKIP $agent (not found in repo)"
    }
}

Write-Host ""
Write-Host "Done. Restart Claude Code to activate all skills."
Write-Host ""
Write-Host "Prerequisites (configure before use):"
Write-Host "  ga4-report / gsc-report  -- Google service account JSON in workspace root"
Write-Host "  site-automate / webflow-seo-orchestrator -- Webflow MCP server + API token"
Write-Host "  (See README.md for full setup details)"
