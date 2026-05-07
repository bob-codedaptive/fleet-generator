---
status: active
tags: [rules, always-applies, hazmat, fleet-wide]
---

# Hazmat Rules — Always-On Operating Rules

These rules apply at all times to every agent on this project. They
are observed-failure rules — each one exists because someone
violated it and broke something. Don't reinvent the failure.

## 1. SPEC-BEFORE-REALITY

Grep symbols, read files, list directories **before** writing claims
about existing code. Memory is not a source of truth.

Before any agent claims "the type is X" or "the field is Y," verify
or stay silent. No "I'm pretty sure it's…"

## 2. LOOK-BEFORE-WRITE

List the target directory as step zero of any write. Catch
collisions and stale state before they ship. `ls` the destination
before `Edit`/`Write`.

## 3. WRITE-SURFACE

Each agent has a defined write surface (its lane). The orchestrator
writes mission files. The worker writes code in the mission's
"Files to Modify" list. Read-only agents write nothing. Crossing
surfaces requires explicit human approval.

## 4. NO-OVERWRITE

If a file was recently modified by another agent (check
`git log --oneline -5 <file>`), verify before changing it. Two
agents must not modify the same file simultaneously.

## 5. MISSION-SCOPE-IS-A-BOUNDARY

Only modify files listed in the mission. Everything else is
off-limits, even if "while you're in there" looks tempting. Scope
creep is how partial migrations ship.

## 6. ASK-WHEN-CROSSING-LANES

If a task requires work outside your role, stop and ask the human.
Don't quietly extend your lane. The orchestrator does not commit
code; the worker does not author missions; reviewers do not modify
files.

## 7. REPORT-CONFLICTS-IMMEDIATELY

If you find a conflict with another agent's work — overlapping
edits, contradicting assumptions, races — stop and report it rather
than guessing how to resolve it.

## How agents use these rules

When an agent is about to violate one of these rules, the right move
is **stop and ask the human**. The cost of asking is low. The cost of
violating one of these rules is high enough that the rule exists.

## Updating the rules

Hazmat rules are tightened only after observed failures. Adding a
rule requires recording the incident that motivated it. Removing a
rule requires recording the mechanical prevention that replaced it.
