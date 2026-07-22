---
name: dependency-auditor
description: Audit dependencies for GitHub-hosted codebases. Scans manifest files, detects outdated, deprecated, or vulnerable packages, checks licenses, and generates a dependency health report.
license: MIT
metadata:
  author: Francesco Castaldi
  tags: [dependencies, audit, security, licenses, vulnerabilities, github]
---

# dependency-auditor

## What I do

I audit project dependencies. I scan manifest files, identify outdated, deprecated, or vulnerable packages, review license compliance, and provide a prioritized dependency health report with safe upgrade suggestions.

## When to use

- During security reviews
- Before releases or dependency updates
- When onboarding or inheriting a project
- When asked to clean up or modernize dependencies

## Workflow

### Step 1: Detect manifests

1. Search for dependency manifests:
   - `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
   - `requirements.txt`, `Pipfile`, `poetry.lock`, `pyproject.toml`
   - `Cargo.toml`, `Cargo.lock`
   - `Gemfile`, `Gemfile.lock`
   - `go.mod`, `go.sum`
   - `composer.json`, `composer.lock`

### Step 2: Run ecosystem audits

1. **npm/yarn/pnpm**: `npm audit`, `yarn audit`, or `pnpm audit`
2. **Python**: `pip audit` or `safety check`
3. **Rust**: `cargo audit`
4. **Ruby**: `bundle audit`
5. **PHP**: `composer audit` (if available)

### Step 3: Check outdated versions

1. Run the appropriate outdated command:
   - `npm outdated`, `yarn outdated`, `pnpm outdated`
   - `pip list --outdated` or `poetry show --outdated`
   - `cargo outdated`
   - `bundle outdated`
   - `go list -u -m all`

### Step 4: Audit licenses

1. List all installed packages with `npm list --all`, `pip list`, etc.
2. Check license metadata in `node_modules/*/package.json` or equivalent.
3. Flag licenses incompatible with the project license (e.g., GPL in a closed-source project).
4. Record license findings in the report.

### Step 5: Suggest version bumps

1. For each outdated package, suggest a target version.
2. Flag breaking changes using release notes or changelog hints.
3. Prioritize updates by security severity, age, and compatibility.

### Step 6: Generate dependency health report

1. Create `DEPENDENCY_HEALTH_REPORT.md`.
2. Include:
   - Manifests found
   - Audit summary (critical/high/medium/low)
   - Outdated packages table
   - License compliance status
   - Recommended actions with order of execution

## Dependencies

- `npm audit`, `yarn audit`, or `pnpm audit`
- `pip audit` (Python) or `safety`
- `cargo audit` (Rust)
- `bundle audit` (Ruby)
- `gh` CLI for repository context and Dependabot alerts
- Optional: `license-checker` or `licensee` for Node.js license scanning

## Example Interaction

```
User: Audit dependencies for vulnerabilities and outdated packages.

Agent: I'm using the dependency-auditor skill. I'll scan manifests, run audits, and produce a dependency health report.

[Detects package.json and package-lock.json]
[npm audit: 2 moderate vulnerabilities in lodash and axios]
[npm outdated: 7 packages including eslint v8 -> v9 (breaking)]
[License scan: all MIT/ISC except one GPL-2.0 transitive package]
[Generates DEPENDENCY_HEALTH_REPORT.md with prioritized fixes]

Agent: Audit complete. Top priority: patch lodash and axios. Defer eslint upgrade until you can handle breaking changes.
```
