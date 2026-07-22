---
name: codebase-documenter
description: Automate documentation for GitHub-hosted codebases. Scans existing docs, identifies gaps, and generates or updates README, API reference, architecture docs, and contributor templates.
license: MIT
metadata:
  author: Francesco Castaldi
  tags: [documentation, readme, api-docs, contributing, changelog, github]
---

# codebase-documenter

## What I do

I make sure a codebase is well-documented. I scan existing documentation, identify gaps, and generate or update README files, API reference, architecture docs, CONTRIBUTING.md, CHANGELOG.md, and inline documentation.

## When to use

- When starting a new project or repository
- After adding a major feature and docs are outdated
- When preparing a project for open-source contributors
- When asked to document APIs, architecture, or workflows

## Workflow

### Step 1: Scan existing documentation

1. List all `.md` files in the repository.
2. Identify existing README, API docs, architecture docs, inline comments, and wiki references.
3. Check GitHub repository metadata (description, topics, default branch) via GitHub MCP.

### Step 2: Identify documentation gaps

1. Find public modules, classes, functions, or API endpoints without documentation.
2. Flag missing or outdated README sections (installation, usage, contributing, license).
3. Identify undocumented configuration files, environment variables, and scripts.

### Step 3: Generate or update README

1. Create or update `README.md` with:
   - Project overview and purpose
   - Quick start / installation
   - Usage examples
   - Architecture overview
   - Testing instructions
   - Contributing link
   - License

### Step 4: Create API reference

1. Extract exported functions, classes, types, and endpoints.
2. Generate `docs/API.md` or a structured `docs/api/` folder.
3. Include parameters, return types, and usage examples.

### Step 5: Create contributor templates

1. Create `CONTRIBUTING.md` with setup, branch, PR, and style guidelines.
2. Create `CHANGELOG.md` with a template and recent version entry.
3. Ensure `LICENSE` is present and referenced.

### Step 6: Update docs with every feature change

1. After each feature change, ask: "Which docs are affected?"
2. Update relevant sections in README, API docs, and architecture docs.
3. Append notable changes to CHANGELOG.md.

## Dependencies

- GitHub MCP server (`@modelcontextprotocol/server-github`)
- `fd` and `ripgrep` for doc scanning
- Language-aware tooling for extracting public APIs (e.g., TypeScript, JSDoc, docstring parsers)

## Example Interaction

```
User: Document this API and set up contributor guides.

Agent: I'm using the codebase-documenter skill. I'll scan existing docs, identify gaps, and generate README, API reference, CONTRIBUTING.md, and CHANGELOG.md.

[Lists existing docs, finds missing API docs and CONTRIBUTING.md]
[Creates README.md with quick start, docs/API.md, CONTRIBUTING.md, CHANGELOG.md]

Agent: Documentation package created. Please review README.md and docs/API.md for accuracy.
```
