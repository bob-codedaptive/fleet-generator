---
name: git-workflow
description: >-
  Git operating conventions for fleet-generator — branch naming, commit-message format, push protocol, prohibited operations.
when_to_use: >-
  Starting or finishing a session in a worktree. Composing a commit message. Configuring a branch. Pushing to remote. Trigger phrases: git workflow, branch from main, never force push, never commit to main, commit message format, type(scope): description, branch naming.
status: active
tags: [skill]
updated: 2026-05-07
---

# Git Workflow

## Branches

| Repo | Stable | Dev / integration | Worker branch |
|---|---|---|---|
| fleet-generator | `main` | `develop` (if used) | `feature/<name>` |

- Never commit directly to `main` or `develop`
- Branch from `develop` if present, otherwise `main`
- One task per branch — never mix unrelated changes
- Branch name describes the task: `add-login`, `fix-parser-crash`

## Commit messages

```
type(scope): short description
```

**Types:** `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

**Examples:**
```
feat(auth): add password reset flow
fix(parser): handle empty input
docs(readme): update install instructions
refactor(models): extract User into separate file
test(workers): add edge cases for retry logic
chore(build): update .gitignore
```

For per-agent commit identity, see the `agent-commits` skill.

## Before pushing

1. Run the `pre-commit` checklist
2. Run `self-review`
3. Verify all tests pass
4. Read the commit log of your branch — does it tell a clean story?

## Push protocol

```bash
git push origin <branch>
```

Never force-push to `main` or `develop`.
Never push without verifying tests.

## Cleanup after merge

```bash
git branch -d <branch>
git push origin --delete <branch>
```

See [references/branch-conventions.md](references/branch-conventions.md)
for naming details.

## Never do these

- Never commit directly to `main`
- Never force-push shared branches
- Never commit generated files (`build/`, `dist/`, `node_modules/`)
- Never commit API keys or credentials
- Never use `--no-verify` to skip hooks

## Worktree usage

For parallel mission work, use git worktrees:

```bash
git worktree add ../fleet-generator-feature-x feature/x
git worktree list
git worktree remove ../fleet-generator-feature-x
```
