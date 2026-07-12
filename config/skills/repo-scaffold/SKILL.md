# Skill: repo-scaffold

> Full GitHub repository scaffolding automation — from project context to shipped repo with labels, badges, CI/CD, and documentation.

Use ONLY when the user asks to **scaffold, bootstrap, inizializzare, creare repo, settare up, configurare repo, setup repository, setup GitHub, create repo, full repo setup, repo automation, auto repo, scaffolding completo, repo dall'inizio**, or similar phrases indicating they want a complete GitHub repository setup from scratch.

Do NOT use for: editing existing repos, deploying code, fixing bugs, or normal development work. This is a one-shot scaffolding skill.

---

## Overview

This skill takes **project context** from the user and fully automates:

1. **GitHub repo creation** — via `gh` CLI
2. **Folder structure** — opinionated scaffold based on project type
3. **Documentation files** — README.md, LICENSE, CONTRIBUTING.md, CHANGELOG.md, SECURITY.md
4. **GitHub labels** — consistent label taxonomy for issues/PRs
5. **Badges** — shields.io in README (license, version, build, coverage)
6. **CI/CD** — GitHub Actions workflows
7. **Git settings** — .gitignore, .gitattributes, editorconfig

## Execution Contract

### PHASE 1: Gather Context (MANDATORY)

ASK the user all of the following before any action:

1. **Project name** — repo name (e.g. `my-awesome-lib`)
2. **Project description** — 1-3 sentence description
3. **Project type** — pick one:
   - `npm-package` — Node.js/TypeScript library
   - `next-app` — Next.js application
   - `react-app` — React SPA
   - `api-node` — Node.js API/backend
   - `api-python` — Python API (FastAPI/Flask)
   - `api-go` — Go API
   - `cli-tool` — CLI tool (Node/Python/Go/Rust)
   - `monorepo` — multi-package workspace
   - `generic` — custom structure
4. **Visibility** — `public` or `private`
5. **License** — `MIT`, `Apache-2.0`, `GPL-3.0`, `BSD-3-Clause`, `ISC`, `Unlicense`, or `none`
6. **Package manager** (if applicable) — `npm`, `yarn`, `pnpm`, `bun`
7. **Test framework** — `vitest`, `jest`, `pytest`, `go test`, `none`
8. **GitHub user/org** — owner for the repo (default: current `gh` user)
9. **Additional context** — any specific requirements (deploy target, special CI needs, etc.)

If user says "skip" / "use defaults", use these defaults:

| Field | Default |
|-------|---------|
| Visibility | `public` |
| License | `MIT` |
| Package manager | `npm` |
| Test framework | `vitest` (JS/TS) / `pytest` (Python) |
| Project type auto-detect | From `package.json` or inferred from description |

### PHASE 2: Validate Dependencies (MANDATORY)

```bash
# Check gh CLI
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "gh CLI not found. Install from https://cli.github.com/"
    exit 1
}

# Check gh auth status
$ghAuth = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Not authenticated with GitHub. Run: gh auth login"
    exit 1
}

# Check git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "git not found."
    exit 1
}

Write-Host "All dependencies OK. Ready to scaffold."
```

If any check fails → STOP, tell user what's missing, and how to fix.

### PHASE 3: Create Repo (MANDATORY)

```bash
# Create GitHub repo
gh repo create $repoName --$visibility --description "$description" --gitignore $gitignoreTemplate

# Clone it locally
gh repo clone $repoName $localPath
Set-Location $localPath

# Or if already in working dir:
# gh repo create $repoName --$visibility --description "$description" --gitignore $gitignoreTemplate --push --source .
```

Store the repo URL and local path for subsequent phases.

### PHASE 4: Scaffold Folder Structure (MANDATORY — per project type)

#### npm-package / library
```
repo/
├── src/
│   └── index.ts
├── tests/
│   └── index.test.ts
├── dist/          (gitignored)
├── node_modules/  (gitignored)
├── package.json
├── tsconfig.json
├── .gitignore
├── .npmignore
├── .editorconfig
└── README.md
```

#### next-app
```
repo/
├── app/
│   ├── layout.tsx
│   └── page.tsx
├── components/
├── lib/
├── public/
├── styles/
├── .env.local.example
├── next.config.ts
├── tsconfig.json
├── .gitignore
├── .editorconfig
└── README.md
```

