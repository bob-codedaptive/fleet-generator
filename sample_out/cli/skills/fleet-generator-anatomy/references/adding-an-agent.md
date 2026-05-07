# Adding an Agent

Agents are spawnable subagents. Each role becomes one entry in the
`ROLES` array. The wizard renders one card per role. The zip ships
one `.md` manifest per enabled agent.

## The three-place pattern

1. **`ROLES`** array (in CONSTANTS section near the top)
2. The `descLine` field — one paragraph for the manifest description
3. (Optional) Update the maintenance core in `fillStateForMaintenance`
   if this agent should be enabled by default in Quick Start

## Step-by-step

### 1. Add the role definition

Open `fleet-generator.html`. Find the `ROLES = [` array. Each entry
looks like:

```js
{ key: 'reviewer', name: 'Garfield', title: 'Reviewer', required: false,
  persona: "Meticulous and unsparing. ...",
  role: "Post-implementation reviewer for fleet-generator. ...",
  does: ["Review diffs against the mission spec", ...],
  notDoes: ["Modify any files", ...],
  skills: ["self-review","blast-radius","mission-template","safety-rules"],
  descLine: "Post-flight reviewer. Read-only. ... MUST BE USED after every code mission. Use PROACTIVELY when ..." }
```

Add a new entry following the same shape. Pick:

- **`key`** — kebab-case identifier (used internally only)
- **`name`** — default agent name (the user can override in the wizard)
- **`title`** — role title shown in the UI and manifest
- **`required`** — `true` for orchestrator/worker, `false` for everyone else
- **`persona`** — up to 1024 characters. Voice, tone, judgment.
- **`role`** — 1–2 sentences placing the agent in the project
- **`does` / `notDoes`** — concrete bullet lists
- **`skills`** — auto-load list referenced in the manifest
- **`descLine`** — frontmatter description with "MUST BE USED" / "Use PROACTIVELY" cues

### 2. Verify

Open the HTML. The new card should appear on Step 4 (Team) with the
right name and title. Toggle it on, walk through to download, unzip,
confirm `cli/agents/<name>.md` exists with the right content.

```bash
node --check /tmp/fc.js     # JS still parses
node /tmp/fleet_e2e_v2.mjs   # full smoke test
```

### 3. Commit

```
feat(generator): add <name> agent (<title>)
```
