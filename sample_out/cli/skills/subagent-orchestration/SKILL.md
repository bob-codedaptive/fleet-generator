---
name: subagent-orchestration
description: >-
  Standard subagent flow for fleet-generator — when Woodstock spawns Snoopy for pre-flight, when to spawn Garfield for review, and when specialist reviewers (Dogbert, Cathy, Odie) get pulled in. Always-active doctrine.
when_to_use: >-
  Always active. Read at session start. Trigger phrases: spawn, subagent, Task tool, pre-flight, post-flight, review, who reviews this, when to call the reviewer, when to spawn the architect, standard flow, orchestrate, hand off.
status: active
tags: [skill]
updated: 2026-05-07
---

# Subagent Orchestration — Standard Flow

The fleet has multiple agents. They aren't decoration — they fire
naturally at standard checkpoints during a mission. The point of
this skill is so Woodstock (the main coder) and Hobbes (the
orchestrator) PULL IN the right specialists without waiting to be
told.

## Who is on the team

- **Hobbes** — orchestrator (planner, mission author)
- **Woodstock** — code worker (main coder, this is YOU when you're
  implementing)
- **Snoopy** — pre-flight scanner (read-only)
- **Garfield** — post-flight reviewer (read-only)
- **Calvin** — architect (design review, read-only)
- **Dogbert** — security reviewer (read-only)
- **Cathy** — accessibility reviewer (read-only)
- **Odie** — performance reviewer (read-only)
- **Linus** — doc writer

(Whichever of these is enabled in this fleet — others may be off.)

## How spawning works

The main coder spawns subagents using the Task tool with
`subagent_type=<lowercase-name>`. Subagents are read-only by
default (except Woodstock and Linus, who write to specific lanes).

Spawn one subagent at a time unless the queries are independent. Read
their reports before continuing.

## Worker's standard execution order

When Woodstock starts a mission, the flow is:

1. **Read the mission file end-to-end.** Absorb every section.
2. **Read referenced skills.** Particularly `pre-commit`,
   `self-review`, and (if touching existing code) `blast-radius`.
3. **Spawn Snoopy (pre-flight scan).** "Scan files in 'Files to
   Modify' and report risks." Snoopy returns GREEN/YELLOW/RED.
4. **Evaluate the brief.** If RED, fix or escalate before coding.
5. **If touching existing code: run `blast-radius`.** Produce the
   Blast Radius Report; commit it as the first commit of the work.
6. **Implement Part by Part.** Each Part = one logical change = one
   commit. Run the test runner after each step.
7. **Run `pre-commit`** before every commit.
8. **Run `self-review`** after the final commit.
9. **Spawn Garfield (post-flight review).** "Review the diff against
   the mission spec." Garfield returns categorized findings
   (CRITICAL / WARNING / INFO).
10. **Address Garfield's findings.** Fix CRITICALs; document
    WARNINGs that won't be fixed; INFO is informational.
11. **Re-spawn Garfield** until Garfield says PASS.
12. **For specialist concerns, spawn the matching reviewer:**
    - Security-touching change → Dogbert
    - UI / accessibility change → Cathy
    - Hot path / perf-sensitive change → Odie
    - User-facing behavior change → Linus updates the docs
13. **Declare done.**

Steps 3, 9, and 11 are NOT optional for non-trivial missions. They
happen automatically. The audit trail shows whether they ran.

## Orchestrator's standard flow

When Hobbes drafts a mission:

1. **Investigate the codebase.** Read relevant files; understand
   the problem.
2. **For non-trivial design choices, spawn Calvin.** "Review
   the proposed approach for tradeoffs and second-order effects."
   Calvin produces a written design review. Recommendations only —
   the human decides.
3. **Address Calvin's findings** in the mission's Design Notes
   section.
4. **Author the mission file** following the `mission-template`
   skill.
5. **Hand off to Woodstock** with the mission file content.

## Specialist triggers

Spawn a specialist as soon as the trigger fires. Don't batch them
to the end.

| Specialist | Spawn when |
|---|---|
| Snoopy | Mission spec arrives, BEFORE coding starts |
| Garfield | After the final commit of a mission |
| Calvin | Designing anything that touches shared primitives, cross-system boundaries, or sets a new pattern others will follow |
| Dogbert | Touching auth, user data, dependency upgrades, URL handlers, credentials, network |
| Cathy | Any UI mission |
| Odie | Touching hot paths, query layers, render paths, allocation-heavy code |
| Linus | User-visible behavior changed |

## What the worker does NOT do

- Don't skip the pre-flight scan because "it's a small change."
  Snoopy is fast; the audit trail wants the run.
- Don't skip the reviewer because "I checked my own work."
  Self-review is required; reviewer is the second pair of eyes.
- Don't spawn three reviewers in parallel just because they're
  available. Spawn the ones whose triggers actually fired.
- Don't ignore reviewer findings because they slow you down. The
  reviewer flagged it for a reason; address or document.

## What the orchestrator does NOT do

- Don't write code. Mission files only.
- Don't decide architecture unilaterally. Recommend; the human
  decides.
- Don't skip Calvin because "I think I know the right answer."
  If a real design choice exists, Calvin reviews it.

## Why this exists

Without this doctrine, the worker tends to do everything alone. The
specialists exist for a reason — each one catches a class of
mistakes the worker is bad at catching. Standard flow makes sure
the right eyes look at the right code.

The audit-log hooks (`log-subagent-start`, `log-subagent-stop`)
make subagent spawns visible. If the audit log shows a mission
landed without the standard spawns, someone skipped a step.
