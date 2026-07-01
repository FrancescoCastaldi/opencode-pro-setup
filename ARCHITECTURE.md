# 🏗️ Architettura — OpenCode PRO Setup

## Panoramica

Questo repository contiene **setup automatizzati** per configurare un ambiente OpenCode AI pronto all'uso. L'obiettivo è: **scansiona → pulisci → installa → configura → verifica** in un unico comando cross-platform.

---

## Stack Tecnologico

| Componente | Tecnologia |
|------------|------------|
| Windows Installer | PowerShell 5.1+ |
| macOS/Linux Installer | Bash 4+ / Zsh |
| Config format | JSON + JSONC |
| Agents | Markdown frontmatter |
| Package manager | npm (globale) |
| Custom plugins | JavaScript (ES modules) |

---

## Struttura Directory

```
opencode-pro-setup/
├── setup.ps1                  # [Windows] Installer PowerShell
├── setup.sh                   # [macOS/Linux] Installer Bash
├── README.md                  # Documentazione principale
├── ARCHITECTURE.md            # Questo file
├── config/
│   ├── opencode.json          # Config principale OpenCode
│   ├── oh-my-opencode-slim.json # Skill collection plugin presets
│   ├── opencode-mem.jsonc     # Memoria persistente
│   ├── dcp.jsonc              # Dynamic Context Pruning
│   ├── tui.json               # TUI plugin config
│   ├── package.json           # Dipendenze npm dei plugin
│   ├── .env.example           # Template chiavi API
│   ├── .gitignore
│   ├── agent/
│   │   └── orchestrator.md    # Agente orchestratore multi-agente
│   ├── plugins/               # Plugin custom JavaScript
│   │   ├── context-pruning.js # Compressione contesto sessioni
│   │   ├── env-protection.js  # Protezione file .env
│   │   └── notification.js    # Notifiche cross-platform
│   ├── snippet/
│   │   └── config.jsonc       # Config snippet plugin
│   ├── memory/
│   │   ├── human.md           # Memoria utente
│   │   └── persona.md         # Memoria persona
│   └── skills/                # Skill OpenCode
│       ├── deepwork/          # Workflow sessioni complesse
│       ├── simplify/          # Semplificazione codice
│       ├── codemap/           # Mappatura codebase
│       ├── clonedeps/         # Clone dipendenze locali
│       ├── reflect/           # Analisi pattern ricorrenti
│       └── worktrees/         # Git worktree management
└── docs/
    ├── API_KEYS.md            # Guida alle chiavi API
    └── CUSTOMIZATION.md       # Personalizzazione avanzata
```

---

## Core Components

### 1. Installer Scripts

| File | OS | Linguaggio |
|------|----|------------|
| `setup.ps1` | Windows | PowerShell |
| `setup.sh` | macOS/Linux | Bash |

**Pipeline comune:**

```
┌─────────────┐    ┌──────────┐    ┌───────────┐    ┌──────────┐    ┌──────────┐
│ STEP 0      │ → │ STEP 1   │ → │ STEP 2    │ → │ STEP 4   │ → │ STEP 6   │
│ Prerequisiti│   │ Scan &   │   │ Installa  │   │ Deploy   │   │ Verifica  │
│ (node,git)  │   │ Clean    │   │ OpenCode  │   │ Config   │   │ & Report  │
└─────────────┘   └──────────┘   └───────────┘   └──────────┘   └──────────┘
```

### 2. Config Layer (`config/`)

- **`opencode.json`** — Cuore del sistema: 3 MCP server, 6 plugin, agenti, permessi.
- **Plugin configs** — `opencode-mem.jsonc` (memoria), `dcp.jsonc` (context pruning), `tui.json` (TUI plugin), `oh-my-opencode-slim.json` (skill collection).
- **Custom plugins** — `plugins/` contiene plugin JavaScript per compressione contesto, protezione `.env`, e notifiche cross-platform.
- **Agent definitions** — `agent/orchestrator.md` con frontmatter YAML per descrizione, modello, permessi.

### 3. MCP Servers (3)

| Server | Tipo | Scopo |
|--------|------|-------|
| `context7` | Remote | Documentazione live librerie |
| `gh_grep` | Remote | Ricerca codice su GitHub |
| `playwright` | Local | Automazione browser & testing |

### 4. Plugin Ufficiali (6)

| Plugin | Scopo |
|--------|-------|
| `opencode-snippets` | Gestione snippet |
| `opencode-supermemory` | Memoria persistente con ricerca vettoriale |
| `opencode-background-agents` | Esecuzione agenti in background |
| `opencode-worktree` | Gestione Git worktree |
| `opencode-notify` | Notifiche desktop |
| `oh-my-opencode-slim` | Skill collection + agent presets |

### 5. Plugin Custom (3)

| Plugin | Scopo | Cross-Platform |
|--------|-------|----------------|
| `context-pruning.js` | Comprime contesto sessioni | ✅ |
| `env-protection.js` | Blocca lettura `.env` | ✅ |
| `notification.js` | Notifiche desktop native | ✅ macOS/Win/Linux |

### 6. Skills (6)

| Skill | Descrizione |
|-------|-------------|
| `deepwork` | Workflow orchestrator per sessioni complesse |
| `simplify` | Semplificazione codice senza cambiar comportamento |
| `codemap` | Generazione mappe codebase |
| `clonedeps` | Clone dipendenze per ispezione |
| `reflect` | Analisi pattern ricorrenti |
| `worktrees` | Git worktree come lane isolate |

---

## Data Flow — Esecuzione Setup

```
User avvia setup
      │
      ▼
┌─────────────────┐
│ Check           │ ← node, npm, git
│ Prerequisites   │
└────────┬────────┘
         │ OK
         ▼
┌─────────────────┐
│ Detect Existing │ ← npm global, winget, brew, dirs, PATH
│ OpenCode        │
└────────┬────────┘
         │ Found? → Backup config → Kill processes → Uninstall
         ▼
┌─────────────────┐
│ npm install -g  │
│ opencode-ai     │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│ Deploy Config + Plugin + Skills + Snippet   │
│ + Memory + MCP + API Keys                   │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│ npm install     │ ← Plugin dipendenze
│ in config dir   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Verify & Report │ ← CLI version, config, agenti, plugins, skills
└─────────────────┘
```

---

## Configurazione e Build

### Dipendenze
- Node.js 18+ (richiesto da OpenCode)
- npm 9+ (package manager)
- Git 2+ (per clone e operazioni repo)
- PowerShell 5.1+ (Windows) o Bash 4+ (macOS/Linux)

### Build / Deploy
Nessun build step necessario. Il setup è "copia e incolla":
1. Clona il repo o scarica gli script
2. Esegui `setup.ps1` (Windows) o `setup.sh` (macOS/Linux)
3. Segui le istruzioni interattive per le API key

### Output
- `~/.config/opencode/` — Configurazione completa
- `~/.opencode/` — Dati e plugin
- `~/.opencode-mem/` — Memoria persistente (opzionale)

---

## Sicurezza

- **Nessuna API key hardcoded** nei file — vengono chieste interattivamente o lette da `.env`
- **Backup automatico** della config esistente prima di pulire
- **Permessi granulari** in `opencode.json` per bash, filesystem, external directory
- **Plugin env-protection.js** — Blocca la lettura di `.env` da parte dell'AI
- **`.gitignore`** — Ignora node_modules, .env, file di backup
