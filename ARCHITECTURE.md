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
| CI (futuro) | GitHub Actions |

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
│   ├── .env.example           # Template chiavi API
│   ├── .gitignore             # Ignora node_modules, .env, backups
│   ├── dcp.jsonc              # Dynamic Context Pruning
│   ├── oh-my-opencode-slim.json # Skill collection plugin
│   ├── opencode-mem.jsonc     # Memoria persistente
│   ├── agent/
│   │   └── orchestrator.md    # Agente orchestratore multi-agente
│   └── skills/                # Skill personalizzate (future)
├── docs/
│   ├── API_KEYS.md            # Guida alle chiavi API
│   └── CUSTOMIZATION.md       # Personalizzazione avanzata
```

---

## Core Components

### 1. Installer Scripts

| File | OS | Linguaggio | Lines |
|------|----|------------|-------|
| `setup.ps1` | Windows | PowerShell | 452 |
| `setup.sh` | macOS/Linux | Bash | 288 |

**Pipeline comune a entrambi:**

```
┌─────────────┐    ┌──────────┐    ┌───────────┐    ┌──────────┐    ┌──────────┐
│ STEP 0      │ → │ STEP 1   │ → │ STEP 2    │ → │ STEP 3   │ → │ STEP 4   │
│ Prerequisiti│   │ Scan &   │   │ Installa  │   │ Deploy    │   │ Verifica  │
│ (node,git)  │   │ Clean    │   │ OpenCode  │   │ Config    │   │ & Report  │
└─────────────┘   └──────────┘   └───────────┘   └──────────┘   └──────────┘
```

### 2. Config Layer (`config/`)

- **`opencode.json`** — Cuore del sistema. 9 MCP server, 17 plugin, 2 agenti, permessi, comandi custom.
- **Plugin configs** — `opencode-mem.jsonc` (memoria), `dcp.jsonc` (context pruning), `oh-my-opencode-slim.json` (skill collection).
- **Agent definitions** — `agent/orchestrator.md` con frontmatter YAML per descrizione, modello, permessi.

### 3. MCP Servers (9)

| Server | Scopo |
|--------|-------|
| `context7` | Documentazione live librerie |
| `playwright` | Automazione browser & testing |
| `fetch` | Web fetching |
| `sequential-thinking` | Ragionamento strutturato |
| `filesystem` | Accesso file sicuro |
| `mermaid` | Diagrammi e grafici |
| `excalidraw` | Whiteboard e schizzi |
| `memory` | Contesto persistente |
| `github` | PR, issues, code search |

### 4. Plugins (17)

Plugin inclusi: `opencode-mem`, `opencode-notify`, `opencode-worktree`, `opencode-goal`, `dcp`, `oh-my-opencode-slim`, `opencode-brainstorm`, `opencode-orchestrate`, e altri per automazione, qualità codice, orchestrazione.

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
┌─────────────────┐
│ Deploy Config   │ ← Copia file, sostituisce placeholder,
│ + API Keys      │   chiede GITHUB_TOKEN, GIT_USERNAME
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ npm install     │ ← Plugin dipendenze
│ in config dir   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Verify & Report │ ← CLI version, config presente, agenti, plugins
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
- **`.gitignore`** — Ignora node_modules, .env, file di backup
- Il README originale puntava a un link pubblico `raw.githubusercontent.com` — aggiornato per repo privato