#### api-node
```
repo/
├── src/
│   ├── index.ts
│   ├── routes/
│   ├── middleware/
│   └── config/
├── tests/
├── prisma/ (optional)
├── .env.example
├── package.json
├── tsconfig.json
├── .gitignore
├── .editorconfig
└── README.md
```

#### api-python
```
repo/
├── src/
│   ├── __init__.py
│   ├── main.py
│   ├── routers/
│   └── config.py
├── tests/
│   └── __init__.py
├── .env.example
├── pyproject.toml
├── .gitignore
├── .editorconfig
└── README.md
```

#### generic (ask user for structure, or use minimal)
```
repo/
├── src/
├── tests/
├── docs/
├── scripts/
├── .gitignore
├── .editorconfig
└── README.md
```

#### monorepo
```
repo/
├── packages/
│   └── .gitkeep
├── apps/
│   └── .gitkeep
├── tools/
│   └── .gitkeep
├── package.json       (workspaces config)
├── pnpm-workspace.yaml / lerna.json / turbo.json
├── tsconfig.json
├── .gitignore
├── .editorconfig
└── README.md
```

Create all directories and files using `New-Item` or filesystem tools. For starter files, write minimal but meaningful content (don't leave them blank).

### PHASE 5: Generate Documentation (MANDATORY)

Create/overwrite these files with content derived from the project context:

#### README.md template structure:
```markdown
# Project Name

<!-- badges will go here -->

Short description.

## Features

- Feature 1
- Feature 2

## Installation

\`\`\`bash
npm install package-name
\`\`\`

## Usage

\`\`\`typescript
import { thing } from 'package-name'

// example
\`\`\`

## API

### `functionName()`

Description of what it does.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
```

#### LICENSE
Fetch from `https://raw.githubusercontent.com/licenses/license-templates/master/templates/{license}.txt` or generate inline for common ones (MIT, Apache-2.0, GPL-3.0, ISC).

#### CONTRIBUTING.md
Standard contributing guide with:
- How to report bugs
- How to suggest features
- Development setup
- PR process
- Code style
- Commit conventions (conventional commits)

#### CHANGELOG.md
```markdown
# Changelog

## [Unreleased]

- Initial project setup
```

#### .gitignore
Use `gh repo create` already sets a basic one. Enhance it for the project type.

#### .editorconfig
```ini
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
trim_trailing_whitespace = false
```

#### SECURITY.md (optional but recommended)
Standard security policy with reporting instructions.

### PHASE 6: Setup GitHub Labels (MANDATORY)

Create a consistent label taxonomy using `gh label create`. Use these categories:

**Type labels** (blue shades):
| Label | Color | Description |
|-------|-------|-------------|
| `type: bug` | `d73a4a` | Something isn't working |
| `type: feature` | `a2eeef` | New feature request |
| `type: enhancement` | `a2eeef` | Improvement to existing feature |
| `type: docs` | `0075ca` | Documentation changes |
| `type: refactor` | `ff9f1c` | Code restructuring |
| `type: test` | `fef2c0` | Test-related changes |
| `type: ci` | `bfdadc` | CI/CD changes |
| `type: chore` | `bfdadc` | Maintenance tasks |
| `type: perf` | `ff9f1c` | Performance improvements |
| `type: security` | `d73a4a` | Security fixes |
| `type: deps` | `bfdadc` | Dependency updates |

**Status labels** (green/yellow shades):
| Label | Color | Description |
|-------|-------|-------------|
| `status: blocked` | `e99695` | Blocked by something else |
| `status: needs-info` | `e99695` | Needs more information |
| `status: in-progress` | `fbca04` | Being worked on |
| `status: review-needed` | `fbca04` | Needs code review |
| `status: ready` | `7bb420` | Ready to be picked up |
| `status: wontfix` | `ffffff` | Will not be fixed |
| `status: duplicate` | `cfd3d7` | Duplicate of another issue |

**Priority labels** (red shades):
| Label | Color | Description |
|-------|-------|-------------|
| `priority: critical` | `b60205` | Must fix immediately |
| `priority: high` | `d73a4a` | Should be fixed soon |
| `priority: medium` | `fbca04` | Normal priority |
| `priority: low` | `0e8a16` | Low priority / nice to have |

**Area labels** (purple shades — optional, ask user):
| Label | Color | Description |
|-------|-------|-------------|
| `area: api` | `5319e7` | API-related |
| `area: ui` | `5319e7` | UI/frontend |
| `area: cli` | `5319e7` | CLI-related |
| `area: core` | `5319e7` | Core functionality |
| `area: config` | `5319e7` | Configuration |

```powershell
# For each label:
gh label create "type: bug" --color d73a4a --description "Something isn't working" --repo $owner/$repoName
```

### PHASE 7: Add Badges to README (MANDATORY)

Insert at the top of README.md (after the title heading):

```markdown
<p align="center">

![License](https://img.shields.io/badge/license-${license}-${color})
![GitHub Stars](https://img.shields.io/github/stars/${owner}/${repo}?style=social)
[![CI](https://github.com/${owner}/${repo}/actions/workflows/ci.yml/badge.svg)](https://github.com/${owner}/${repo}/actions/workflows/ci.yml)
[![npm version](https://img.shields.io/npm/v/${packageName}.svg)](https://www.npmjs.com/package/${packageName})

</p>
```

Default badge set:
- **License** — shields.io badge (always)
- **CI status** — pointing to the CI workflow (always)
- **npm version** — for npm packages
- **Python version** — for Python packages
- **Go version** — for Go packages
- **Coverage** — placeholder for codecov (optional)
- **GitHub stars** — social badge (optional)

### PHASE 8: Setup CI/CD (MANDATORY)

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  quality:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      
      - run: npm ci
      - run: npm run lint        # if applicable
      - run: npm run typecheck   # if TypeScript
      - run: npm test
      - run: npm run build       # if applicable
```

Also create optional workflows based on project type:

**release.yml** (for packages — triggered on tag push):
```yaml
name: Release

on:
  push:
    tags: ['v*']

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          registry-url: https://registry.npmjs.org
      - run: npm ci
      - run: npm run build
      - run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
      - uses: softprops/action-gh-release@v1
```

**Auto-label.yml** (optional — auto-label PRs by branch prefix):
```yaml
name: Auto Label

on:
  pull_request:
    types: [opened]

jobs:
  label:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/labeler@v5
```

### PHASE 9: Initialize Git and Push (MANDATORY)

```powershell
# Stage everything
git add -A

# Initial commit
git commit -m "chore: initial scaffold

- Configured project structure
- Added documentation (README, LICENSE, CONTRIBUTING, CHANGELOG)
- Set up CI/CD pipeline
- Added GitHub labels
- Configured EditorConfig and gitignore"

# Push
git push origin main
```

### PHASE 10: Verify & Report (MANDATORY)

Run these checks and report results:

```powershell
# Verify repo exists
$repoCheck = gh repo view $owner/$repoName --json name,url 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Repo created successfully"
}

