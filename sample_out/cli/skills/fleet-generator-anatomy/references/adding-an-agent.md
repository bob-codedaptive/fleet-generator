# Adding an Agent

Agents are spawnable subagents. Each role becomes one entry in the
`ROLES` array. The wizard renders one card per role. The zip ships
one `.md` manifest per enabled agent.

## Where an agent lives

1. **`ROLES`** array (in CONSTANTS section near the top)
2. Its rows in `ROSTER`, `EFFORT`, `PROFILE` and `HAIKU_KEEP`, and in
   `F_FREE` if it has steps that need no approval
3. (Optional) Update the maintenance core in `fillStateForMaintenance`
   if this agent should be enabled by default in Quick Start

## Step-by-step

### 1. Add the role definition

Open `fleet-generator.html`. Find the `ROLES = [` array. Each entry
looks like:

```js
{ key: 'postflight', name: 'Marvin', title: 'Post-flight Inspector', required: false,
  tools: READ_TOOLS,
  persona: "Blunt, exact, unimpressed by a green suite. ...",
  role: "Post-flight reviewer for fleet-generator. Read-only. ...",
  does: ["Read the diff against the mission ...", ...],
  notDoes: ["Edit code or write the fix: rework is the worker's, ...", ...],
  skills: ["gate-procedures","communication"],
  load: ["blast-radius","diagnosing-bugs"],
  descLine: "Post-flight reviewer. Read-only. ... Use after the worker's final commit." }
```

Add a new entry following the same shape. Pick:

- **`key`** — kebab-case identifier (used internally only)
- **`name`** — default agent name (the user can override in the wizard)
- **`title`** — role title shown in the UI and manifest
- **`required`** — `true` for orchestrator/worker, `false` for everyone else
- **`persona`** — up to 1024 characters. Voice, tone, judgment.
- **`role`** — 1–2 sentences placing the agent in the project
- **`does` / `notDoes`** — concrete bullet lists
- **`tools`** — `READ_TOOLS` for a read-only role; add Edit and Write for a writer, Agent for one that starts others
- **`skills`** — preloaded; keep it to what the role cannot start without, and make sure none disagrees with the role
- **`load`** — skills named for loading on demand
- **`descLine`** — frontmatter description: what it does, then "Use when ...". No "MUST BE USED": newer models over-trigger on it
- **Every rule in `notDoes` carries its reason** after a colon: Fable and Opus apply a bare "never" further than meant

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
