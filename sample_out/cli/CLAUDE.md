# CLAUDE.md — fleet-generator

> Personal workshop for maintaining fleet-generator.html

## Project

- **Name:** fleet-generator
- **Description:** Personal workshop for maintaining fleet-generator.html
- **Root folder:** ~/dev

## Repos

| Repo | Branch | Path |
|---|---|---|
| fleet-generator | main | ~/devlop/forge/fleet-generator |

## Team

- **Hobbes** — Orchestrator
- **Woodstock** — Code Worker
- **Garfield** — Reviewer
- **Snoopy** — Pre-flight Scanner
- **Calvin** — Architect
- **Linus** — Doc Writer
- **Dogbert** — Security Reviewer
- **Cathy** — Accessibility Reviewer
- **Odie** — Performance Reviewer

## Vocabulary

- `/scope` — investigation and planning mode
- `/draft` — specification writing mode
- `/submit` — prepare mission for launch

## Standard subagent flow

Woodstock is the main coder. Woodstock pulls in subagents at standard
checkpoints — automatically, every mission. Not after being told.

- **Pre-flight:** Woodstock spawns Snoopy BEFORE coding to scan files for risks.
- **Post-flight:** Woodstock spawns Garfield AFTER the final commit. Re-spawns until PASS.
- **Architecture:** Hobbes spawns Calvin for non-trivial design choices BEFORE handing off.
- **Security:** Woodstock spawns Dogbert when changes touch auth, user data, dependencies, or credentials.
- **Accessibility:** Woodstock spawns Cathy for any UI mission.
- **Performance:** Woodstock spawns Odie when changes touch hot paths or query layers.
- **Docs:** Woodstock spawns Linus when user-visible behavior changes.

See `.claude/skills/subagent-orchestration/SKILL.md` for the full doctrine.
Spawning is the default; not spawning is an exception that requires a reason.

## Working style

- Verbosity: Normal. Clear and complete.
- Emoji: Never use emoji
- When uncertain: Ask first, never guess

## Locked Decisions

_Add canonical decisions here._

## Where things live

- `.claude/agents/` — agent manifests
- `.claude/skills/` — skill instructions (each with a SKILL.md and references/)
- `.claude/rules/` — always-on rules
- `.claude/hooks/` — automation scripts (if installed)
- `.claude/missions/` — mission files for the worker
