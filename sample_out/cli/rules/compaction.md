---
status: active
tags: [rules, always-applies, compaction, fleet-wide]
---

# Compaction Survival — What the Compactor Must Preserve

Claude Code's automatic compaction summarizes older messages to free
context space. `CLAUDE.md` content and rules survive compaction
intact (re-injected every request). Mission instructions delivered as
initial prompt content do NOT — they get summarized, and specific
details (line numbers, symbol names, file lists) can be lost.

This rule tells the compactor what to preserve verbatim when
summarizing mission context. It loads on every session via the rules
mechanism, so it is always present.

## Summary instructions

When summarizing this conversation for compaction, always preserve
verbatim:

- The mission title and any mission ID
- The complete "Files to Modify" list / table
- The complete "Files NOT to Modify" list
- The complete "Blast Radius Scope" section, including all symbol names
- Any architectural-review verdicts and binding conditions
- The current implementation Part number and its `→ verify:` line
- The most recent test-runner exit code and pass count
- Any RESCOPE_REQUIRED or MUST_UPDATE items from the Blast Radius Report
- The exact commit-message format from the mission
- The branch name and worktree path

## Recovery after compaction

If implementation details from a mission Part have been summarized
away, **re-read the mission file from disk** before continuing. Do
not guess at details that were in the mission — the file is at
`.claude/active-mission.md` (or wherever the mission lives).

## Why this rule exists

Without explicit preservation instructions, the compactor treats all
prompt content as equally summarizable. A mission's file list can
become "working on several files" and the blast radius scope can
become "modifying some symbols." Both are useless for continuing
implementation. This rule is the highest-impact, lowest-risk
improvement to compaction resilience.
