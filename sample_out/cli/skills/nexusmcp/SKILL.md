---
name: nexusmcp
description: >-
  Persistent AI memory across sessions for fleet-generator, via NexusMCP — temporal knowledge graph, diary entries, fact recording with invalidation.
when_to_use: >-
  Recording a decision. Querying prior context. Writing a session summary. Recovering from compaction. Trigger phrases: remember this, recall, persistent memory, nexus, knowledge graph, diary, prior decisions, what did we decide.
status: active
tags: [skill]
updated: 2026-05-07
---

> **PREVIEW — NexusMCP launches soon.** This skill describes how the
> agent uses NexusMCP for cross-session memory. The MCP server is not
> yet available; calls silently no-op until it ships. No regeneration
> is needed when NexusMCP lands — the skill body is already complete.

# Persistent Memory (NexusMCP)

NexusMCP provides temporal knowledge graph memory across sessions
for fleet-generator. The mental model: a working memory the agent reads
at session start, writes at session end, and queries on demand.

## At session start

```
nexus_search("project name keywords")
nexus_diary_read(limit=5)
```

Goal: load enough context to continue prior work without asking the
human to repeat history.

## During work

When the agent learns a fact that future sessions will need:

```
nexus_kg_add(
  subject="auth.passwordReset",
  predicate="uses",
  object="bcrypt",
  reason="performance audit 2026-04-12"
)
```

When a fact stops being true (refactor, redesign):

```
nexus_kg_invalidate(fact_id="...", reason="migrated to argon2")
```

## At session end

Write a diary entry summarizing what changed:

```
nexus_diary_write(
  topic="auth-refactor",
  entry="Migrated password hashing to argon2. Old bcrypt path removed."
)
```

## Filesystem-vs-palace precedence

When the palace says one thing and the filesystem says another, the
filesystem wins. Use the palace as a hint about what was true at a
point in time, not as ground truth right now.

If a palace fact contradicts current code, invalidate the fact
rather than acting on it.

## When NexusMCP is not connected

Skip memory operations silently. The agent should still function
without persistent memory — it just won't remember across sessions.

## Tool reference

For the full tool list and parameter shapes, see
[references/tool-reference.md](references/tool-reference.md).
