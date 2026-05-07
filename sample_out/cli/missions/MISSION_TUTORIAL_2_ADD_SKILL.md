# Mission: Tutorial 2 — Add a Custom Skill

> **Tutorial.** Second in the workshop ladder. Teaches the
> three-place pattern for optional CLI skills.

## Context

You'll add a new optional CLI skill called `naming-conventions`
that captures your project's file/symbol naming rules. After this
mission, the wizard's Step 5 has a new checkbox for the skill, and
generated fleets can ship it.

The goal is to learn the three places that have to agree for an
optional skill to work.

## Read First

- `.claude/skills/fleet-generator-anatomy/SKILL.md`
- `.claude/skills/fleet-generator-anatomy/references/adding-a-skill.md`

## Files to Modify

| File | Change |
|---|---|
| fleet-generator.html | Add `naming-conventions` to `OPTIONAL_CLI_SKILLS` map |
| fleet-generator.html | Add wizard checkbox entry to `OPTIONAL_SKILLS` array |

(Same file, two edits.)

## Files NOT to Modify

- `.claude/**`
- `GUIDE.html`

## Implementation Parts

### Part 1 — Add the skill body

Open `fleet-generator.html`. Find `const OPTIONAL_CLI_SKILLS = {`.
Add a new entry inside the object:

\`\`\`js
'naming-conventions': {
  desc: "Naming conventions for fleet-generator — file naming, symbol naming, casing rules.",
  use: "Naming a new file, function, type, or variable. Reviewing names for consistency. Trigger phrases: name this file, what should I call this, naming convention, casing.",
  body: \`# Naming Conventions

Apply these conventions to all new code in fleet-generator.

## Files

- (your file naming rule, e.g. kebab-case for JS, snake_case for Python)

## Symbols

- (your symbol naming rule)

## Acronyms

- (your acronym handling rule)
\`
}
\`\`\`

### Part 2 — Add the wizard entry

Find `const OPTIONAL_SKILLS = [`. Add an entry that drives the
checkbox:

\`\`\`js
{ key:'naming-conventions', label:'Naming conventions',
  desc:'Project-specific naming rules for files, symbols, acronyms.' },
\`\`\`

The `key` MUST match the `OPTIONAL_CLI_SKILLS` key exactly.

**Commit:** `feat(generator): add naming-conventions skill`

→ verify: open the HTML, walk to Step 5, the new checkbox appears
  with your label and description; toggle it on, download, inspect
  `cli/skills/naming-conventions/SKILL.md`.

## Test Requirements

\`\`\`bash
# Syntax must still parse
python3 << 'PY'
import re
with open('fleet-generator.html') as f: html = f.read()
script = re.findall(r'<scr' + r'ipt>(.*?)</scr' + r'ipt>', html, re.DOTALL)[-1]
with open('/tmp/fc.js','w') as f: f.write(script)
PY
node --check /tmp/fc.js
\`\`\`

If `node --check` fails, you broke a template literal. Common cause:
unescaped backticks inside the body (use \`\\\`\` instead of \`\`).

## Verification

1. Open `fleet-generator.html` in a browser
2. Walk to Step 5 (Preferences)
3. The new checkbox is present under Optional Skills
4. Toggle it on, walk to Download
5. Open the downloaded zip; `cli/skills/naming-conventions/SKILL.md` exists
6. Body matches what you wrote (with `fleet-generator` substituted)

## Success Criteria

- [ ] `OPTIONAL_CLI_SKILLS` has the new entry
- [ ] `OPTIONAL_SKILLS` has the matching wizard entry
- [ ] Wizard renders the new checkbox
- [ ] Generated zip contains the skill when toggled on
- [ ] No template-literal syntax errors
- [ ] One commit landed

## Next

When this lands, run Tutorial 3 (`MISSION_TUTORIAL_3_ADD_HOOK.md`)
to add a custom hook.
