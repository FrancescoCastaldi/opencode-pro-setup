---
name: codebase-refactorer
description: Assist large, safe refactoring in GitHub-hosted codebases. Analyzes opportunities, plans phases, uses git worktrees, runs tests after each phase, and produces a review-ready PR.
license: MIT
metadata:
  author: Francesco Castaldi
  tags: [refactoring, git-worktree, tests, pr, code-quality, github]
---

# codebase-refactorer

## What I do

I help refactor codebases safely. I analyze the code for refactoring opportunities, plan the work in phases, create an isolated git worktree, run tests after each phase, and generate a diff with a PR for review.

## When to use

- When a codebase needs cleanup, modernization, or restructuring
- Before or after a migration
- When duplicate code, dead code, or tight coupling is identified
- When a user explicitly asks for refactoring

## Workflow

### Step 1: Analyze refactoring opportunities

1. Search for code smells: duplication, long functions, large classes, tight coupling, magic numbers, deep nesting.
2. Identify safe candidates: rename, extract, move, split, or delete.
3. Estimate risk and impact (public API, tests, dependencies).

### Step 2: Plan refactoring in phases

1. Create a `REFACTOR_PLAN.md` with phases.
2. Order phases from low risk to high risk.
3. Define success criteria for each phase (e.g., tests pass, no public API changes).

Phases:
- Extract: move duplicated logic to shared helpers.
- Rename: rename variables, functions, and files for clarity.
- Restructure: split modules, move files, or update imports.

### Step 3: Create a git worktree

1. Use the `using-git-worktrees` skill to create an isolated workspace.
2. Branch name: `refactor/<short-description>`.
3. Run tests to confirm a clean baseline.

### Step 4: Execute one phase at a time

1. Apply changes for the current phase.
2. Run the project-appropriate test command (`npm test`, `cargo test`, `pytest`, etc.).
3. If tests fail, fix or revert and ask for guidance.
4. Commit the phase with a clear message.

### Step 5: Generate diff and PR

1. Review the final diff.
2. Write a PR description summarizing the plan, phases, and verification.
3. Use `gh pr create` to open the PR.
4. Ask the user for review approval before merging.

## Dependencies

- `git` with worktree support
- `using-git-worktrees` skill for isolation
- `tester` agent for test execution and verification
- Project test runner

## Example Interaction

```
User: Refactor the auth module to remove duplication.

Agent: I'm using the codebase-refactorer skill. I'll analyze the code, plan phases, create an isolated worktree, and verify with tests.

[Analyzes src/auth/ and finds duplicated token validation logic]
[Creates worktree at .worktrees/auth-refactor]
[Phase 1: extract token validation into src/auth/utils.ts — tests pass]
[Phase 2: update all call sites — tests pass]
[Creates PR with title "refactor(auth): extract and deduplicate token validation"]

Agent: Refactor complete. PR #123 is ready for review with a clean test history.
```
