---
name: model-tiers
description: >-
  Which model runs which role, at what effort, and why each model gets its own version of an agent file. The measured roster, the per-model differences, and the lessons behind them.
when_to_use: >-
  Setting up a fleet. Changing the model a role runs on. A role behaves differently after a model change. Costs are higher than expected. A reviewer stops early, a coder adds work nobody asked for, or an orchestrator types the code itself.
status: active
tags: [skill]
updated: 2026-11-12
---

# Model tiers

Each role runs on one model, chosen for that role, and its agent file is
written for that model. Moving a role to another model means generating
its file again, not editing the model line: the text changes too.

## The default roster

Measured on the fleet this is modelled on. The Claude column is the
default; the OpenAI column is what the same role ran on when it ran on
GPT.

| Role | Claude (default) | OpenAI |
| --- | --- | --- |
| Orchestrator | Claude Opus 5.5, medium | GPT-6.1 Sol, xhigh |
| Coordinator | Claude Opus 5.5, medium | GPT-6.1 Sol, xhigh |
| Code Worker | Claude Opus 5.5, medium | GPT-6.1 Sol, high |
| Pre-flight Scanner | Claude Haiku 5.5, medium | GPT-6.1 Terra, medium |
| Post-flight Inspector | Claude Haiku 5.5, medium | GPT-6.1 Terra, high |
| Submission Gate | Claude Haiku 5.5, high | GPT-6.1 Sol, high |
| Architect | Claude Opus 5.5, medium | GPT-6.1 Sol, high |
| Last-resort Coder | Claude Opus 5.5, xhigh | GPT-6.1 Sol, max |
| Numeric Specialist | Claude Opus 5.5, xhigh | GPT-6.1 Sol, xhigh |
| Root-cause Investigator | Claude Opus 5.5, medium | GPT-6.1 Sol, high |
| Visual Consistency Reviewer | Claude Sonnet 5.5, medium | GPT-6.1 Sol, medium |
| Doc Writer | Claude Sonnet 5.5, medium | GPT-6.1 Sol, medium |
| Security Reviewer | Claude Haiku 5.5, high | GPT-6.1 Sol, xhigh |
| Accessibility Reviewer | Claude Sonnet 5.5, medium | GPT-6.1 Sol, medium |
| Performance Reviewer | Claude Sonnet 5.5, medium | GPT-6.1 Sol, medium |

Why these:

- The seats that hold a mission end to end (orchestrator, coordinator,
  worker) run on Opus at medium. Raising effort bought less there than
  fixing the role text did.
- The gates run on Haiku. On a 22-review replay, Haiku at medium matched
  the reference reviewer more often than at high or xhigh, and never failed
  work the reference passed. Security at high caught 15 of 19 seeded
  defects, against 13 at medium.
- Specialists that judge prose or screens run on Sonnet at medium.
- The last-resort coder runs at the top of the effort ladder.

## Lessons that held

1. **Role text matters more than the model.** The large gains came from
   rewriting what a role says, not from moving it up a model or an effort
   level.
2. **A role and a skill it preloads must not disagree.** A reviewer told
   not to run tests, preloading a skill that said "re-run the test command
   yourself", followed both. These models follow instructions closely, so
   a contradiction is followed either way.
3. **Short prompts for small models.** Haiku with a 76k-character reviewer
   prompt agreed with the reference on 17 of 21 reviews; with the short
   one, 19 of 21, at a third of the cost. Haiku's files preload only what
   the role cannot start without and name the rest for loading on demand.
4. **Make small models write their checks down.** A check with no written
   result was a check skipped.
5. **Say how big a fix should be, and when FAIL is right.** "The fewest
   words that make the line true" stopped rewritten paragraphs; a written
   list of what is and is not a FAIL stopped failures on style.
6. **Effort is a lever, but measure it.** Higher was not better for every
   seat.
7. **Work with no judgement in it is a command, not an agent.** The worker
   and the coordinator run the tests themselves.

## What each model's file adds

| Model | Its file adds | Because |
| --- | --- | --- |
| Haiku 5.5 | short preload, skills on demand, written check lists, a real check before done | it skips checks and stops early on long prompts |
| Sonnet 5.5 | stop at the brief, one review, ideas first | it adds work nobody asked for, and starts its own review rounds at high effort |
| Opus 5.5 | the four bad turn endings named, look before you act, time matters | it ends long turns with a status message, and starts before reading enough |
| Fable 5.2 | the steps that need no approval, named; finishing work; writing for a reader with no context | it applies rules exactly as written and holds back what a rule does not name |
| GPT-6.1 Sol | done means shown, a tool policy, observed / inferred / unknown, evidence-first debugging | a returned tool call is not proof the action worked |
| GPT-6.1 Terra | as Sol, plus where Terra fits | it is best on scoped work with a clear check |
| GPT-6 Astra | which instruction wins, when to assume and when to ask, plain paragraphs, checks in proportion | it is sensitive to conflicting instructions, asks more and delegates less; it is not offered for the orchestrator |

Every file carries its rules with their reasons, because Fable and Opus
apply a bare "never" further than it was meant.

Sources: Anthropic's prompting guides for Haiku 5.5, Sonnet 5.5, Opus 5.5
and Fable 5.2; promptessor.com's guides for the GPT models (its Fable and
Opus guides were checked against Anthropic's and agree).

## The retry ladder

Within one model, the next try is the same model at more effort:

- Claude Haiku 5.5: Try 1 medium, try 2 high, try 3 xhigh.
- Claude Sonnet 5.5: Try 1 medium, try 2 high, try 3 xhigh.
- Claude Opus 5.5: Try 1 low (mechanical) or medium (logic), try 2 high, try 3 xhigh.
- Claude Fable 5.2: Try 1 low (mechanical) or medium (logic), try 2 high, try 3 xhigh.
- GPT-6.1 Sol: Try 1 low (mechanical) or high (logic), try 2 xhigh, try 3 max.
- GPT-6.1 Terra: Try 1 medium, try 2 high, try 3 xhigh. For logic past try 1, move to Sol.
- GPT-6 Astra: Try 1 low (mechanical) or medium (logic), try 2 high, try 3 xhigh.

First failure on a unit: a corrected brief to the same coder, because the
brief was probably the problem. Second: the root-cause investigator, then
the last-resort coder with its answer. Third: stop and return the findings.

## OpenAI models in Claude Code

A GPT model ID in an agent file needs a proxy that serves it to Claude
Code. In Codex, use the IDs directly.

## Pin the model in the file, not the dispatch

Every agent file names its model and effort. Do not pass a model on the
dispatch: it overrides the file, and the bare aliases drift with each
release.

## Read-only roles do not load writer skills

A gate reads a diff, applies one lens, reports, and stops. It never
commits, never writes prose for a human, never touches the fleet's own
configuration, so it does not need the skills that teach those things.

Measured: four such skills (commit identity, house voice, canonical-source
rules, operator working patterns) were **3,800 words loading on every
dispatch** of agents that could never use them.

## Watch the delegation number

The share of tokens spent in dispatched units rather than in the
orchestrator's own context predicts cost better than any other single
number.

Measured across live runs: orchestrators that dispatched their
implementation units ran about 64% of tokens in subagents. Orchestrators
that typed the code themselves ran 0 to 32%, and cost three to four times
as much for comparable work.

If that number is low, the orchestrator is being a typist. That is a
doctrine problem, not a model problem, and no model upgrade fixes it.
