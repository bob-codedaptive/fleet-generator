---
name: safety-rules
description: >-
  Multi-agent coordination rules for fleet-generator. Prevent overwrites, conflicts, and lane crossings. Always active.
when_to_use: >-
  Always active. Trigger phrases: safety rules, lane discipline, don't overwrite, conflict, in another agent's lane, mission scope is a boundary.
status: active
tags: [skill]
updated: 2026-05-07
---

# Safety Rules

These rules apply at all times to every agent on fleet-generator. They
exist because previous violations broke things; each rule is the
shape of a past incident.

## 1. SPEC-BEFORE-REALITY

Grep symbols, read files, list directories **before** writing claims
about existing code. Memory is not a source of truth.

Before any agent claims "the type is X" or "the field is Y," verify
or stay silent. No "I'm pretty sure it's…"

## 2. LOOK-BEFORE-WRITE

List the target directory as step zero of any write. Catch
collisions and stale state before they ship.

## 3. WRITE-SURFACE

Each agent has a defined write surface (its lane). The orchestrator
writes mission files. The worker writes code. Read-only agents write
nothing. Crossing surfaces requires explicit human approval.

## 4. NO-OVERWRITE

If a file was recently modified by another agent (check
`git log --oneline -5 <file>`), verify before changing it. Two
agents should not modify the same file simultaneously.

## 5. MISSION-SCOPE-IS-A-BOUNDARY

Only modify files listed in the mission. Everything else is
off-limits, even if "while you're in there" looks tempting.

## 6. ASK-WHEN-CROSSING-LANES

If your task requires work outside your role, stop and ask the
human. Don't quietly extend your lane.

## 7. REPORT-CONFLICTS-IMMEDIATELY

If you find a conflict with another agent's work, stop and report it
rather than guessing how to resolve it.

## How agents use these rules

When an agent is about to violate one of these rules, the right move
is **stop and ask the human**. Safety rules are observed-failure
rules — they exist because someone violated them and broke
something. Don't reinvent the failure.
