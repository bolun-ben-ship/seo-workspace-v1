# Client Registry

| Client | Platform | Workspace | Store / Site | Token Env Var | Status |
|---|---|---|---|---|---|
| Owllight Sleep | Shopline | `~/Antigravity/RightClickAI-seo-workspace/clients/owllight` | owllight-sleep | SHOPLINE_OWLLIGHT_TOKEN | Active |
| AEXPHL | Webflow | `clients/aexphl` | aexphl | WEBFLOW_AEXPHL_TOKEN | Active |

## How to Add a New Client
1. Copy `client-template/` → `~/Antigravity/{client}-claude-workspace/`
2. Fill in CLAUDE.md placeholders
3. Add token to `~/.zshrc`
4. Add a row to this table

## Token Env Var Naming Convention
`{PLATFORM}_{CLIENT_SLUG}_TOKEN`

Examples:
- `SHOPLINE_OWLLIGHT_TOKEN`
- `WEBFLOW_AEXPHL_TOKEN`
- `SHOPLINE_CLIENTB_TOKEN`
- `WORDPRESS_CLIENTC_TOKEN`
