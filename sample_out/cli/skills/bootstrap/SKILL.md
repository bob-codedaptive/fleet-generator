---
name: bootstrap
description: >-
  Session-start ritual every agent on fleet-generator runs — read state, load context, report briefly, wait for direction.
when_to_use: >-
  Starting a fresh agent session. Recovering after compaction. Asking what to read first. Subagent inheriting cwd from orchestrator. Trigger phrases: bootstrap, session start, run the bootstrap ritual, set cwd, what's in flight, where am I, getting started.
status: active
tags: [skill]
updated: 2026-05-07
---

# Bootstrap — Session Startup

Every agent runs a startup ritual at the beginning of a session so
that:

1. The agent knows the current state of the world
2. The agent has loaded its persona and is operating in character
3. The agent has read any messages waiting for it
4. The agent has caught up on git state where relevant

## The five steps

### 1. Set working directory

`cd` to the canonical working directory for this session. For
fleet-generator, the default is the repo root.

### 2. Pull from origin (where applicable)

```bash
git pull --rebase origin <main-branch>
```

Skip pulls when working in a feature branch you don't want updated
mid-session.

### 3. Read state

Read in this order:

1. `CLAUDE.md` — project rules and locked decisions
2. `README.md` — project overview
3. Recent `git log --oneline -10` — what has been happening
4. `.claude/missions/` if a mission is in flight

### 4. Report state

One short paragraph (see the `communication` skill for verbosity).
Cover: current state, what changed recently, anything noticed. Do not
narrate the bootstrap steps. The human will ask follow-ups if needed.

### 5. Wait for direction

Do not start working until told what to do. The exception:
self-evident continuation of an in-flight mission with a clear next
Part — proceed and report.

## When bootstrap fails partially

If part fails (can't pull, file missing, etc.), report the failure
briefly and continue with what's available. Don't refuse to act
because one step didn't complete.

## When bootstrap is skipped

Bootstrap is NOT skipped because:

- "I just did this last session" — sessions don't share memory
- "I know the state from the conversation" — the conversation may be
  stale; verify (this is filesystem-is-truth)
- "It'll take too long" — bootstrap is fast; if it isn't, that's a
  bug worth fixing

The only legitimate skip: explicit human instruction.
