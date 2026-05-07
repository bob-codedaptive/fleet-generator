---
name: branch-hygiene
description: >-
  One task per branch on fleet-generator. Clean up after merge. Never commit directly to integration branches.
when_to_use: >-
  Creating a branch. Naming a branch. Cleaning up after a merge. Trigger phrases: branch, branch hygiene, one task per branch, cleanup, branch from develop, never commit to main.
status: active
tags: [skill]
updated: 2026-05-07
---

# Branch Hygiene

## The rules

1. **One task per branch.** Never mix unrelated changes.
2. **Name branches descriptively.** Include the task name.
3. **Branch from the correct base.** Usually `main` or `develop`.
4. **Clean up after merge.** Delete the branch locally and remotely.
5. **Never commit directly to main / develop.** Always use a branch.

## Naming

`<type>/<short-name>` or `<short-name>` — pick one and stay
consistent.

Good:
- `feature/social-login`
- `fix/parser-crash`
- `refactor/extract-user-model`

Bad:
- `branch-1` — meaningless
- `woodstock-stuff` — branches don't belong to agents
- `fix` — too vague

## Lifecycle

```bash
# Create
git checkout -b feature/x main

# Work
# ...commits...

# Push
git push -u origin feature/x

# Merge (typically via PR / review)
# ...

# Cleanup
git checkout main
git pull
git branch -d feature/x
git push origin --delete feature/x
```

## What goes in one branch

One task = one logical unit of work. Examples:

- "Add password reset" → one branch
- "Fix parser bug" → one branch
- "Add password reset AND fix parser bug" → two branches

If you're tempted to mix, the test is: would these two changes be
reviewed as one PR or two? If two, they're two branches.

## Stale branches

Branches that have been open for more than a week without progress
are stale. Either finish, abandon (delete), or rebase onto current
`main`/`develop` and continue.

The graveyard of "branches I'll get to" is real. Burn them
periodically.
