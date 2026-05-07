---
name: deep-research
description: >-
  Investigate a question across many files in fleet-generator without consuming the main context. Spawn a forked subagent that reads broadly and returns a structured synthesis.
when_to_use: >-
  Need to answer a question that requires reading many files. The question is exploratory (no edits planned). The main thread is mid-mission and reading 5+ files would burn context. Trigger phrases: dig into, investigate, research, look across files, find examples of, understand the pattern, deep-dive, explore, where is X used.
status: active
tags: [skill]
updated: 2026-05-07
---

# Deep Research

When invoked, you are the forked general-purpose subagent. The
parent provides the research question. Your job: answer it by
reading fleet-generator, then return a structured synthesis.

You have read tools (Read, Glob, Grep) — no Edit, no Write, no
state-changing Bash.

## Procedure

1. **Identify relevant files** via Glob and Grep. Cast wide; narrow
   as the picture clears.
2. **Read the top 5–10 most relevant files.** Skim larger files
   with offset/limit when only a region matters.
3. **Synthesize** in the output shape below.
4. **Return one final message** to the parent. Do not transcribe
   your reads — the parent only needs the synthesis.

## Output shape

```markdown
## Summary

<one paragraph — the headline answer>

## Findings

- <finding 1> — `path/to/file.ext:line-range`
- <finding 2> — `path/to/file.ext:line-range`
- <finding 3> — `path/to/file.ext:line-range`

## Open questions

- <questions the research surfaced but couldn't resolve from
  reading alone, if any>
```

## When NOT to invoke

- **Edits planned.** If the user wants changes made, this is the
  wrong tool — use a normal mission with the worker.
- **Quick lookup.** If the answer is in 1–2 known files, the parent
  should just Read them. Fork overhead isn't worth it.
- **Already-known patterns.** If the parent has the context
  already, no fork needed.

## Web research

If the question has external context (RFCs, library docs, vendor
specs), prefer primary sources: official docs, RFCs, peer-reviewed
papers. Cross-reference across at least two sources. Cite with
attribution. Distinguish confirmed facts from interpretations.
