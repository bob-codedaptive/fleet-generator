---
name: diagnosing-bugs
description: >-
  Build a feedback loop that fails on the bug before forming any theory. Adapted from mattpocock/skills (MIT).
when_to_use: >-
  A bug is reported. A test fails intermittently. Behaviour differs between environments. You are about to guess at a cause.
status: active
tags: [skill]
updated: 2026-11-12
---

# Diagnosing bugs

## Build the failing loop first

Before reading code to build a theory, get a command that fails on this
bug, reliably, in under a few seconds.

If you catch yourself reading code to form a hypothesis before that
command exists, stop. Jumping to a hypothesis is the exact failure this
prevents.

A real example: a rebase was reported as "FAILED with conflicts" and an
operator spent an hour hunting merge conflicts that did not exist. The
cause was a missing binary on PATH. Nobody had run the rebase and looked.

## Then rank hypotheses, and make them falsifiable

Write three to five candidate causes before testing any of them. For each,
state what you would observe if it were true and what you would observe if
it were not.

Anchoring on the first plausible cause is the most common way a diagnosis
goes wrong, and it is invisible from inside: the first theory always feels
sufficient.

## Tighten the loop as you go

A loop is a product, not a prerequisite. Faster, sharper, more
deterministic. Every second you remove you pay back on every iteration.

## Report what you observed

"This looks wrong" is a guess wearing a fact's clothes. "Input X produced
exit 133" is a fact. Report the file, the exit code, the last line of
stderr.

Distinguish a content problem from an environment problem from a
bookkeeping problem. Most stubborn bugs are the last two.
