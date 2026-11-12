---
name: subagent-orchestration
description: >-
  Standard subagent flow for fleet-generator: when Woodstock starts Snoopy for pre-flight, when it starts Marvin for review, how a FAIL is reworked, and when the specialists are pulled in. Always-active doctrine.
when_to_use: >-
  Always active. Read at session start. Trigger phrases: spawn, subagent, Agent tool, pre-flight, post-flight, review, who reviews this, when to call the reviewer, when to start the architect, standard flow, orchestrate, hand off, rework.
status: active
tags: [skill]
updated: 2026-11-12
---

# Subagent Orchestration — Standard Flow

The fleet's agents fire at fixed checkpoints during a mission. This skill
is how Woodstock (the code worker) and Hobbes (the orchestrator) pull
in the right one without waiting to be told.

## Who is on the team

| Agent | Role | Model | Writes |
|---|---|---|---|
| Hobbes (`hobbes`) | Orchestrator | Claude Opus 5.5, medium | yes |
| Bilby (`bilby`) | Coordinator | Claude Opus 5.5, medium | yes |
| Woodstock (`woodstock`) | Code Worker | Claude Opus 5.5, medium | yes |
| Snoopy (`snoopy`) | Pre-flight Scanner | Claude Haiku 5.5, medium | read-only |
| Marvin (`marvin`) | Post-flight Inspector | Claude Haiku 5.5, medium | read-only |
| Agatha (`agatha`) | Submission Gate | Claude Haiku 5.5, high | read-only |
| Calvin (`calvin`) | Architect | Claude Opus 5.5, medium | read-only |
| Ace (`ace`) | Last-resort Coder | Claude Opus 5.5, xhigh | yes |
| Ada (`ada`) | Numeric Specialist | Claude Opus 5.5, xhigh | read-only |
| Sherlock (`sherlock`) | Root-cause Investigator | Claude Opus 5.5, medium | read-only |
| Escher (`escher`) | Visual Consistency Reviewer | Claude Sonnet 5.5, medium | read-only |
| Linus (`linus`) | Doc Writer | Claude Sonnet 5.5, medium | yes |
| Dogbert (`dogbert`) | Security Reviewer | Claude Haiku 5.5, high | read-only |
| Cathy (`cathy`) | Accessibility Reviewer | Claude Sonnet 5.5, medium | read-only |
| Odie (`odie`) | Performance Reviewer | Claude Sonnet 5.5, medium | read-only |

Only the agents enabled in this fleet are listed. Each runs the model
its own file names; do not pass a model when you start one.

## How starting an agent works

Start one with the Agent tool and `subagent_type=<lowercase-name>`. Its
last message is its return; read it before you go on. Start agents in
the same message only when their work is independent. When you resume an
agent (to re-review, say), send it a message rather than starting a new
one: it keeps what it already read.

## The worker's flow

1. **Read the mission end to end**, and the files under Read First.
2. **Start Snoopy** with the mission's file list. It returns
   VERDICT: GREEN, AMBER or RED, the test commands that cover the change,
   and a touch list of comments and docs the change will make stale. RED
   stops the mission until what it names is fixed or ruled on.
3. **If the mission touches existing code, run `blast-radius`** and
   commit the report first.
4. **Implement Part by Part.** Each Part gets its `→ verify:` check (a
   build or one targeted test) and its own commit. Run `pre-commit`
   before each commit.
5. **Run the tests once**, when every Part is in: the commands Snoopy
   listed plus your new tests. Paste the command and the last lines of
   its output.
6. **Run `self-review`.**
7. **Start Marvin** with the mission and the pasted output. It returns
   VERDICT: PASS, PASS WITH FINDINGS or FAIL, with file:line findings on
   one severity scale (1 and 2 block, 3 does not; see `gate-procedures`).
8. **On FAIL**, fix what it names, run the tests that cover the fix, and
   resume the same reviewer. After the third FAIL on the same Part, stop
   and report both positions.
9. **Start the specialists whose triggers fired** (table below).
10. **Report done**: the verdict, the test output, the commits.

Steps 2 and 7 happen on every mission that changes code. A small change
is the most common reason given for skipping them, and the judgment of
whether a change is small belongs to the reviewer.

## The orchestrator's flow

1. **Investigate the codebase.** Read the files the work touches, and the
   ones near them.
2. **For a non-trivial design choice, start Calvin** for a written
   design review. It recommends; the human decides.
3. **Author the mission** with the `mission-template` skill.
4. **Hand it to Woodstock**, or to the coordinator when the mission
   cuts into more than one unit.

## Specialist triggers

Start a specialist as soon as its trigger fires.

| Agent | Start when |
|---|---|
| Snoopy | A mission arrives, before any edit |
| Marvin | After the mission's last commit |
| Calvin | A design touches shared primitives or cross-system boundaries, or sets a pattern others will follow |
| Dogbert | The change touches authentication, user data, dependencies, URL handlers, paths, credentials or the network |
| Cathy | A UI change adds or changes interactive elements |
| Odie | The change touches hot paths, query layers, render paths, or allocation-heavy code |
| Linus | User-visible behaviour changed |
| Sherlock | A unit failed review twice, or a test set will not go green |
| Ace | After Sherlock, for a unit that failed twice with a corrected brief |

Start only the ones whose triggers fired: three reviewers started because
they are available cost three reviews and find nothing the right one
would not.

## Why this exists

Without it, the worker does everything alone. Each specialist catches a
class of mistake the worker is bad at catching in its own work.

The audit-log hooks (`log-subagent-start`, `log-subagent-stop`) make
every start visible. A mission that landed without the standard starts
shows in the log.
