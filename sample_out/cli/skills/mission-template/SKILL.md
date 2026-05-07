---
name: mission-template
description: >-
  Standard structure for missions assigned to Woodstock — header, blast radius scope, files to modify, parts, commits, verification, success criteria.
when_to_use: >-
  Authoring or reviewing a mission file. Structuring a new mission for the worker. Asking what the worker does step-by-step during execution. Verifying whether a mission follows the template. Trigger phrases: use the mission template, structured per the mission template, mission lifecycle, mission sections, Files to Modify, success criteria, mission header, blast radius scope, write a mission, mission format.
status: active
tags: [skill]
updated: 2026-05-07
---

# Mission Template

This skill defines the structure of every mission file the worker
executes. Missions that don't follow it tend to fail at the same
predictable points.

## Required sections (in order)

```
# Mission: [Title]
## Context              — what needs to change and why
## Read First           — files / docs to absorb before coding (optional)
## Blast Radius Scope   — symbols changing (when touching existing code)
## Files to Modify      — explicit list with change descriptions
## Files NOT to Modify  — guard rails
## Implementation Parts — numbered. Each Part has commit + verify
## Test Requirements    — what to test, expected results
## Verification         — how to confirm the mission succeeded
## Success Criteria     — checklist of done conditions
```

For details on each section, see
[references/section-guide.md](references/section-guide.md).

## Per-Part structure

Each Part = one logical change = one commit.

```markdown
### Part N — [description]

[instructions, file paths, code snippets if needed]

**Commit:** `type(scope): description`
→ verify: [what to check before next Part]
```

The `→ verify:` line is required on every Part except the last
(the last Part uses the `## Verification` section).

## Worker execution order

1. Read the mission file end-to-end
2. Read any files in "Read First"
3. If "Blast Radius Scope" is present, run the `blast-radius` skill
4. For each Part: implement → run tests → run `pre-commit` → commit
5. After the final Part: run `self-review` → declare done

## What the mission does NOT contain

- Standard skill list (the worker auto-loads them)
- Worker execution order (defined here, not per-mission)
- Agent definitions or behavioral instructions
- Control-plane metadata

## Examples

See [references/examples.md](references/examples.md) for two worked
mission files: a Tier 1 primitive-touch and a Tier 3 net-new feature.

## Rules

- Every file in "Files to Modify" must appear in a Part
- No placeholders (TODO, FILL, TBD, XXX) in the final mission
- Test requirements must be specific and verifiable
- Commit messages use conventional format: feat, fix, refactor, docs,
  test, chore
