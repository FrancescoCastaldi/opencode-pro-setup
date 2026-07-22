---
name: github-issue-triage
description: Triage and manage GitHub issues and PRs.
metadata:
  compatibility: opencode
  tags: [github, issues, prs, triage, labels, milestones]
---

# Skill: github-issue-triage

Use this skill when the user asks to **triage, organize, classify, or manage GitHub issues and pull requests**.

## Dependencies

- `gh` CLI installed and authenticated (`gh auth status`)
- GitHub MCP server (`@modelcontextprotocol/server-github`) enabled

## Workflow

### 1. List open issues and PRs

```bash
# Issues
gh issue list --repo owner/repo --limit 100 --state open --json number,title,author,labels,createdAt,updatedAt,assignees,milestone

# PRs
gh pr list --repo owner/repo --limit 100 --state open --json number,title,author,labels,createdAt,updatedAt,assignees,milestone
```

If no repo is specified, use the current repository or ask the user.

### 2. Classify items

For each issue/PR, classify into:
- `bug` — defect, regression, unexpected behavior
- `feature` — new capability
- `question` — support or clarification
- `tech-debt` — refactoring, maintenance, modernization
- `docs` — documentation
- `ci` — build/test/automation

Use title, body, labels, and comments for classification. Prefer evidence over assumptions.

### 3. Check for duplicates

Search for similar titles and bodies:

```bash
gh issue list --repo owner/repo --search "<keywords>" --state all --limit 20
```

Flag likely duplicates and suggest closing them with a reference comment.

### 4. Suggest labels and milestones

Propose:
- `type:` labels (`type: bug`, `type: feature`, etc.)
- `priority:` labels (`priority: critical`, `priority: high`, etc.)
- `status:` labels (`status: needs-info`, `status: ready`, etc.)
- `area:` labels if applicable
- Milestone assignment based on issue complexity and roadmap

Apply only with user approval.

### 5. Suggest assignment

For unassigned issues, suggest an assignee based on:
- Recent commit history in the relevant area
- Existing issue/PR assignments
- Team roles or CODEOWNERS

```bash
gh api repos/owner/repo/contributors --jq '.[] | .login'
```

### 6. Generate triage report

Produce a concise markdown report:

```markdown
# Triage Report: owner/repo

## Summary
- Open issues: N
- Open PRs: N
- Unassigned: N
- Needs classification: N

## Classified Items
| # | Title | Type | Priority | Suggested Labels | Suggested Assignee |
|---|-------|------|----------|------------------|---------------------|

## Duplicates
| # | Title | Likely duplicate of |

## Recommended Actions
- Close duplicates
- Add labels to items without type
- Assign unassigned issues
- Set milestone for high-priority items
```

## Safety Rules

- Do not close, label, assign, or edit issues/PRs without user approval.
- Present the triage report first; apply changes only when confirmed.
- Respect repository conventions (existing labels, CODEOWNERS, project boards).
