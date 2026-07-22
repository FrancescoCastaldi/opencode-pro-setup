---
name: git-release
description: Draft release notes, propose semver version bumps, and publish GitHub releases from merged PRs.
metadata:
  compatibility: opencode
  tags: [github, release, semver, changelog, gh-cli]
---

# Skill: git-release

Use this skill when the user wants to **draft a release, create a GitHub release, generate a changelog, or propose a version bump** for a repository.

## Dependencies

- `gh` CLI installed and authenticated (`gh auth status`)
- `git` CLI
- Repository with a version file (`package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, or similar)

## Workflow

### 1. Gather context

- Repository: current repo or ask user for `owner/repo`
- Target version: ask user, or auto-propose based on semver
- Release title: optional; default to version tag
- Pre-release: yes/no
- Generate changelog: yes/no

### 2. Determine version bump (semver)

Inspect the version source and list merged PRs since the last release/tag:

```bash
# Last tag
gh release list --repo owner/repo --limit 1 --json tagName
# or
git describe --tags --abbrev=0

# Merged PRs since last tag
gh pr list --repo owner/repo --search "is:merged merged:>YYYY-MM-DD" --json number,title,author,labels,mergedAt
```

Classify merged PRs by labels/titles:
- `BREAKING CHANGE` / major feature → **major** bump
- `feat:` / `feature` / `enhancement` → **minor** bump
- `fix:` / `bug` / `patch` → **patch** bump
- `chore:`, `docs:`, `ci:` → **patch** or no bump

Propose the next version. Ask for confirmation before applying.

### 3. Draft release notes

Generate a structured release note draft:

```markdown
## What's Changed

### 🚀 Features
- #123: Add new feature by @author

### 🐛 Bug Fixes
- #124: Fix the thing by @author

### 🧹 Maintenance
- #125: Update dependencies by @author

### ⚠️ Breaking Changes
- #126: Rename API by @author
```

Use:
- `gh pr list --repo owner/repo --search "is:merged merged:>YYYY-MM-DD" --json number,title,author,labels`
- `gh release create` with `--notes` or `--notes-file`

### 4. Update version file (optional)

If the user confirms, update the version in the appropriate manifest:
- `package.json` → `npm version <major|minor|patch>` or edit manually
- `Cargo.toml` → edit `version`
- `pyproject.toml` → edit `version`
- `go.mod` → tag-based versioning

Commit the version bump with a conventional commit:

```bash
git add -A
git commit -m "chore(release): bump version to vX.Y.Z"
```

### 5. Create GitHub release

```bash
# Create tag and release
gh release create vX.Y.Z \
  --repo owner/repo \
  --title "vX.Y.Z" \
  --notes-file release-notes.md \
  --target main
```

For pre-releases:

```bash
gh release create vX.Y.Z-beta.1 --repo owner/repo --title "vX.Y.Z-beta.1" --notes-file release-notes.md --prerelease
```

### 6. Generate or update CHANGELOG.md

Append to `CHANGELOG.md`:

```markdown
## [vX.Y.Z] - YYYY-MM-DD

### Added
- ...

### Fixed
- ...

### Changed
- ...
```

Commit changelog update:

```bash
git add CHANGELOG.md
git commit -m "docs: update changelog for vX.Y.Z"
```

## Error Handling

| Problem | Action |
|--------|--------|
| No tags found | Create initial release `v0.1.0` |
| `gh` not authenticated | Stop and show `gh auth login` instructions |
| Version file not found | Ask user where version is stored |
| Release already exists | Ask to edit existing release or bump version |

## Safety Rules

- Do not publish a release without user confirmation.
- Do not push tags unless explicitly authorized.
- Do not commit version bumps to protected branches without user approval.
- Keep release notes factual and link back to PRs/issues.
