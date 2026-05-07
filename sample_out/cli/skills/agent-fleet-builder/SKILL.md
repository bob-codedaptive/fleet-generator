---
name: agent-fleet-builder
description: >-
  Rubric and methodology for building and auditing a Claude Code agent fleet on fleet-generator toward A-grade. Defines what A-grade means in each mechanism category, the wave-based refactoring methodology, and the verification gate.
when_to_use: >-
  Auditing the fleet against the A-grade rubric. Designing a refactoring wave. Deciding which mechanism (subagent / skill / hook / rule / memory) fits a need. Reviewing whether a fleet has reached A-grade. Trigger phrases: A-grade fleet, fleet audit, fleet refactor, wave methodology, agent fleet quality, rubric, what mechanism fits, how do I improve this fleet.
status: active
tags: [skill]
updated: 2026-05-07
---

# Agent Fleet Builder

The rubric and methodology for moving a Claude Code agent fleet on
fleet-generator from working to A-grade.

**A-grade means:** every Claude Code mechanism the fleet could
benefit from is used correctly, deliberately, and with measurable
impact on session quality. Working is the floor. A-grade is the
ceiling.

## The seven categories

A-grade requires an A in each. C-and-below issues block the overall
grade; B-grade categories drag but don't block.

### A — Subagent design

- Every subagent has complete frontmatter: `name`, `description`,
  `tools`, `model`, `memory` (and `disallowedTools` when
  needed).
- Recurring-shape subagents declare `initialPrompt`.
- Reasoning-heavy subagents declare `effort` deliberately (default
  may not be optimal for low-reasoning lanes).
- Tool restrictions use the `Agent(...)` allowlist syntax.
- Memory scope is correct: `project` for fleet agents, `user` for
  cross-project knowledge, `local` for unsynced personal content.
- `mcpServers` scopes MCPs per subagent when relevant.

### B — Skill design

- Every skill has `description` AND `when_to_use` separated. The
  description is what the skill does in one precise sentence;
  `when_to_use` carries trigger phrases and example queries.
- Skills with arguments declare `argument-hint`.
- Skills with side-effecting tools use `allowed-tools` to pre-approve
  the safe surface.
- Long content lives in `references/` files, linked from SKILL.md.
  Progressive disclosure — the body is short, the references carry
  depth.

### C — Hooks

- Hooks are deployed for: state observability (subagent start/stop,
  pre/post compact, transcript save), enforcement (write-scope,
  push gate), and habit formation (memory-curation prompt).
- Hooks fail open on errors; logged warnings, not session aborts.
- Default mode is WARN; flip to BLOCK after observation period.

### D — Rules and CLAUDE.md

- Always-on rules carry the project's hazmat list and compaction
  preservation instructions.
- Path-scoped rules load only when relevant files are touched.
- CLAUDE.md is concise; locked decisions live there, narratives don't.

### E — Memory

- Auto-memory at `.claude/agent-memory/<agent>/` is curated, not
  auto-dumped. Learning notes are written deliberately.
- Persistent memory backend (NexusMCP / mempalace) is queried at
  session start, written at milestones, invalidated when stale.

### F — Models and effort

- Model choice matches reasoning needs. Opus for the heavy lifting;
  Haiku for cheap ops.
- `effort` is set per agent, not left to default.

### G — Documentation and discoverability

- Every agent and skill has a README-level entry that a new operator
  can read cold and understand.
- Trigger phrases are explicit so semantic match works.

## The wave methodology

A-grade is rarely reached in a single refactor. The path goes through
**waves**: each wave targets one or two categories, has a measurable
success metric, and a verification gate.

For the full methodology — wave principles, the wave shape, bespoke
probes vs full integration tests — see
[references/wave-methodology.md](references/wave-methodology.md).

## The verification gate

Bespoke probe per wave; full integration test per phase. A wave is
"done" when its primary metric measurably improved. A phase is "done"
when the full integration test (the fleet running an end-to-end
mission) passes.

## When to add a new wave mid-plan

If during execution a finding surfaces that a scheduled wave can't
absorb, add a new wave. Don't stuff findings into the wrong wave;
the metric will get muddled. Adding a wave is cheaper than delivering
a confused wave.

If a wave's metric proves inadequate (passing it didn't actually move
the grade), revise the metric. Don't declare victory on a metric that
doesn't measure what mattered.
