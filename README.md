# OpenCode PRO Setup

<div align="center">

**Professional, batteries-included configuration for the OpenCode AI editor.**

Plugins, skills, MCP servers, multi-agent orchestration and LSP support.

[![Windows](https://img.shields.io/badge/Windows-Supported-blue)](install.ps1)
[![OpenCode](https://img.shields.io/badge/OpenCode-1.17%2B-orange)](https://opencode.ai)

</div>

---

## Quick start

1. **Clone or download this repository.**
2. **Open PowerShell as Administrator** in the folder.
3. Run the installer:

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

Or simply **double-click `install.bat`**. It will request administrator rights automatically and run `install.ps1` for you.

> **No backup is created.** The installer deletes the existing OpenCode config/data directories and installs a fresh PRO setup.

---

## What the installer does

| Step | Action |
|------|--------|
| **0. Prerequisites** | Verifies Node.js and npm. If Node.js is missing, it can install it via `winget`. |
| **1. Clean** | Deletes existing `~/.config/opencode`, `~/.opencode`, `~/.opencode-mem` and uninstalls `opencode-ai` globally. |
| **2. Install OpenCode** | `npm install -g --no-fund --no-audit opencode-ai@latest` |
| **3. Deploy config** | Copies `config/` from this repo to `~/.config/opencode`. |
| **4. Plugin dependencies** | Runs `npm install --no-fund --no-audit` inside the config directory. |
| **5. MCP servers** | Installs MCP servers globally (filesystem, playwright, github, puppeteer, excel, opencode, fetch, sequential-thinking, memory). |
| **6. LSP servers** | Installs TypeScript/HTML/CSS/JSON/Markdown/YAML language servers globally. |
| **7. API keys** | Prompts for **OpenCode Zen**, **OpenCode Go** and **GitHub** API keys. |
| **8. Providers** | Adds `opencode` and `opencode-go` providers if not already present. |
| **9. Verify** | Checks `opencode --version`, config, plugins, skills and dependencies. |

---

## API keys

The installer will ask for the following keys:

| Key | Why it is needed | Where to get it |
|-----|------------------|-----------------|
| **OpenCode Zen API key** | Authenticates the `opencode` provider. | Your OpenCode account dashboard. |
| **OpenCode Go API key** | Authenticates the `opencode-go` provider. | Your OpenCode Go account dashboard. |
| **GitHub Personal Access Token** | Powers the GitHub MCP server and code search. | https://github.com/settings/tokens - create a classic token with `repo` and `read:user` scopes. |

Keys are stored in:

- `~/.config/opencode/.env` (for OpenCode CLI/environment)
- `~/.config/opencode/.github-token` (for the GitHub MCP server)
- Your user-level environment variables (`OPENCODE_API_KEY`, `OPENCODE_GO_API_KEY`, `GITHUB_TOKEN`)

You can re-run the installer at any time to rotate the keys.

---

## Installer parameters

| Parameter | Description |
|-----------|-------------|
| `-DryRun` | Simulate the installation without deleting, installing or writing anything. |
| `-Force` | Skip the confirmation prompts before cleaning and installing. |
| `-SkipClean` | Do not delete existing OpenCode directories. |
| `-Offline` | Use only the local `config/` folder, do not download from GitHub. |

### Examples

```powershell
# See what the installer would do
powershell -ExecutionPolicy Bypass -File install.ps1 -DryRun

# Fully unattended (except API-key prompts)
powershell -ExecutionPolicy Bypass -File install.ps1 -Force

# Re-deploy only the configuration without deleting anything
powershell -ExecutionPolicy Bypass -File install.ps1 -SkipClean
```

---

## What's included

### Agents

13 agents including orchestrator, general, explore, brainstormer, build, reviewer, debugger, optimizer, tester, docker, database, refactor and scriptwriter.

### Plugins

- **Official:** `opencode-mem`, `opencode-snippets`, `opencode-supermemory`, `opencode-background-agents`, `opencode-worktree`, `opencode-notify`, `oh-my-opencode-slim`
- **Custom:** `context-pruning`, `env-protection`, `notification`

### Skills

`deepwork`, `simplify`, `codemap`, `clonedeps`, `reflect`, `worktrees`, `release-smoke-test`, `repo-scaffold`, `verification-planning` plus `oh-my-opencode-slim` skill updates.

### MCP servers

| Server | Package | Status |
|--------|---------|--------|
| filesystem | `@modelcontextprotocol/server-filesystem` | enabled |
| playwright | `@playwright/mcp` | enabled |
| github | `@modelcontextprotocol/server-github` | enabled |
| puppeteer | `@modelcontextprotocol/server-puppeteer` | enabled |
| excel | `@negokaz/excel-mcp-server` | enabled |
| opencode | `opencode-mcp` | enabled |
| fetch | `html-extractor-mcp` | enabled |
| sequential-thinking | `@modelcontextprotocol/server-sequential-thinking` | enabled |
| memory | `@modelcontextprotocol/server-memory` | enabled |
| context7 | remote | enabled |
| gh_grep | remote | enabled |
| sqlite, postgres, redis, brave-search, mcp-ops | - | disabled |

### LSP servers

TypeScript, JavaScript, HTML, CSS, JSON, Markdown, YAML.

---

## Customization

Edit `~/.config/opencode/opencode.jsonc` to change models, plugins, MCP servers, permissions or LSP servers. OpenCode reads the configuration automatically on the next start.

---

## Repository structure

```
opencode-pro-setup/
├── install.ps1          # Single PowerShell installer
├── install.bat          # Double-click wrapper for install.ps1
├── README.md            # This file
├── ARCHITECTURE.md      # Architecture notes
├── docs/                # Additional documentation
└── config/              # OpenCode PRO configuration
    ├── opencode.jsonc   # Main config
    ├── opencode-mem.jsonc
    ├── oh-my-opencode-slim.json
    ├── dcp.jsonc
    ├── tui.json
    ├── .env.example     # Template for API keys
    ├── .gitignore
    ├── package.json     # Plugin dependencies
    ├── agents/
    ├── commands/
    ├── memory/
    ├── plugins/
    ├── skills/
    └── snippet/
```

---

## Troubleshooting

```powershell
# Re-run the installer
powershell -ExecutionPolicy Bypass -File install.ps1

# Check what the installer would do
powershell -ExecutionPolicy Bypass -File install.ps1 -DryRun

# Reinstall the OpenCode CLI only
npm uninstall -g opencode-ai
npm install -g opencode-ai

# Reinstall global MCP servers
npm install -g @modelcontextprotocol/server-filesystem @playwright/mcp @modelcontextprotocol/server-github @modelcontextprotocol/server-puppeteer @negokaz/excel-mcp-server opencode-mcp html-extractor-mcp @modelcontextprotocol/server-sequential-thinking @modelcontextprotocol/server-memory

# Reinstall global LSP servers
npm install -g typescript-language-server vscode-langservers-extracted yaml-language-server
```

---

## License

MIT - see the repository for details.
