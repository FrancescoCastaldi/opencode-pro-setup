# OpenCode PRO Setup

<div align="center">

**Configurazione completa e cross-platform per OpenCode AI editor**
con plugin, skill, MCP server e agenti multi-orchestrazione.

[![Windows](https://img.shields.io/badge/Windows-Supported-blue)](setup.ps1)
[![macOS](https://img.shields.io/badge/macOS-Supported-blue)](setup.sh)
[![Linux](https://img.shields.io/badge/Linux-Supported-blue)](setup.sh)
[![OpenCode](https://img.shields.io/badge/OpenCode-1.17%2B-orange)](https://opencode.ai)

</div>

## Cosa Include

| Feature | Count |
|---------|-------|
| 🤖 **Agenti AI** | Orchestrator + sub-agents (oracle, librarian, fixer, designer, explorer) |
| 🔌 **Plugin** | 6 ufficiali + 3 custom |
| 🔧 **MCP Server** | 3 (context7, gh_grep, playwright) |
| 📚 **Skill** | 6 (deepwork, simplify, codemap, clonedeps, reflect, worktrees) |
| 🛡️ **Plugin Custom** | context-pruning, env-protection, notification cross-platform |
| 💾 **Memoria** | Supermemory + persistente |

### Plugin Stack
- **opencode-snippets** — Snippet gestiti
- **opencode-supermemory** — Memoria persistente con vettori
- **opencode-background-agents** — Agenti in background
- **opencode-worktree** — Git worktree management
- **opencode-notify** — Notifiche desktop cross-platform
- **oh-my-opencode-slim** — Skill collection + agent presets

### Plugin Custom
- **context-pruning.js** — Comprime automaticamente il contesto nelle sessioni lunghe
- **env-protection.js** — Blocca la lettura di file `.env` da parte dell'AI
- **notification.js** — Notifiche desktop cross-platform (macOS/Windows/Linux)

### MCP Stack
- **context7** — Documentazione live delle librerie
- **gh_grep** — Ricerca codice su GitHub
- **playwright** — Automazione browser e testing

## 🚀 Installazione Rapida

### Windows (PowerShell 5+)

```powershell
git clone https://github.com/FrancescoCastaldi/opencode-pro-setup.git
cd opencode-pro-setup
powershell -ExecutionPolicy Bypass -File setup.ps1
```

### macOS / Linux

```bash
git clone https://github.com/FrancescoCastaldi/opencode-pro-setup.git
cd opencode-pro-setup
chmod +x setup.sh
./setup.sh
```

## Cosa Fa l'Installer

1. **Prerequisiti** — Node.js, npm, Git
2. **Scansione & pulizia** — Rileva installazioni esistenti, esegue backup
3. **Installa OpenCode** — via npm globale
4. **Struttura directory** — Crea le cartelle di configurazione
5. **Deploy configurazione** — Copia tutti i file, installa plugin, skill, MCP
6. **Verifica** — Controlla che tutto funzioni

## Struttura del Repository

```
opencode-pro-setup/
├── setup.ps1               # Installer Windows (PowerShell)
├── setup.sh                # Installer macOS/Linux (Bash)
├── README.md               # Documentazione
├── ARCHITECTURE.md         # Architettura del setup
├── config/
│   ├── opencode.json       # Config principale OpenCode
│   ├── oh-my-opencode-slim.json  # OMO preset
│   ├── opencode-mem.jsonc  # Memoria plugin config
│   ├── dcp.jsonc           # Dynamic Context Pruning
│   ├── tui.json            # TUI config
│   ├── package.json        # Dipendenze plugin
│   ├── .env.example        # Template API keys
│   ├── .gitignore
│   ├── agent/
│   │   └── orchestrator.md # Agente orchestratore
│   ├── plugins/
│   │   ├── context-pruning.js   # Compressione contesto
│   │   ├── env-protection.js    # Protezione .env
│   │   └── notification.js      # Notifiche cross-platform
│   ├── snippet/
│   │   └── config.jsonc   # Config snippet
│   ├── memory/
│   │   ├── human.md
│   │   └── persona.md
│   └── skills/
│       ├── deepwork/       # Workflow sessioni complesse
│       ├── simplify/       # Semplificazione codice
│       ├── codemap/        # Mappatura codebase
│       ├── clonedeps/      # Clone dipendenze
│       ├── reflect/        # Analisi pattern ricorrenti
│       └── worktrees/      # Git worktree management
└── docs/
    ├── API_KEYS.md
    └── CUSTOMIZATION.md
```

## Personalizzazione

Modifica `config/opencode.json` per:
- Cambiare modello AI
- Aggiungere/rimuovere plugin
- Aggiungere/rimuovere MCP server
- Modificare permessi

## Note Cross-Platform

- **Plugin notification.js** rileva automaticamente il sistema operativo:
  - macOS: `osascript` per notifiche native
  - Windows: PowerShell toast notifications con fallback console
  - Linux: `notify-send` con fallback console

- **Percorsi**: Tutti i path usano separatori `/` (validi su Windows con Node.js)
- **Terminale**: Compatibile con PowerShell, CMD, bash, zsh
