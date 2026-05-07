# Adding a Hook

Hooks fire on Claude Code events (Stop, PreCompact, SubagentStart,
PreToolUse, etc.). Each is a bash script + a settings.json entry.

## The three-place pattern

1. **`OPTIONAL_HOOKS`** array entry (wizard checkbox label)
2. **`hookScript(key)`** switch — the bash body
3. **`genSettingsJSON()`** — wires event + pattern to the script

All three must agree on the hook key.

## Step-by-step

### 1. Add wizard checkbox

In CONSTANTS, the `OPTIONAL_HOOKS` array:

```js
{ key:'log-mission-changes', label:'Log mission file changes',
  desc:'Append to ~/.claude/audit/mission-changes.log when active-mission.md changes.' },
```

### 2. Add the script body

In `hookScript(key)`, add a branch:

```js
if (key === 'log-mission-changes') return `#!/usr/bin/env bash
mkdir -p ~/.claude/audit
# ... your bash here ...
`;
```

Bash conventions:
- `set -euo pipefail` at the top
- Fail open: never block the agent on hook errors
- Audit log to `~/.claude/audit/<name>.log`
- Read stdin JSON via `jq` (with grep fallback for systems without jq)
- For PreToolUse hooks, exit 0 to allow; emit
  `{"permissionDecision": "deny", "reason": "..."}` to block

### 3. Wire settings.json

In `genSettingsJSON()`:

```js
if (state.prefs.hooks['log-mission-changes'])
  settings.hooks.push({ event:'PostToolUse', pattern:'Edit',
    command:'.claude/hooks/log-mission-changes.sh' });
```

Match the right event:
- **`Stop`** — agent finishes
- **`PostStart`** — session starts
- **`SubagentStart` / `SubagentStop`** — subagent lifecycle
- **`PreCompact` / `PostCompact`** — context compaction
- **`PreToolUse` / `PostToolUse`** — tool calls (use `pattern` to filter)

### 4. Verify

```bash
node --check /tmp/fc.js
node /tmp/fleet_e2e_v2.mjs
```

Open the HTML, walk to Step 5, toggle the new hook on, generate.
Inspect:
- `cli/hooks/<name>.sh` exists, executable bit set
- `cli/settings.json` has the hook entry

### 5. Commit

```
feat(generator): add <name> hook
```
