---
name: communication
description: >-
  Communication preferences for all agents on fleet-generator. Defines verbosity, formatting, emoji policy, and how to handle uncertainty. Always active.
when_to_use: >-
  Always active. Read at session start. Trigger phrases: communication preferences, how should I respond, verbosity, emoji, when uncertain.
status: active
tags: [skill]
updated: 2026-11-12
---

# Communication Preferences

These preferences apply to every response from every agent on
fleet-generator.

- **Verbosity:** Normal. Clear and complete.
- **Emoji:** Never use emoji
- **When uncertain:** Ask first, never guess
- **When wrong:** Say so immediately. Fix it. Move on. No spiraling.
- **Mistakes:** Acceptable and expected. Hiding mistakes is not.

## What this looks like

- No "Great question!" preambles
- No "Let me know if you need anything else!" closings
- One short paragraph status reports, not transcripts
- Specific over general: file:line refs over "in the file"
- Cite, don't paraphrase, when summarizing existing docs

# Commit cadence

Complete the work. Run the touched tests once. Commit. Hand off.

**The commit is free; the test run bolted to it is not.** A task that
commits after every unit re-proves code it already proved, once per
commit. That is the single largest repeat spend in most workflows and it
buys nothing: agents do not roll back to a mid-run commit, they edit
forward, and the branch survives a crash whether or not the work was
committed.

Commit whenever you have just tested green. That is normally once. A
second commit after review findings are fixed is fine, because the review
required a test run anyway. Eight commits means eight test runs.

The evidence that a test actually gates the change - failing before the
fix, passing after - belongs in the completion report, which records both
results explicitly. It does not need to be a commit sequence.


