---
name: documentation-rev
description: >-
  Same-commit doc edit discipline for fleet-generator — every behavior-changing mission ships its doc update in the same commit series as the code change.
when_to_use: >-
  Authoring or revising a documentation file. Reviewing whether a behavior-changing mission shipped its doc edit. Bumping a doc's version. Trigger phrases: documentation rev, doc revision, same-commit doc edit, rev bump, README update, behavior-changing mission.
status: active
tags: [skill]
updated: 2026-05-07
---

# Documentation Rev Discipline

Every behavior-changing mission ships its doc update in the same
commit series as the code that changes the behavior. Forward-only.
No deltas.

## The rule

A behavior-changing mission must include a doc edit in the same
commit series. Concretely:

- Public API change → README and/or API doc updated
- New user-facing setting → user guide updated
- Schema change → schema reference updated
- New environment variable → configuration doc updated

A code commit without the corresponding doc edit is rejected at
post-flight and bounced back to the worker.

## What counts as "behavior-changing"

- New feature
- Changed UI affordance
- Renamed field
- New setting
- Altered schema
- New endpoint

What does NOT count:
- Refactor with no behavior change
- Comment cleanup
- Test additions
- Performance fixes that preserve behavior

## Same commit, same series

"Same commit" means the doc edit is in the same Part as the code
change. Not "I'll do docs at the end" — that's how docs lag behind
shipped behavior, then drift, then become wrong.

If the mission has 4 Parts, and Part 2 changes user-visible
behavior, the doc edit is in Part 2's commit. Not Part 5.

## Version bumping

For docs that carry version numbers (API references, schema docs):

| Change | Version bump |
|---|---|
| Typo, wording cleanup | No bump; update `updated:` if frontmatter has it |
| Add a rule, field, or setting | Patch bump (v1.2 → v1.2.1) |
| Multi-section rewrite | Minor bump (v1.2 → v1.3) |
| Structural change | Major bump (v1.2 → v2.0) |

See [references/version-bumping.md](references/version-bumping.md)
for examples.

## ADR discipline

Architecture Decision Records: written once, never re-opened.

Statuses: `proposed`, `accepted`, `rejected`, `superseded`.
Once accepted, the text doesn't change. Errors get corrected by a
new ADR that supersedes the old one.

## Post-flight enforcement

Garfield verifies in post-flight that any behavior-changing mission
shipped a corresponding doc edit. Missing doc edit → CRITICAL
finding → merge blocked.
