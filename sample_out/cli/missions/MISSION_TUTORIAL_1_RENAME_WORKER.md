# Mission: Tutorial 1 — Rename Your Worker

> **Tutorial.** First in the workshop ladder. Teaches where `ROLES`
> lives in fleet-generator.html and how the wizard reads it.

## Context

Your fleet-generator ships with a default worker named `Woodstock`.
You'll change that default to a name you pick. The change is small;
the goal is to learn where role definitions live and how the wizard
turns them into agent manifests.

When you finish, opening the HTML in a browser shows your new
default in the wizard's Step 4 (Team).

## Read First

- `.claude/skills/fleet-generator-anatomy/SKILL.md`
- `.claude/skills/fleet-generator-anatomy/references/adding-an-agent.md`

## Files to Modify

| File | Change |
|---|---|
| fleet-generator.html | Update the `worker` entry in the `ROLES` array — change `name` and `persona` |

## Files NOT to Modify

- `.claude/**`
- `GUIDE.html`

## Implementation Parts

### Part 1 — Pick a new worker name

Decide on a name. Anything works (`Sparky`, `Otis`, `Mochi`,
`Patches`). Write it down. Optional: pick a short persona blurb
(2–3 sentences).

### Part 2 — Find the worker role

Open `fleet-generator.html`. Search for `key: 'worker'` (around
the `ROLES` array near the top of the script section).

The entry looks like:

\`\`\`js
{ key: 'worker', name: 'Woodstock', title: 'Code Worker', required: true,
  persona: "Thorough and methodical. ...",
  ...
}
\`\`\`

### Part 3 — Edit the name (and optionally the persona)

Change the `name` value to your pick. Optional: replace the persona
string with one that matches your worker's voice.

**Commit:** `feat(generator): rename default worker`

→ verify: open `fleet-generator.html` in a browser; on Step 4 the
  worker card shows your new default name; download a fleet and
  inspect `cli/agents/<your-name>.md` to confirm the manifest's
  `name:` and persona match.

## Test Requirements

Visual inspection of the wizard plus a generated manifest is enough
for this tutorial. No unit-test harness exists for the HTML.

## Verification

1. Open `fleet-generator.html` in a browser
2. Walk to Step 4 (or click Quick Start)
3. The worker card shows your new name
4. Download a fleet, unzip, open `cli/agents/<your-name>.md`
5. Persona matches what you wrote

## Success Criteria

- [ ] `ROLES` worker entry has the new name
- [ ] (optional) persona updated to match
- [ ] Wizard shows the new default
- [ ] Generated manifest matches
- [ ] One commit landed

## Next

When this lands, run Tutorial 2 (`MISSION_TUTORIAL_2_ADD_SKILL.md`)
to add a custom skill.
