---
name: agent-commits
description: >-
  Per-agent git commit identity for fleet-generator. Every agent signs commits so the human can scan git log and tell who did what.
when_to_use: >-
  Composing a commit. Setting GIT_AUTHOR_NAME or running `git -c user.name=...`. Spawning a subagent that will commit. Auditing git log for robot vs human commits. Trigger phrases: commit identity, commit under <agent>'s identity, audit trail, git log --author, per-commit identity, set identity.
status: active
tags: [skill]
updated: 2026-05-07
---

# Commit Identity

Every commit produced by an agent on fleet-generator is signed with a
distinct identity so the audit trail clearly distinguishes human
commits from robot commits, and robots from each other.

## Why this matters

The human reads `git log`. They need to scan and tell at a glance:

- Is this commit human or agent?
- Which agent? (Woodstock? Hobbes?)
- What kind of work did each one do?

Without distinct identities, all agent commits look the same.

## Identity table

| Agent | Author | Email |
|---|---|---|
| Woodstock | `Woodstock` | `woodstock@agent` |
| Hobbes | `Hobbes` | `hobbes@agent` |
| Garfield | (read-only — no commits) | — |
| Snoopy | (read-only — no commits) | — |
| The human | (their own git config) | (their own) |

The `@agent` domain is intentional — these are not real email
addresses, just unique tags that group agent commits.

## Setting identity per-commit (preferred)

```bash
git -c user.name="Woodstock" -c user.email="woodstock@agent" \
  commit -m "type(scope): description"
```

This survives clones, doesn't pollute `.git/config`, and makes the
identity intent visible in the script that issued the commit.

## Setting identity per-session

For multi-commit sessions, set environment variables once:

```bash
export GIT_AUTHOR_NAME="Woodstock"
export GIT_AUTHOR_EMAIL="woodstock@agent"
export GIT_COMMITTER_NAME="Woodstock"
export GIT_COMMITTER_EMAIL="woodstock@agent"
```

For the full identity table including conventions on subagents
acting on another agent's behalf, see
[references/identity-table.md](references/identity-table.md).

## Audit trail

```bash
# all of one agent's commits
git log --author="Woodstock"
# all robot commits
git log --author="@agent"
```
