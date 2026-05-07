---
name: source-of-truth
description: >-
  Designate canonical documents on fleet-generator. When canonical sources conflict with other information, the canonical document wins.
when_to_use: >-
  Asking which doc is authoritative. Designating a canonical document. Resolving a conflict between two docs. Trigger phrases: source of truth, canonical, authoritative, locked decision, canon, which doc wins.
status: active
tags: [skill]
updated: 2026-05-07
---

# Source of Truth

Some documents are authoritative. When they conflict with other
information, the canonical document wins.

## How to designate a canonical document

In `CLAUDE.md`, under "Locked Decisions":

```markdown
## Locked Decisions

- `docs/architecture/auth.md` — canonical authentication design.
  Conflicts with this doc must update this doc, not the conflicting
  source.
- `schemas/user.json` — canonical user schema.
```

## How agents use canonical sources

1. Before starting work that depends on the design, read the
   canonical doc
2. If implementation contradicts the canonical doc, stop and ask
3. Canonical docs are updated only with explicit human approval
4. Updates land in the same commit as the implementation that
   reflects them — see `documentation-rev`

## Anti-pattern: drift

Canonical doc says X. Code does Y. Both ship for two months. By
month three, nobody remembers which one was right. The doc gets
called "out of date" and ignored. Drift is how canon dies.

Prevention: when an agent notices canon and code disagree, stop and
ask. Do not silently update the code to match outdated canon, and do
not silently update canon to match drifted code. Resolve with the
human.

## Anti-pattern: implicit canon

A doc that everyone treats as authoritative but isn't marked as
such. New agents don't know to read it. The agent who wrote it has
forgotten which version is current.

Prevention: if it's authoritative, mark it. If it's not, don't treat
it as such.

## Examples

See [references/examples.md](references/examples.md) for two
real-world canon-conflict scenarios.
