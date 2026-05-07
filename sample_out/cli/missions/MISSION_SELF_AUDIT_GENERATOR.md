# Mission: Self-Audit — Workshop Wave N

## Context

This audits your personal copy of `fleet-generator.html` AND the
workshop's `.claude/` configuration. Run it periodically — monthly,
or whenever the workshop feels off.

The goal is a measured grade and a Wave (N+1) proposal, not
immediate fixes. Audits produce reports; missions produce changes.

## Read First

- `.claude/skills/agent-fleet-builder/SKILL.md`
- `.claude/skills/agent-fleet-builder/references/wave-methodology.md`
- `.claude/skills/canonical-skill-source/SKILL.md`
- `.claude/skills/fleet-generator-anatomy/SKILL.md`

## Files to Modify

| File | Change |
|---|---|
| docs/fleet-audits/WAVE_N_REPORT.md | New file: audit report (template below) |

## Files NOT to Modify

- `fleet-generator.html`
- `GUIDE.html`
- `.claude/**`

A self-audit that secretly mutates the generator is the worst kind
of audit. Wave N produces a report. Wave N+1 (a separate mission)
acts on it.

## Implementation Parts

### Part 1 — Measure the generator

Run these probes against `fleet-generator.html`:

\`\`\`bash
# Line count
wc -l fleet-generator.html

# Skill counts
grep -c "^  '[a-z-]\+':" fleet-generator.html  # rough — review categories below

# Untranslated tokens (should be zero)
grep -oE '\{\{[A-Z_a-z][^}]*\}\}' fleet-generator.html | sort -u

# JS syntax
python3 << 'PY'
import re
with open('fleet-generator.html') as f: html = f.read()
script = re.findall(r'<scr' + r'ipt>(.*?)</scr' + r'ipt>', html, re.DOTALL)[-1]
with open('/tmp/fc.js','w') as f: f.write(script)
PY
node --check /tmp/fc.js && echo "JS OK"
\`\`\`

Record numbers and findings.

### Part 2 — Grade against the rubric

For each category in `agent-fleet-builder`, grade the generator's
output (the fleet a Quick Start produces from this generator) and
the workshop's `.claude/` setup. Two grades per category:

- A: every requirement met
- B: most requirements met; non-blocking gaps
- C: significant gaps that drag overall quality
- D: foundational requirements missing

Categories: A subagents, B skills, C hooks, D rules/CLAUDE.md,
E memory, F models/effort, G docs.

### Part 3 — Identify the lowest grade

The wave that produces the most leverage targets the lowest-grade
category. Identify it; note dependencies.

### Part 4 — Propose Wave N+1

Use the wave-shape format:

- Primary metric (single binary measurable target)
- Within-wave iteration mechanic
- Bespoke probe
- Success criteria
- Dependencies

### Part 5 — Write the report

Write `docs/fleet-audits/WAVE_N_REPORT.md` with the audit and the
proposed Wave N+1.

**Commit:** `docs(fleet-audits): Wave N self-audit`

→ verify: report exists; each category has a grade for both
  generator and workshop; Wave N+1 is defined; no other files
  modified.

## Verification

- Report exists at `docs/fleet-audits/WAVE_N_REPORT.md`
- Two grades per category (one for generator output, one for workshop)
- Wave N+1 defined in wave-shape format
- No edits to fleet-generator.html, GUIDE.html, or .claude/

## Success Criteria

- [ ] Wave N report written
- [ ] Generator grades: 7 categories × 1 grade each
- [ ] Workshop grades: 7 categories × 1 grade each
- [ ] Wave N+1 proposed with primary metric
- [ ] Report committed; no other files changed

## Report template

\`\`\`markdown
# Workshop Audit — Wave N — 2026-05-07

## Probes (raw measurements)

- Line count: <N>
- Skill counts: CLI=<n> mandatory + <m> optional + <q> Quick Start + <w> workshop, Chat=<n> mandatory + <m> optional
- Untranslated tokens: <list>
- JS syntax: PASS / FAIL
- Other observations: ...

## Grades

| Category | Generator output | Workshop .claude/ | Evidence |
|---|---|---|---|
| A. Subagents       | ? | ? | ... |
| B. Skills          | ? | ? | ... |
| C. Hooks           | ? | ? | ... |
| D. Rules / CLAUDE.md | ? | ? | ... |
| E. Memory          | ? | ? | ... |
| F. Models / effort | ? | ? | ... |
| G. Docs            | ? | ? | ... |

## Lowest-grade category

<which one, why, generator vs workshop>

## Wave N+1 proposal

### Primary metric
<single binary target>

### Within-wave iteration mechanic
<what to try first; what to try if first attempt fails;
 max attempts before escalation>

### Bespoke probe
<small targeted test>

### Success criteria
<what "wave passed" means>

### Dependencies
<prior waves or fixes required first>
```
