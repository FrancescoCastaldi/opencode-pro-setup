# OpenCode PRO Setup 🚀

<div align="center">

**Automated setup for a fully-configured OpenCode AI coding agent**
with 17 plugins, 9 MCP servers, and multi-agent orchestration.

[![Windows](https://img.shields.io/badge/Windows-Supported-blue)](setup.ps1)
[![macOS](https://img.shields.io/badge/macOS-Supported-blue)](setup.sh)
[![Linux](https://img.shields.io/badge/Linux-Supported-blue)](setup.sh)
[![OpenCode](https://img.shields.io/badge/OpenCode-1.17%2B-orange)](https://opencode.ai)

</div>

## ✨ What You Get

| Feature                | Count |
|------------------------|-------|
| 🤖 **AI Agents**      | 2 (orchestrator + general) |
| 🔌 **Plugins**        | 17 |
| 🔧 **MCP Servers**    | 9 |
| 🛡️ **Security Rules** | Granular permissions |
| 💾 **Memory System**  | Persistent + vector search |
| 📋 **Workflows**      | Plan → Implement → Review → Merge |

### Plugin Stack
Memory, notifications, worktrees, goal tracking, context pruning, skill collections, brainstorming, orchestration, PR automation, and more.

### MCP Stack
- **context7** — Live library documentation
- **playwright** — Browser automation & testing
- **fetch** — Web fetching
- **sequential-thinking** — Structured reasoning
- **filesystem** — Safe file access
- **mermaid** — Diagrams & charts
- **excalidraw** — Whiteboard & sketches
- **memory** — Persistent context
- **github** — PRs, issues, code search

## 🚀 Quick Start

### Windows (PowerShell 5+)

```powershell
# Clone and run
git clone https://github.com/FrancescoCastaldi/opencode-pro-setup.git
cd opencode-pro-setup
powershell -ExecutionPolicy Bypass -File setup.ps1
```

> **Nota:** Il repo è privato. Scarica manualmente i file o clona con `git clone`.

### macOS / Linux

```bash
# Clone and run
git clone https://github.com/FrancescoCastaldi/opencode-pro-setup.git
cd opencode-pro-setup
chmod +x setup.sh
./setup.sh
```

> **Nota:** Il repo è privato. Scarica manualmente i file o clona con `git clone`.

## 📋 What the Installer Does

1. **🔍 Checks prerequisites** — Node.js, npm, Git
2. **🧹 Scans & cleans** existing OpenCode installations
   - Detects: npm global, winget, Homebrew, directories, processes
   - Backups config before removing
   - Kills running processes
3. **📦 Installs OpenCode** fresh via npm
4. **📁 Creates directory structure** for configs, agents, skills, data
5. **⚙️ Deploys configuration** with your API keys
6. **🔌 Installs plugin dependencies**
7. **✅ Verifies everything** works

## 🔑 API Keys You'll Need

| Key | Required | Where to Get |
|-----|----------|-------------|
| `GITHUB_TOKEN` | ✅ Yes | https://github.com/settings/tokens (scopes: repo, read:user) |
| `ANTHROPIC_API_KEY` | Optional | https://console.anthropic.com |
| `OPENAI_API_KEY` | Optional | https://platform.openai.com/api-keys |

The installer will prompt you for these interactively.

## 🎮 Usage After Install

```bash
# Start OpenCode
opencode

# Use the orchestrator agent (default)
opencode run "Your task here"

# Or use general agent
opencode run --agent general "Your task here"
```

## 🛠️ Customization

Edit `~/.config/opencode/opencode.json` to:
- Change the AI model
- Add/remove plugins
- Add/remove MCP servers
- Adjust permissions
- Add custom commands

See [CUSTOMIZATION.md](docs/CUSTOMIZATION.md) for details.

## 📂 Repository Structure

```
opencode-pro-setup/
├── setup.ps1          # Windows installer
├── setup.sh           # macOS/Linux installer
├── ARCHITECTURE.md    # Architettura del progetto
├── config/
│   ├── opencode.json           # Main configuration
│   ├── .env.example            # API keys template
│   ├── dcp.jsonc               # Dynamic Context Pruning
│   ├── oh-my-opencode-slim.json # Oh My Opencode Slim
│   ├── opencode-mem.jsonc      # Memory plugin config
│   ├── .gitignore
│   └── agent/
│       └── orchestrator.md     # Orchestrator agent definition
├── docs/
│   ├── API_KEYS.md
│   └── CUSTOMIZATION.md
└── README.md
```

## 📜 License

MIT - Use freely. Fork and customize for your team.
