---
name: blast-radius
description: >-
  Pre-flight protocol for missions that modify, remove, rename, or alter the semantics of existing symbols on fleet-generator. Documents call-site impact and required updates BEFORE code changes are made.
when_to_use: >-
  Mission renames or removes a symbol. Mission changes a function signature. Mission deprecates a method. Mission alters schema fields, enum cases, or shared constants. Trigger phrases: blast radius, MUST_UPDATE, INTENTIONALLY_LEFT, RESCOPE_REQUIRED, rename, signature change, symbol removal, deprecation, migration, orphan deprecation, bridge helper, partial migration, call sites.
status: active
tags: [skill]
updated: 2026-05-07
---

# Blast Radius Discipline

Right the first time, every time. A partial migration is worse than
a delayed migration.

## When this skill applies

Before the worker makes any change to existing code that modifies,
removes, renames, deprecates, or alters the semantics of a symbol
that may be referenced elsewhere. Specifically, any of:

- Renaming a type, function, parameter, or field
- Changing a function signature (parameters, types, return)
- Removing a property, parameter, accessor, or case
- Adding deprecation annotations
- Changing semantics even when the signature is preserved
- Modifying schema, persistence, or canonical constants

Does NOT apply to purely additive changes: new files with no
references yet, new private helpers, formatting, comment-only edits.

If uncertain whether a change triggers this skill — it does. Run the
protocol.

## The protocol — five steps

### Step 0: Establish the baseline

Before writing any production code:

```bash
# Run the test suite. Capture the pass count.
<your-test-runner> 2>&1 | tail -5
```

If tests don't pass at mission start, STOP. Tests must pass at the
baseline. Fix in a separate mission first.

### Step 1: Identify every symbol being changed

For each symbol the mission will modify:
- Full path
- Change class: rename / signature / removal / deprecation / semantic
- Scope: public / internal / private

### Step 2: Grep exhaustively

For each symbol, grep across all of: production code, tests, docs,
configs, comments. See [references/grep-recipes.md](references/grep-recipes.md)
for language-specific patterns.

For renamed symbols, grep BOTH old and new names to confirm the old
has no surviving references.

### Step 3: Classify every hit

Every grep hit gets one of three classifications:

- **MUST_UPDATE** — uses the symbol; must change to match
- **INTENTIONALLY_LEFT** — false positive OR legitimate non-update.
  Requires written justification.
- **RESCOPE_REQUIRED** — must update, but doing so expands the
  mission beyond its sanctioned scope. **The mission stops.** Surface
  to the human with a rescope request.

The RESCOPE_REQUIRED classification is the escape valve. The wrong
move is to silence the issue with a bridge or shim — see
[references/anti-patterns.md](references/anti-patterns.md).

### Step 4: Write the Blast Radius Report

Commit it to `docs/blast_radius/<mission-id>_BLAST_RADIUS.md` as
the FIRST commit of the work, before any production change. Use the
template in [references/report-template.md](references/report-template.md).

### Step 5: Implement — every MUST_UPDATE site must be touched

When implementation begins, every file listed as MUST_UPDATE must
appear in the final diff. Garfield verifies this in post-flight.

## The rule

If a change to symbol X has any effect on other code that reads or
writes X, every such call site is in scope. There is no
"pre-existing, out of scope" escape hatch for call sites of the SAME
symbol.

If the mission cannot cover all call sites, the mission rescopes —
it never ships partial.
