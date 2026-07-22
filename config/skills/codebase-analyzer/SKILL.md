---
name: codebase-analyzer
description: Perform deep codebase analysis for GitHub-hosted projects. Maps structure, tech stack, dependencies, code quality, dead code, duplicates, and architecture; produces an actionable health report.
license: MIT
metadata:
  author: Francesco Castaldi
  tags: [codebase, analysis, architecture, quality, audit, dependencies, health-report]
---

# codebase-analyzer

## What I do

I analyze a codebase holistically and generate a structured health report. I map project structure, identify the tech stack, audit dependencies, measure code quality, find dead code, detect duplication, and produce architecture/dependency diagrams.

## When to use

- Onboarding to a new repository
- Before planning large refactors or migrations
- For periodic codebase health checks
- When asked to understand, audit, or improve code quality

## Workflow

### Step 1: Discover project structure

1. Identify the repository root and VCS status.
2. Use `fd` to list files by category and `ripgrep` to find key manifests.
3. Detect project type(s) from files such as `package.json`, `Cargo.toml`, `pyproject.toml`, `requirements.txt`, `go.mod`, `Gemfile`, etc.

### Step 2: Map tech stack and dependencies

1. Read the main manifest files.
2. List production vs. dev dependencies and their declared versions.
3. Identify framework, runtime, build tool, and test runner.

### Step 3: Analyze code quality

1. Run `cloc` (optional) to count lines of code by language.
2. Identify long functions, deeply nested files, and large modules via `ripgrep`/`fd`.
3. Look for anti-patterns (singleton misuse, tight coupling, magic numbers, duplicated strings).
4. Check test coverage if coverage reports or scripts are present.

### Step 4: Find dead code, duplication, and unused dependencies

1. Search for exports, functions, classes, or variables that are never imported.
2. Use `ripgrep` to find duplicated blocks or copy-pasted code.
3. Compare `package.json` dependencies against actual imports in source files.
4. Flag deprecated APIs or TODO/FIXME comments.

### Step 5: Generate architecture and dependency diagrams

1. Identify high-level modules, entry points, and public APIs.
2. Build a dependency graph (modules import each other).
3. Create an architecture diagram in Mermaid format inside the report.

### Step 6: Produce a health report

1. Write a Markdown report named `CODEBASE_HEALTH_REPORT.md`.
2. Include sections:
   - Project overview
   - Tech stack
   - Dependency summary
   - Quality findings
   - Dead code & duplication
   - Architecture diagram
   - Risk areas
   - Actionable recommendations with priority

## Dependencies

- `fd` (file listing)
- `ripgrep` (fast text search)
- `cloc` (optional line count)
- GitHub MCP server (`@modelcontextprotocol/server-github`) for remote repository metadata
- `gh` CLI for repository context and PR/issue data

## Example Interaction

```
User: Analyze this codebase and tell me where the quality problems are.

Agent: I'm using the codebase-analyzer skill. I'll map the project, audit dependencies and quality, then generate a health report.

[Runs fd, ripgrep, reads package.json, detects React + TypeScript project]
[Finds 3 unused dependencies, 2 duplicated functions, low test coverage in src/api/]
[Generates CODEBASE_HEALTH_REPORT.md with Mermaid architecture diagram]

Agent: Report generated. Top issues: remove unused lodash/deep, deduplicate validation in src/utils, add tests for src/api. Recommendations are ranked by priority.
```