# Verify labels
$labelCount = (gh label list --repo $owner/$repoName 2>$null).Count
Write-Host "✓ $labelCount labels created"

# Verify CI file exists
if (Test-Path ".github/workflows/ci.yml") {
    Write-Host "✓ CI workflow created"
}

# Verify README has badges
if (Select-String -Path "README.md" -Pattern "img.shields.io") {
    Write-Host "✓ Badges added to README"
}

# Verify git remote
$remote = git remote -v
if ($remote -match $repoName) {
    Write-Host "✓ Remote configured"
}
```

## Final Report

Present a clean summary:

```
✅ Full scaffolding complete!

Repository:     https://github.com/{owner}/{repo}
Local path:     {localPath}
Project type:   {type}
License:        {license}

Created:
  📁 Folders:     {count}
  📄 Files:       {count of .md, .yml, config files}
  🏷️  Labels:     {count} ({categories})
  🛡️  Badges:     {count}
  🔄 CI/CD:       ci.yml, release.yml

Next steps:
  cd {localPath}
  code .                   # Open in editor
  npm run dev              # Start developing
  # Review and customize README.md
  # Set up secrets: NPM_TOKEN, CODECOV_TOKEN
```

## Error Recovery

| Failure Point | Action |
|---------------|--------|
| `gh repo create` fails (name taken) | Suggest alternative name, ask user |
| `gh auth` not configured | Show `gh auth login` instructions |
| Push rejected | Check branch protection, suggest `--force` only after user confirms |
| Label creation fails on existing label | Use `--force` flag or skip duplicates |
| File write permissions | Check directory ownership, retry with admin |

## Prohibited Actions

- ❌ Do NOT create placeholder files with TODO comments — write real content
- ❌ Do NOT skip the context-gathering phase
- ❌ Do NOT push without user-facing verification
- ❌ Do NOT force-push unless explicitly authorized
- ❌ Do NOT create private repos with `MIT` license (MIT implies public domain)
- ❌ Do NOT commit secrets, API keys, or real credentials
