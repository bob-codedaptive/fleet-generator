---
name: dispatch-doctrine
description: >-
  An orchestrator dispatches, monitors, corrects and steers. Writing the code itself is the failure of that job, not a shortcut to it.
when_to_use: >-
  An orchestrator is about to write code. Deciding whether work should be dispatched or done inline. Writing a brief for a dispatched unit. A dispatched unit came back wrong.
status: active
tags: [skill]
updated: 2026-11-12
---

# Dispatch doctrine

Judgment is yours. Typing is not.

**When two or more units have disjoint file sets, dispatching is
mandatory.** Not preferred. A task with eight files across five parts is a
fan-out, and writing it yourself is a doctrine violation regardless of how
well it turns out.

The reviewer judges YOU, not the workers. A unit that comes back wrong is
your brief being wrong.

You may write code yourself in one case: a worker has botched the same
unit badly or repeatedly, and a corrected brief has already failed. Not
because it is faster, not because the change is small, not because you can
see the fix. Log every instance with the reason a re-dispatch did not
work.

## A brief carries content, not process

A brief is: the working directory and base commit; the ruling and why;
verified facts with file:line anchors; what to build; what is out of
scope; what to return.

It is NOT the dispatch doctrine, the commit rules, the test discipline, or
the safety rules. The agent file already carries those. Restating them
spends the unit's context before it starts and teaches it nothing.

This is expensive when you get it wrong. In one incident four workers each
carried a full lifecycle their agent file already specified, and two burned
their entire budget without writing a line of code.

## Brief content decides the output

Measured across eight parallel implementations of one identical task: the
one whose brief named a specific protocol three times conformed to it; the
one whose brief named a different protocol twenty times conformed to THAT
one instead and lost the ability to assert on structure.

Name the conformances, the boundary cases, and the exact wrong answers you
are guarding against. A dispatched unit starts with none of your context.
The brief is the whole world it gets.

## Pass the agent name only. Never pass `model`.

The agent file is the model picker. A gate runs on the model its
frontmatter names because the file says so. A `model` argument on the
dispatch call **overrides the file**, and the bare aliases are traps —
`sonnet` is not a model, it is an alias that resolves to whatever the
harness currently maps it to, which may be a model your fleet does not run.

Measured: one coordinator passed `model: 'sonnet'` on five dispatches
and every gate and coder in the wave ran on the wrong model while every pin
said otherwise. The suites passed. Nobody noticed until a token audit.

A hook refuses this if you enable it, because the doctrine alone was not
enough — the coordinator that did it had read the rule.

## Verify a fact before you anchor it

A file:line reference that has moved sends the unit somewhere wrong with
total confidence. Check it against the file, not against your memory of
the file.

## Review every returned diff

A green suite is not evidence. Three crash bugs shipped from units whose
own tests passed, all found by reading the diff rather than running it.

Re-dispatch a wrong unit once with a corrected brief before fixing it
yourself. The brief was probably the problem.
