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
| **Agenti AI** | 14 agenti (orchestrator, general, explore, brainstormer, build, reviewer, debugger, optimizer, tester, docker, database, refactor, scriptwriter) |
| **Plugin Ufficiali** | 6 (opencode-snippets, opencode-supermemory, opencode-background-agents, opencode-worktree, opencode-notify, oh-my-opencode-slim) |
| **Plugin Custom** | 3 (context-pruning, env-protection, notification cross-platform) |
| **MCP Server** | 3 (context7, gh_grep, playwright) + 10+ configurabili |
| **Skill** | 6 (deepwork, simplify, codemap, clonedeps, reflect, worktrees) |
| **Memoria** | Supermemory + persistente con vettori |
| **LSP** | 10 linguaggi (TypeScript, JavaScript, HTML, CSS, JSON, Markdown, LaTeX, Python, Docker, YAML) |

### Plugin Stack
- **opencode-mem** — Memoria persistente con ricerca vettoriale
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
- **Altri** — filesystem, github, puppeteer, excel, fetch, sequential-thinking, memory, sqlite, postgres, redis, e altri configurabili

---

## Installazione Rapida

### Windows (PowerShell 5+)

```powershell
# Opzione 1: Clona ed esegui
git clone https://github.com/FrancescoCastaldi/opencode-pro-setup.git
cd opencode-pro-setup
powershell -ExecutionPolicy Bypass -File setup.ps1

# Opzione 2: Download diretto (anche senza Git)
powershell -Command "iwr -Uri 'https://raw.githubusercontent.com/FrancescoCastaldi/opencode-pro-setup/main/setup.ps1' -OutFile setup.ps1; .\setup.ps1"
```

### macOS / Linux

```bash
git clone https://github.com/FrancescoCastaldi/opencode-pro-setup.git
cd opencode-pro-setup
chmod +x setup.sh
./setup.sh
```

---

## Cosa Fa l'Installer

### Pipeline Completa

```
Prerequisiti → Scansione & Backup → Pulizia → Installa OpenCode → Deploy Config → Plugin Dependencies → API Keys → Verifica
```

### Dettaglio Step

1. **Prerequisiti** — Verifica/Installa Node.js 18+, npm, Git (via winget su Windows)
2. **Scansione & Backup** — Rileva installazioni esistenti, esegue backup completo in `~/opencode-backup-*`
3. **Pulizia** — Kill processi, disinstalla npm global, rimuove directory, pulisce PATH
4. **Installa OpenCode** — via npm globale (`npm install -g opencode-ai`)
5. **Struttura directory** — Crea `~/.config/opencode/` con tutte le sottocartelle
6. **Deploy configurazione** — Copia da GitHub (o dalla cartella `config/` locale):
   - Config principale (`opencode.jsonc`)
   - Plugin ufficiali + custom
   - Skill (deepwork, simplify, codemap, clonedeps, reflect, worktrees)
   - Agenti (orchestrator, ecc.)
   - Memoria, snippet
7. **Plugin Dependencies** — `npm install` per tutti i plugin
8. **API Keys** — Richiede interattivamente GitHub Token e username
9. **Verifica** — Controlla CLI, config, agenti, plugin, skills

---

## Struttura del Repository

```
opencode-pro-setup/
├── setup.ps1               # [Windows] Installer PowerShell (self-contained)
├── setup.sh                # [macOS/Linux] Installer Bash
├── README.md               # Documentazione
├── ARCHITECTURE.md         # Architettura del setup
├── config/
│   ├── opencode.jsonc      # Config principale OpenCode (versione PRO)
│   ├── oh-my-opencode-slim.json  # OMO preset con agenti
│   ├── opencode-mem.jsonc  # Memoria plugin config
│   ├── dcp.jsonc           # Dynamic Context Pruning
│   ├── tui.json            # TUI plugin config
│   ├── .env.example        # Template API keys
│   ├── .gitignore
│   ├── agent/
│   │   └── orchestrator.md # Agente orchestratore multi-agente
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

---

## Parametri dell'Installer

| Parametro | Descrizione |
|-----------|-------------|
| `-Force` | Esecuzione automatica (senza conferme) |
| `-SkipClean` | Salta la pulizia delle installazioni esistenti |
| `-Offline` | Usa solo file locali (non scarica da GitHub) |
| `-RepoUrl` | URL del repository (default: GitHub) |

**Esempi:**
```powershell
# Installazione automatica (senza interruzioni)
powershell -ExecutionPolicy Bypass -File setup.ps1 -Force

# Solo deploy configurazione (senza pulire)
powershell -ExecutionPolicy Bypass -File setup.ps1 -SkipClean

# Installazione offline
powershell -ExecutionPolicy Bypass -File setup.ps1 -Offline
```

---

## Personalizzazione

Modifica `config/opencode.jsonc` per:
- Cambiare modello AI
- Aggiungere/rimuovere plugin
- Aggiungere/rimuovere MCP server
- Modificare permessi
- Aggiungere LSP server per nuovi linguaggi

## Note Cross-Platform

- **Plugin notification.js** rileva automaticamente il sistema operativo:
  - macOS: `osascript` per notifiche native
  - Windows: PowerShell toast notifications con fallback console
  - Linux: `notify-send` con fallback console
- **Percorsi**: Tutti i path usano separatori `/` (validi su Windows con Node.js)
- **Terminale**: Compatibile con PowerShell, CMD, bash, zsh
