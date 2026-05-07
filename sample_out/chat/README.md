# Chat Skills

Drag any of the `.zip` files in this folder into claude.ai →
**Settings → Capabilities → Skills**. Multi-select works for bulk
install.

## Always shipped

- `scope.zip` — investigation / planning mode
- `draft.zip` — specification writing mode
- `submit.zip` — prepare mission for CLI launch
- `communication.zip` — communication preferences
- `bootstrap.zip` — fresh-chat onboarding flow
- `continuity.zip` — cross-session handoff packets

## Optional (selected in wizard)

- `notebooklm-prep.zip`
- `memory-interface.zip`

Each zip contains `<name>/SKILL.md` plus, for some, a `references/`
folder for progressive disclosure.

## How the modes work

- `/scope` is for thinking. Read-only. Discuss the design. Don't write code yet.
- `/draft` is for writing the spec. Output goes into artifacts so the work survives compaction.
- `/submit` formats the spec for launch and tells you the exact CLI command to run.

Each mode ends every response with a footer like
`[MODE: SCOPE]` so you can tell which is active.
