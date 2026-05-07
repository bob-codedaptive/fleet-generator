# fleet-generator — fleet-generator workshop

This is your personal workshop for maintaining a copy of
`fleet-generator.html`. The HTML in this folder is yours to edit
over time. The agent team in `cli/` knows how to help.

## What's inside

- **`fleet-generator.html`** — your editable copy of the generator
- **`GUIDE.html`** — the documentation for end users (best-effort copy)
- **`cli/`** — Claude Code agent team for editing the generator
  - Includes the `fleet-generator-anatomy` skill that documents the
    file's structure
  - Tutorial ladder: `MISSION_TUTORIAL_1_RENAME_WORKER.md`,
    `MISSION_TUTORIAL_2_ADD_SKILL.md`, `MISSION_TUTORIAL_3_ADD_HOOK.md`
  - Audit mission: `MISSION_SELF_AUDIT_GENERATOR.md`
- **`chat/`** — chat skills you upload to claude.ai
- **`install.sh`** — wires the CLI side into this folder's `.claude/`

## First-time setup

```
cd <this-folder>
git init                          # if not already a repo
bash install.sh .                 # installs into ./.claude/
```

The installer creates `.claude/agents/`, `.claude/skills/`,
`.claude/rules/`, `.claude/hooks/`, and `.claude/missions/`
inside this folder.

## Install the chat side

Drag every `.zip` from `chat/` into claude.ai → Settings →
Capabilities → Skills (multi-select supported).

## Get started

Open `fleet-generator.html` in a browser. That's the tool you'll
edit. To see what end users see, also open `GUIDE.html`.

Run the tutorial ladder in order to learn the file structure:

```
claude --agent woodstock --model opus --dangerously-skip-permissions
# paste cli/missions/MISSION_TUTORIAL_1_RENAME_WORKER.md
```

When all three tutorials are done, run `MISSION_SELF_AUDIT_GENERATOR.md`
periodically to grade your fork against the rubric and propose the
next improvement wave.

## Note on GUIDE.html

If `GUIDE.html` isn't in this folder, the browser running the
generator couldn't fetch it (file:// CORS or it was missing). Copy
it manually from wherever you got the original, or it'll be in any
zip your generator produces.
