---
name: canonical-skill-source
description: >-
  MANDATORY before writing ANY agent system content on fleet-generator — manifests, skills, rules, hooks, settings. Enforces the single canonical source location and the one-way deployment direction.
when_to_use: >-
  Writing a SKILL.md, creating an agent manifest, adding a rule file, adding a hook script, modifying .claude/ contents. Trigger phrases: add a skill, create a rule, new agent, update the manifest, canonical source, single source of truth, sync, deploy agents.
status: active
tags: [skill]
updated: 2026-05-07
---

# Canonical Skill Source

The one rule that prevents the most damage.

## The rule

**ALL agent system content for fleet-generator is authored at ONE
location.**

Pick a canonical source location for the project — typically a
directory in the docs / fleet-source repo, separate from the deployed
`.claude/` directories. Examples:

- A dedicated repo: `fleet-source/`
- A subdirectory of the project: `fleet/agents-source/`
- The wizard's output, kept in version control: `fleet-package/`

Whatever you pick, write it down in `CLAUDE.md` under "Locked
Decisions" and don't move it without explicit human approval.

## Authoring surfaces (canonical) vs deployment surfaces

| Surface | Role |
|---|---|
| Canonical source (e.g. `fleet-source/`) | Where you AUTHOR. Edit here. |
| `.claude/agents/` etc. in each repo     | Deployment target. Don't edit. |

Product / project repos' `.claude/` directories are deployment
targets, **not authoring surfaces**. Writing directly to `.claude/`
in a repo bypasses the deployment pipeline and creates silent
divergence between repos.

## The deployment pipeline

```
fleet-source/                  →  each repo's .claude/
  ├── agents/                  →    .claude/agents/
  ├── skills/                  →    .claude/skills/
  ├── rules/                   →    .claude/rules/
  └── hooks/                   →    .claude/hooks/
```

Direction: one-way (canonical source → deployment).
Idempotent: re-running with no changes produces zero diff.

## Before you write

Ask yourself:

1. Am I writing to the canonical source location? → Proceed.
2. Am I writing to a repo's `.claude/` directly? → STOP. Write to
   the canonical source instead, then deploy.
3. Am I creating a new skill? → Create it at
   `<canonical>/skills/<name>/SKILL.md`, then deploy.

## Why this rule exists

Without a canonical source, agent content scatters across repos.
Two repos drift apart. A skill exists in one but not the other.
Nobody remembers which version is current. The fleet becomes a hydra.

The fix is simple: never write to `.claude/` directly. Always write
to the canonical source and let the deployment distribute.

## Exceptions

None. There are no exceptions to this rule.
