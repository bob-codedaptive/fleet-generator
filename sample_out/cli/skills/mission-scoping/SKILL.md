---
name: mission-scoping
description: >-
  Tiered cap rule for mission scope on fleet-generator — Tier 1 primitive-touching ≤3 edits, Tier 2 UI-bounded ≤6 edits, Tier 3 net-new no cap, plus atomic exception.
when_to_use: >-
  Authoring a mission. Deciding whether a mission should be split. Pre-flight scanner verifying scope. Worker flagging RESCOPE_REQUIRED mid-mission. Trigger phrases: mission scoping, primitive-touching, Tier 1, Tier 2, Tier 3, ≤3 edits, UI-bounded, net-new, atomic exception, RESCOPE_REQUIRED, split the mission, cap.
status: active
tags: [skill]
updated: 2026-05-07
---

# Mission Scoping — Tiered Caps

A flat cap ("≤ 3 files") works for primitive-touching missions and
over-splits everything else. The tiered model keeps discipline where
it matters and removes friction where it doesn't.

## Tier 1: Primitive-touching — ≤ 3 edits

When a mission touches any primitive (a type or symbol whose blast
radius spans the codebase), the cap is **strict**: ≤ 3 edits to
existing files.

For fleet-generator, primitives include core domain types, schema
fields, public API surfaces, and shared utilities used in many call
sites. If a mission edits 3 files and one defines a primitive, the
mission is at the cap. A fourth file edit triggers RESCOPE_REQUIRED.

## Tier 2: UI-bounded — ≤ 6 files

When a mission is bounded by a single UI component cluster (a screen,
modal, or named feature) and touches no primitive, the cap is **6
files within the bounding component**.

The mission must **name the bounding component** in its scope:
- "Bounded by `SettingsScreen` and its tests"
- "Bounded by `PaymentModal` and its view-model"

Edits outside the named component count against Tier 1.

## Tier 3: Net-new — no cap

When a mission only adds new files and edits no existing file, there
is no cap. Adding 12 new files for a feature is fine.

The mission must explicitly state "all-new files, no edits to
existing code" and Garfield verifies post-flight.

## Atomic exception

When a logical change cannot be split without producing an
intermediate broken state on the integration branch, the cap doesn't
apply. The mission must include an **atomic justification** naming
why splitting would break the build.

Examples that warrant atomic exception:
- Schema migration across model + persistence + validator
- Cross-layer rename where call sites and definition must update together
- Protocol conformance change across all conformers

Examples that do NOT:
- "More convenient to do it all at once"
- "I want to keep the related changes in one PR"

## Pre-flight gate

When the orchestrator authors a mission and the pre-flight scanner
checks it, the gate is:

- [ ] ≤ 3 existing files (Tier 1), OR
- [ ] UI-bounded with named component, ≤ 6 files (Tier 2), OR
- [ ] Net-new with no edits to existing code (Tier 3), OR
- [ ] Atomic exception with explicit justification

If none, split the mission before admission.

## Mid-mission RESCOPE_REQUIRED

If the worker discovers mid-mission that the actual blast radius
exceeds the scoped tier:

1. Stop coding
2. Report the blast radius reality
3. Request RESCOPE_REQUIRED
4. The orchestrator splits the mission

## Examples

See [references/examples.md](references/examples.md) for four
worked cases.
