---
name: github-repo-optimizer
description: Analyze and optimize GitHub repository health.
metadata:
  compatibility: opencode
  tags: [github, repo-health, optimization, branches, security, actions]
---

# Skill: github-repo-optimizer

Use this skill when the user asks to **analyze, audit, or optimize a GitHub repository**.

## Dependencies

- `gh` CLI installed and authenticated (`gh auth status`)
- GitHub MCP server (`@modelcontextprotocol/server-github`) enabled

## Workflow

### 1. Check repository health

```bash
# Stale branches
gh api repos/owner/repo/branches --paginate --jq '.[] | {name, commit: .commit.sha, protected}'

# Old issues
gh issue list --repo owner/repo --state open --search "created:<YYYY-MM-DD" --limit 100

# Inactive PRs
gh pr list --repo owner/repo --state open --search "updated:<YYYY-MM-DD" --limit 100
```

Identify:
- Branches older than 90 days
- Issues open longer than 180 days
- PRs inactive for more than 30 days

### 2. Analyze workflows/actions status

```bash
# List workflows
gh api repos/owner/repo/actions/workflows --jq '.workflows[] | {name, state, path}'

# Recent runs
gh run list --repo owner/repo --limit 20 --json name,status,conclusion,createdAt
```

Flag:
- Disabled workflows
- Consistently failing workflows
- Workflows without branch filters
- Missing `pull_request` or `push` triggers

### 3. Suggest branch cleanup candidates

Generate a list of safe-to-delete branches:
- Merged and not protected
- No open PRs
- Older than threshold

Suggest deletion with user approval.

### 4. Review security settings

```bash
# Branch protection rules
gh api repos/owner/repo/branches/main/protection --jq '{required_status_checks, enforce_admins, required_pull_request_reviews}'

# Secret scanning alerts
gh api repos/owner/repo/secret-scanning/alerts --jq '.[] | {number, secret_type, state, created_at}'

# Dependabot alerts
gh api repos/owner/repo/dependabot/alerts --jq '.[] | {number, state, dependency, severity}'
```

Check for:
- Branch protection enabled on default branch
- Required PR reviews
- Required status checks
- Secrets scanning enabled
- Dependabot alerts

### 5. Review label and milestone hygiene

```bash
gh label list --repo owner/repo --limit 100
gh api repos/owner/repo/milestones --jq '.[] | {title, state, open_issues, closed_issues}'
```

Suggest:
- Removing unused or duplicate labels
- Consolidating similar labels
- Adding missing `type:`, `priority:`, `status:` labels
- Closing completed milestones

### 6. Generate optimization report

```markdown
# Repository Health Report: owner/repo

## Health Score
- Stale branches: N
- Old issues: N
- Inactive PRs: N

## Actions
- Workflows: N total, N failing, N disabled

## Security
- Branch protection: enabled/disabled
- Required reviews: yes/no
- Secret scanning: enabled/disabled
- Dependabot alerts: N

## Hygiene
- Labels: N (unused: N)
- Milestones: N open, N closed

## Recommended Actions
1. Delete stale branches (list)
2. Close or label old issues
3. Update failing workflows
4. Enable branch protection/secret scanning
5. Clean up labels and milestones
```

## Safety Rules

- Do not delete branches, close issues, or change security settings without user approval.
- Present the report and ask for explicit confirmation before applying any changes.
- Never expose secrets or alert details in output.
