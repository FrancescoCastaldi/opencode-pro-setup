# OpenCode PRO Setup

<div align="center">

**Configurazione professionale completa per OpenCode AI editor**
Plugin, skill, MCP server, agenti multi-orchestrazione e LSP.

[![Windows](https://img.shields.io/badge/Windows-Supported-blue)](setup.ps1)
[![macOS](https://img.shields.io/badge/macOS-Supported-blue)](setup.sh)
[![Linux](https://img.shields.io/badge/Linux-Supported-blue)](setup.sh)
[![OpenCode](https://img.shields.io/badge/OpenCode-1.17%2B-orange)](https://opencode.ai)

</div>

---

## Indice

- [Installazione Windows (procedura esatta)](#installazione-windows-procedura-esatta)
- [Installazione macOS / Linux (procedura esatta)](#installazione-macos--linux-procedura-esatta)
- [Cosa fa l'installer, passo per passo](#cosa-fa-linstaller-passo-per-passo)
- [API keys: cosa serve e dove trovarle](#api-keys-cosa-serve-e-dove-trovarle)
- [Dopo l'installazione: primo avvio](#dopo-linstallazione-primo-avvio)
- [Parametri dell'installer](#parametri-dellinstaller)
- [Cosa include](#cosa-include)
- [Personalizzazione](#personalizzazione)

---

## Installazione Windows (procedura esatta)

### Prerequisiti

- Windows 10+ con PowerShell 5.0+
- L'installer **può installare automaticamente** Node.js e Git se mancanti

### Procedura

#### 1. Apri PowerShell come Amministratore

Premi `Win+X`, seleziona **"Windows PowerShell (Admin)"** oppure **"Terminale (Admin)"**.

#### 2. Esegui questo comando (copia e incolla tutto)

```powershell
powershell -Command "iwr -Uri 'https://raw.githubusercontent.com/FrancescoCastaldi/opencode-pro-setup/main/setup.ps1' -OutFile \"$env:TEMP\setup.ps1\"; powershell -ExecutionPolicy Bypass -File \"$env:TEMP\setup.ps1\""
```

> **Nota:** Windows potrebbe chiedere conferma per eseguire script non firmati. Rispondi **Sì** o **Esegui comunque**.

#### 3. Segui le richieste interattive

L'installer ti chiederà:

| Prompt | Cosa rispondere |
|--------|----------------|
| "Install Node.js LTS via winget?" | `Y` (se non hai Node.js) |
| "Install Git via winget?" | `Y` (se non hai Git) |
| "Clean all existing installations?" | `Y` (consigliato per installazione pulita) |
| "Enter GitHub Personal Access Token" | Inserisci il tuo token (vedi [API keys](#api-keys-cosa-serve-e-dove-trovarle)) oppure Invio per saltare |
| "Enter OpenCode username" | Invio per usare il nome utente Windows, oppure digita un nome personalizzato |

#### 4. Verifica il risultato finale

Se tutto è ok, vedrai:

```
========================================
 OpenCode PRO - Installation Complete!
========================================
    OpenCode CLI: v1.xx.x
    Config: opencode.jsonc
    Agent: orchestrator
    Custom plugins: 3
    Skills: 6
    Plugin deps: installed
    ...
    Run: opencode
```

#### 5 (opzionale) — Installa manualmente se la via diretta non funziona

```powershell
git clone https://github.com/FrancescoCastaldi/opencode-pro-setup.git
cd opencode-pro-setup
powershell -ExecutionPolicy Bypass -File setup.ps1
```

---

## Installazione macOS / Linux (procedura esatta)

### Prerequisiti

- Node.js 18+ e npm
- Git
- Bash o Zsh

### Procedura

```bash
# 1. Clona il repository
git clone https://github.com/FrancescoCastaldi/opencode-pro-setup.git
cd opencode-pro-setup

# 2. Rendi eseguibile lo script
chmod +x setup.sh

# 3. Esegui l'installer
./setup.sh
```

Lo script bash segue la stessa pipeline dello script Windows.

---

## Cosa fa l'installer, passo per passo

### Pipeline completa

```
Prerequisiti → Scansione & Backup → Pulizia → Installa OpenCode → 
Crea directory → Deploy config → Plugin deps → MCP & LSP → 
API Keys → Provider → Verifica
```

### Dettaglio step

| Step | Cosa fa | Richiede input? |
|------|---------|----------------|
| **0. Prerequisiti** | Verifica Node.js 18+, npm, Git. Li installa via winget se assenti | Solo se mancano e vuoi installarli |
| **1. Scansione & Backup** | Cerca installazioni OpenCode esistenti, le backup in `~/opencode-backup-*` | Chiede conferma prima di pulire |
| **2. Installa OpenCode** | `npm install -g opencode-ai@latest` | No |
| **3. Crea directory** | Crea `~/.config/opencode/` con sottocartelle `agents/`, `plugins/`, `skills/`, `snippet/`, `memory/` | No |
| **4. Deploy config** | Copia `opencode.jsonc`, agenti, plugin custom, memory, skills, snippet dal repo o da GitHub | No |
| **5. Plugin dependencies** | `npm install` nella cartella config (plugin: opencode-snippets, supermemory, background-agents, worktree, notify, oh-my-opencode-slim) | No |
| **5b. MCP & LSP** | Installa globalmente MCP server (playwright, github, excel, sequential-thinking, memory, fetch) e LSP (TypeScript, HTML, CSS, JSON, Markdown, YAML) | No |
| **5c. API Keys** | Configura GitHub Token e username | **Sì** — chiede GitHub Token |
| **5d. Providers** | Configura provider `opencode` e `opencode-go` | No |
| **6. Verifica** | Controlla CLI, config, agenti, plugin, skills, node_modules | No |

---

## API keys: cosa serve e dove trovarle

### Obbligatorie

Nessuna — puoi saltare tutto e iniziare subito con `opencode`.

### Consigliate

| Chiave | Dove trovarla | Cosa abilita |
|--------|--------------|--------------|
| **GitHub Token** | https://github.com/settings/tokens → `Generate new token (classic)` → spunta `repo` e `user` | Ricerca codice GitHub (gh_grep) |
| **GitHub Username** | Il tuo username GitHub | Identificazione nei commit |

### Opzionali (configurabili dopo)

| Chiave | Dove configurarla | Cosa abilita |
|--------|------------------|--------------|
| **Anthropic API Key** | `opencode providers add anthropic` | Modelli Claude |
| **OpenRouter API Key** | `opencode providers add openrouter` | Molteplici modelli |
| **Google AI Key** | `opencode providers add google` | Modelli Gemini |
| **OpenAI Key** | `opencode providers add openai` | Modelli GPT |

---

## Dopo l'installazione: primo avvio

### 1. Avvia OpenCode

```bash
opencode
```

Al primo avvio OpenCode crea il database interno e inizializza i plugin.

### 2. In un progetto esistente

Naviga nella cartella del progetto e apri OpenCode:

```bash
cd C:\Progetti\mio-progetto
opencode
```

Oppure usa `/init` dentro OpenCode per analizzare il progetto.

### 3. Verifica i plugin attivi

Dentro OpenCode, controlla che i plugin siano caricati:

```
/plugin list
```

Dovresti vedere: opencode-snippets, supermemory, background-agents, worktree, notify, oh-my-opencode-slim, context-pruning, env-protection, notification.

### 4. Configura provider aggiuntivi (opzionale)

```bash
opencode providers add anthropic
opencode providers add openrouter
# Segui le istruzioni interattive per inserire le API key
```

### 5. Se qualcosa non funziona

```bash
# Riavvio pulito
opencode
# Se persiste, reinstalla
npm uninstall -g opencode-ai && npm install -g opencode-ai
```

---

## Parametri dell'installer

| Parametro | Descrizione |
|-----------|-------------|
| `-Force` | Esecuzione automatica (non chiede conferme) |
| `-SkipClean` | Salta backup e pulizia installazioni esistenti |
| `-Offline` | Usa solo file locali (non scarica da GitHub) |
| `-RepoUrl` | URL del repository (default: GitHub) |

### Esempi

```powershell
# Installazione automatica (senza interruzioni)
powershell -ExecutionPolicy Bypass -File setup.ps1 -Force

# Solo deploy configurazione (senza pulire)
powershell -ExecutionPolicy Bypass -File setup.ps1 -SkipClean

# Installazione offline
powershell -ExecutionPolicy Bypass -File setup.ps1 -Offline
```

---

## Cosa include

### Agenti (13)

| Agente | Ruolo |
|--------|-------|
| **orchestrator** | Coordinatore multi-agente — pianifica, delega, verifica |
| **general** | Assistente generico per coding |
| **explorer** | Ricerca rapida nel codebase |
| **brainstormer** | Ideazione e progettazione |
| **build** | Implementazione esecutiva |
| **reviewer** | Code review qualità e sicurezza |
| **debugger** | Debug sistematico |
| **optimizer** | Ottimizzazione performance |
| **tester** | Test automation |
| **docker** | DevOps e container |
| **database** | SQL e query optimization |
| **refactor** | Refactoring strutturale |
| **scriptwriter** | Automazione scripting |

### Plugin

- **Ufficiali:** opencode-snippets, supermemory, background-agents, worktree, notify, oh-my-opencode-slim, opencode-mem
- **Custom:** context-pruning (comprime contesto), env-protection (protegge .env), notification (notifiche cross-platform)

### Skill

deepwork, simplify, codemap, clonedeps, reflect, worktrees

### MCP Server

| Server | Descrizione |
|--------|-------------|
| `@playwright/mcp` | Automazione browser |
| `@modelcontextprotocol/server-github` | API GitHub |
| `@negokaz/excel-mcp-server` | Operazioni Excel |
| `opencode-mcp` | Comandi OpenCode |
| `mcp-fetch-server` | Fetch URL |
| `@modelcontextprotocol/server-sequential-thinking` | Ragionamento strutturato |
| `@modelcontextprotocol/server-memory` | Memoria persistente |
| `context7` / `gh_grep` (plugin) | Documentazione e ricerca codice |

### LSP Server

TypeScript, JavaScript, HTML, CSS, JSON, Markdown, YAML

---

## Personalizzazione

Modifica `config/opencode.jsonc` per:

- **Cambiare modello AI predefinito** — modifica `"model"` nella sezione del provider
- **Aggiungere/rimuovere plugin** — aggiorna `"plugins"` nella sezione `"pluginDependencies"`
- **Aggiungere/rimuovere MCP server** — modifica la sezione `"mcpServers"`
- **Configurare permessi** — modifica la sezione `"permissions"`
- **Aggiungere LSP server** — modifica la sezione `"lsp"`

Dopo aver modificato il config, esegui:

```bash
opencode
```

OpenCode rilegge automaticamente il config all'avvio.

---

## Struttura del Repository

```
opencode-pro-setup/
├── setup.ps1               # [Windows] Installer PowerShell (self-contained)
├── setup.sh                # [macOS/Linux] Installer Bash
├── README.md               # Questa guida
├── ARCHITECTURE.md         # Architettura del setup
├── config/
│   ├── opencode.jsonc      # Config principale OpenCode (versione PRO)
│   ├── oh-my-opencode-slim.json  # OMO preset con agenti
│   ├── opencode-mem.jsonc  # Memoria plugin config
│   ├── dcp.jsonc           # Dynamic Context Pruning
│   ├── tui.json            # TUI plugin config
│   ├── .env.example        # Template API keys
│   ├── .gitignore
│   ├── agents/             # Agenti AI (orchestrator, ecc.)
│   ├── plugins/            # Plugin custom (context-pruning, env-protection, notification)
│   ├── snippet/            # Config snippet
│   ├── memory/             # Memoria persistente (human.md, persona.md)
│   └── skills/             # Skill (deepwork, simplify, codemap, clonedeps, reflect, worktrees)
└── docs/
    ├── API_KEYS.md
    └── CUSTOMIZATION.md
```
