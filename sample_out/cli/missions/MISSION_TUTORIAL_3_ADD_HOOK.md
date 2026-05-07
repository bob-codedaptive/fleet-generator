# Mission: Tutorial 3 — Add a Custom Hook

> **Tutorial.** Third in the workshop ladder. Teaches the
> three-place hook pattern: array entry, script body, settings.json
> wiring.

## Context

You'll add a new optional hook called `log-mission-changes` that
fires on PostToolUse for Edit/Write events and logs whenever
`.claude/active-mission.md` changes. After this mission, the
wizard's Optional Hooks section has a new checkbox.

The goal is to learn the three-place hook pattern. All three places
must agree on the hook key.

## Read First

- `.claude/skills/fleet-generator-anatomy/SKILL.md`
- `.claude/skills/fleet-generator-anatomy/references/adding-a-hook.md`

## Files to Modify

| File | Change |
|---|---|
| fleet-generator.html | Add wizard entry to `OPTIONAL_HOOKS` array |
| fleet-generator.html | Add bash body branch to `hookScript()` |
| fleet-generator.html | Add settings.json wiring to `genSettingsJSON()` |

(Same file, three edits.)

## Files NOT to Modify

- `.claude/**`
- `GUIDE.html`

## Implementation Parts

### Part 1 — Wizard entry

Find `const OPTIONAL_HOOKS = [`. Add an entry:

\`\`\`js
{ key:'log-mission-changes', label:'Log mission file changes',
  desc:'Append to ~/.claude/audit/mission-changes.log when active-mission.md is edited.' },
\`\`\`

### Part 2 — Script body

Find `function hookScript(key) {`. Add a branch:

\`\`\`js
if (key === 'log-mission-changes') return \`#!/usr/bin/env bash
set -euo pipefail
mkdir -p ~/.claude/audit
ts="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
stdin_raw="$(cat)"
target=""
if command -v jq >/dev/null 2>&1; then
  target="$(printf '%s' "$stdin_raw" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null || printf '')"
fi
case "$target" in
  *.claude/active-mission.md)
    echo "$ts | edited active-mission.md" >> ~/.claude/audit/mission-changes.log
    ;;
esac
\`;
\`\`\`

(Watch the escaping. Backticks in bash are escaped as \`\\\`\`.)

### Part 3 — settings.json wiring

Find `function genSettingsJSON() {`. Add a branch:

\`\`\`js
if (state.prefs.hooks['log-mission-changes'])
  settings.hooks.push({ event:'PostToolUse', pattern:'Edit|Write|MultiEdit',
    command:'.claude/hooks/log-mission-changes.sh' });
\`\`\`

**Commit:** `feat(generator): add log-mission-changes hook`

→ verify: open the HTML, walk to Step 5, the new hook checkbox is
  present; toggle on, generate, inspect both `cli/hooks/log-mission-changes.sh`
  AND `cli/settings.json` to confirm the entry exists.

## Test Requirements

\`\`\`bash
python3 << 'PY'
import re
with open('fleet-generator.html') as f: html = f.read()
script = re.findall(r'<scr' + r'ipt>(.*?)</scr' + r'ipt>', html, re.DOTALL)[-1]
with open('/tmp/fc.js','w') as f: f.write(script)
PY
node --check /tmp/fc.js
\`\`\`

## Verification

1. Open the HTML, walk to Step 5
2. The hook checkbox is visible
3. Toggle it on, generate
4. Unzip the download
5. `cli/hooks/log-mission-changes.sh` exists, executable bit set
6. `cli/settings.json` includes the hook entry with the right event/pattern
7. The bash script is syntactically valid: `bash -n cli/hooks/log-mission-changes.sh`

## Success Criteria

- [ ] `OPTIONAL_HOOKS` has the new wizard entry
- [ ] `hookScript()` has the new branch with bash body
- [ ] `genSettingsJSON()` has the new wiring
- [ ] All three keys agree
- [ ] Wizard renders the checkbox
- [ ] Generated zip contains script + settings entry
- [ ] `bash -n` accepts the script
- [ ] One commit landed

## What you just learned

You can now extend fleet-generator.html with new agents, skills, and
hooks confidently. The patterns are uniform — each is a small set of
parallel additions to specific data structures, with three-place
agreement for hooks.

For deeper changes (modifying chat skills, adding wizard steps,
changing zip layout), read `fleet-generator-anatomy/SKILL.md` end
to end.

## Next

Run `MISSION_SELF_AUDIT_GENERATOR.md` periodically to grade your
fork against the agent-fleet-builder rubric and propose improvement
waves.
