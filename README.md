# fleet-generator

A browser wizard that generates a working agent fleet for Claude Code or
Codex. One HTML file, no install, no build step. Open it, answer some
questions, download a zip.

**Now with [MOOTx01](https://github.com/codedaptive/mootx01-ce) integration:**
an optional persistent-memory layer so a session can hand its own work to
the next one.

The output is a `.claude/` directory containing agent definitions, skills, hooks,
settings, and an install script. Drop it in a repository and the agents are
there next time you start a session.

## Why a fleet rather than one agent

A single agent doing everything is the default, and it is the expensive
way. It holds the whole task in one context, reasons about all of it at the
top tier, and types every line itself.

A fleet splits that into three roles:

- an **orchestrator** decomposes the work and dispatches it
- **workers** implement one unit each, from a brief
- a **reviewer** judges the orchestrator's output before it lands

The split is not organisational tidiness. It is what makes the work
cheaper and better at the same time: the units run on a smaller model, they
run in parallel, and nothing merges without something that did not write it
having looked.

**The orchestrator writing the code itself is the failure of that job, not
a shortcut to it.** Measured across live runs, orchestrators that dispatched
their implementation work ran about 64% of tokens in subagents.
Orchestrators that typed it themselves ran 0 to 32%, and cost three to four
times as much for comparable work.

## What you get

| | |
| --- | --- |
| **Agents** | Role definitions with tools, model, and skills, in the shape your target reads |
| **Skills** | The doctrine each role loads on demand, rather than carrying always |
| **Hooks** | Shell hooks for scope enforcement, push gating, and logging |
| **Commands** | Slash commands for the workflows you picked |
| **Settings** | `settings.json` wired to the hooks |
| **Install script** | Puts it all in place |

## Getting started

Open `web/fleet-generator.html` in a browser. Nothing is uploaded; the
whole thing runs locally.

`web/GUIDE.html` walks the wizard end to end, including three install
paths depending on how much you want to decide up front. `sample_out/`
holds a full generated bundle if you would rather read the output before
running anything.

## Two choices worth understanding before you generate

### Target

Claude Code reads a `.claude/` directory. Codex reads an `AGENTS.md` at the
repository root. The doctrine is identical either way, so this is a
packaging choice rather than a different fleet.

Picking **Both** emits both entry points from one source, and the
`AGENTS.md` states that the skill files are authoritative. Two
descriptions of one fleet drift the moment either is edited, and saying
which one wins is cheaper than reconciling them later.

### Model tiers

The generated fleet does not put every agent on one model.

| Role | Tier | Why |
| --- | --- | --- |
| Reviewer | top | One pass over a finished diff. Cheap, and the only thing between a plausible-looking change and your main branch. |
| Orchestrator | top | Pays for itself *if* it dispatches. If it types the code itself, this is the most expensive possible arrangement. |
| Workers | mid | They receive a brief containing everything they need, so capability buys less here than anywhere else. |

**A model class implies an agent-file shape.** Keep two variants of the
orchestrator: the full procedural file for the smaller model, and a lean
one for the capable model. Measured on one identical task across eight
configurations, the lean file halved the cost of the capable model and
passed, while making every smaller model more expensive and no better.

Running a capable model against the full procedural file is the most
common setup error. It reads as the safe choice and it is not: the model
spends context on scaffolding it does not need, has less left for the work,
and starts doing the work itself rather than dispatching.

Edit `MODEL_TIERS` near the top of the wizard's script block to change the
defaults.

## Optional: persistent memory

A checkbox adds a compact ritual for
[MOOTx01](https://github.com/codedaptive/mootx01-ce): `/prepare-for-compact`,
`/start-clean`, and `/recover-from-compact`. The commands need MOOTx01
installed; leave the box unchecked if you are not running it. The agent writes its own
handoff before context runs out, and the next session reads it back.

The `handoff` and `plan-capture` skills ship regardless. They are written
against "your memory system", so they work with any store and are better
with a real one behind them.

## Repo layout

```
fleet-generator/
├── web/
│   ├── fleet-generator.html   # the wizard: this is the product
│   ├── GUIDE.html             # how to use it, end to end
│   ├── SPEC.md                # how it is built, for editing it
│   └── archive/
├── sample_out/                # a full generated bundle, for reading
├── src/fleet_generator/       # Python scaffold, reserved, currently empty
├── pyproject.toml
└── README.md
```

## Editing the wizard

Everything lives in `web/fleet-generator.html` as JavaScript constants:
`ROLES` for the agents, `CLI_SKILLS` and `OPTIONAL_CLI_SKILLS` for skill
bodies, `OPTIONAL_HOOKS` for hooks, `MODEL_TIERS` for the tiers. There is
no separate source tree: the constants are the source.

`web/SPEC.md` documents the structure and what has to agree with what when
adding a skill or a hook.

`sample_out/` is a snapshot rather than generated output, so it drifts when
the wizard changes and needs a deliberate refresh.
