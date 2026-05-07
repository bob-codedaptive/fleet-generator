---
name: fleet-generator-anatomy
description: >-
  Anatomy of fleet-generator.html — where every data structure lives, how skills/agents/hooks are defined, how substitution works, and how the zip gets built. Read before editing fleet-generator.html.
when_to_use: >-
  Editing fleet-generator.html. Adding an agent, skill, hook, or chat skill. Modifying defaults. Tracing why generated content looks the way it does. Trigger phrases: anatomy, where does X live in fleet-generator, how do I add a skill, how do I add an agent, how do I add a hook, edit fleet-generator, ROLES, CLI_SKILLS, OPTIONAL_HOOKS, CHAT_SKILLS, buildZipEntries.
status: active
tags: [skill]
updated: 2026-05-07
---

# Fleet-Generator Anatomy

This workshop maintains a personal copy of `fleet-generator.html` —
a single self-contained HTML file that produces installable Claude
agent fleets. This skill documents the file's structure so the
worker agent can edit it confidently.

## High-level layout

```
fleet-generator.html
├── HTML head + body skeleton (the wizard UI)
└── <script>
    ├── CONSTANTS  — STEP_TITLES, PREREQS, ROLES, OPTIONAL_*, UNCERTAINTY
    ├── STATE      — central `state` object
    ├── HELPERS    — kebab(), escHtml(), sub(), postSub(), subVars()
    ├── ZIP        — crc32, makeZip (STORE mode, no compression)
    ├── SKILL CONTENT — CLI_SKILLS, OPTIONAL_CLI_SKILLS, MAINT_CLI_SKILLS, WORKSHOP_CLI_SKILLS, CHAT_SKILLS, OPTIONAL_CHAT_SKILLS
    ├── POST-PROCESSING — fm(), renderSkill(), renderRefs()
    ├── AGENT MANIFEST — genAgent()
    ├── HOOKS      — hookScript() switch
    ├── TOP-LEVEL FILES — genCLAUDEmd(), genSettingsJSON(), genReadme(), genInstallSh()
    ├── BUILD ZIP  — buildZipEntries(), buildChatSkillZip()
    ├── WIZARD UI  — renderers per step
    ├── NAV        — canAdvance(), refreshNav(), goToStep()
    └── INIT       — init() at the very end
```

## The data structures you edit most

### `ROLES` (CONSTANTS section)

Array of agent role definitions. Each entry describes one role: key,
default name, title, required flag, persona, role description, what
the agent does and doesn't do, which skills it auto-loads, and the
`descLine` used in the manifest's frontmatter.

To add an agent, see [references/adding-an-agent.md](references/adding-an-agent.md).

### `CLI_SKILLS` (mandatory, always shipped)

Object map of skill key → `{ desc, use, body, refs }`. The body is
a template literal with `{{ var }}` substitutions and escaped backticks
(` in source becomes ` in output). Add a key here to ship a new
mandatory CLI skill.

### `OPTIONAL_CLI_SKILLS` (optional, wizard checkbox)

Same shape as CLI_SKILLS. Companion entry in `OPTIONAL_SKILLS` array
(in CONSTANTS) drives the wizard checkbox. Both must agree on key.

### `MAINT_CLI_SKILLS` (Quick Start project mode only)

Same shape. Only ships when `state.quickStart && !state.workshopMode`.
Currently: `agent-fleet-builder`, `canonical-skill-source`.

### `WORKSHOP_CLI_SKILLS` (workshop mode only)

Same shape. Only ships when `state.workshopMode`. This skill
(`fleet-generator-anatomy`) lives here.

### `CHAT_SKILLS` and `OPTIONAL_CHAT_SKILLS`

Object maps. Each value has a `name()` callback returning the skill
folder name (so vocab-driven names like `/scope` work). Body
follows the same template-literal pattern. Each chat skill becomes
its own zip inside `chat/`.

### `OPTIONAL_HOOKS` and `hookScript()`

Three-place pattern: (1) array entry in `OPTIONAL_HOOKS` for the
wizard checkbox, (2) bash body in `hookScript()`, (3) settings.json
event/pattern wiring in `genSettingsJSON()`. All three must match.

For step-by-step:
- [references/adding-a-skill.md](references/adding-a-skill.md)
- [references/adding-a-hook.md](references/adding-a-hook.md)

## Substitution flow

Skill bodies and reference files contain `{{ token }}` placeholders
(no spaces in real usage — written with spaces here so this doc
itself doesn't get substituted).
Two passes resolve them:

1. **`sub(s)`** — replaces tokens that are functions of state:
   `{{ project }}`, `{{ worker }}`, `{{ orch }}`, `{{ scope }}`,
   `{{ repo }}`, `{{ date }}`, etc. See `subVars()` for the full list.
2. **`postSub(s)`** — replaces tokens that are functions of prefs:
   `{{ VERB_LINE }}`, `{{ EMOJI_LINE }}`, `{{ UNCERT_LINE }}`,
   `{{ REPO_TABLE }}`, `{{ NEXUS_BANNER }}`.
3. **`unescapeBackticks(s)`** — converts source `\\`` into output ```
   (so fenced code blocks survive being inside a JS template literal).

Order: `postSub(sub(unescapeBackticks(body)))`.

## The NEXUS_MCP_LIVE flag

Single constant near the top of `<script>`. When `false`, skill
bodies that reference NexusMCP get a "PREVIEW — coming soon" banner.
When `true`, the banner disappears. Skills are otherwise complete and
ready.

To flip when NexusMCP ships: change one line.

## Verification (every edit)

After any edit to fleet-generator.html:

```bash
# 1. Syntax check (extract the last <script> block, run node --check)
python3 << 'PY'
import re
with open('fleet-generator.html') as f:
    html = f.read()
script = re.findall(r'<scr' + r'ipt>(.*?)</scr' + r'ipt>', html, re.DOTALL)[-1]
with open('/tmp/fc.js','w') as f:
    f.write(script)
PY
node --check /tmp/fc.js

# 2. End-to-end smoke (if /tmp/fleet_e2e_v2.mjs exists)
node /tmp/fleet_e2e_v2.mjs
```

If either fails, the edit is wrong. Fix before committing.

## File size discipline

The file has grown organically. Aim to keep it under 5,500 lines. If
you're approaching that, audit for redundant skill content rather
than splitting the file — splitting breaks the single-file deployment
property that makes this work on file://.
