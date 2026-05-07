# Fleet Generator — Specification

## Purpose

Single self-contained HTML file (`fleet-generator.html`, ~6.3k lines) that runs in any browser on `file://` and produces a downloadable ZIP containing a complete, installable Claude agent fleet for a software project. Audience is non-technical: the user never copies a raw `.claude/` directory; they get a tarball with `install.sh`.

## Three install paths (Step 0)

| Path | Time | Defaults | Best for |
|---|---|---|---|
| **1. Guided wizard** | ~5 min | User picks everything | Real product repos — choose names, vocabulary, only the agents/hooks you want |
| **2. Quick Start** | ~30 sec | Every agent + every optional skill + every hook + maintenance kit + starter audit mission, all on | Fresh/empty test repos. Safe in production (never overwrites existing `CLAUDE.md`/`settings.json`; lands them as `*.fleet`) |
| **3. Workshop** | ~30 sec | Same as Quick Start, plus the live HTML page is captured into the bundle as `fleet-generator.html`, plus three tutorial missions (`MISSION_TUTORIAL_1_RENAME_WORKER`, `_2_ADD_SKILL`, `_3_ADD_HOOK`) and a workshop-specific self-audit | Power users who want a personal, evolvable fork of the generator |

All three converge on the same `downloadZip()` → in-browser zip writer.

## UI — 8-step wizard

| Step | Title | What it captures | Validation |
|---|---|---|---|
| 0 | Start | Path selection (cards 1/2/3); prerequisite checklist | None |
| 1 | Project | `name`, `desc`, `root` folder | name + desc required |
| 2 | Repos | List of `{name, branch, path}` | ≥1 repo with name+path |
| 3 | Vocabulary | Three slash-command words: `scope`/`draft`/`submit` (renameable) | All required; rejects ~60 reserved Claude built-ins (`/plan`, `/clear`, `/init`, `/agents`, `/skills`, `/hooks`, `/loop`, `/schedule`, `/security-review`, `/ultrareview`, etc.) |
| 4 | Team | Per agent: enabled?, name (≤64), persona (≤1024) | Required agents enabled with names |
| 5 | Preferences | Verbosity slider (terse/normal/detailed), uncertainty mode (ask / guess+flag / always-ask), emoji on/off, optional CLI skills, optional hooks, optional chat skills | None |
| 6 | Preview | Stats grid (agent/skill/hook counts) + monospace tree of the zip | None |
| 7 | Download | Big download button + post-download next-steps card | None |

UI invariants: Tailwind via CDN, DM Sans font, vanilla JS, no React/Babel/build step. Inputs use `oninput` (not `onchange`) so the Next button enables as the user types. Containers holding active inputs aren't `innerHTML`-rebuilt on keystroke.

## Data model

```
state = {
  step, prereqs[5],
  project: { name, desc, root },
  repos: [{ name, branch, path }, ...],
  vocab:  { scope, draft, submit },
  agents: { <key>: { enabled, name, persona } },
  prefs:  { verbosity, uncertainty, emoji, skills{}, hooks{}, chatSkills{} },
  quickStart, workshopMode, workshopPayload
}
```

`ROLES` (constant) defines the menu of nine agents, each with: `key`, default `name` (cartoon character), `title`, `required`, `persona` (≤1024), `role`, `does[]`, `notDoes[]`, `skills[]`, `descLine` (manifest frontmatter description with "MUST BE USED" / "Use PROACTIVELY" cues).

| Role | Default | Required | Read-only |
|---|---|---|---|
| Orchestrator | Hobbes | ✓ | — |
| Code Worker | Woodstock | ✓ | — |
| Reviewer | Garfield | — | ✓ |
| Pre-flight Scanner | Snoopy | — | ✓ |
| Architect | Calvin | — | ✓ |
| Doc Writer | Linus | — | — |
| Security Reviewer | Dogbert | — | ✓ |
| Accessibility Reviewer | Cathy | — | ✓ |
| Performance Reviewer | Opus | — | ✓ |

## Output structure

```
{project}-fleet/                    (or {project}/ in workshop mode)
├── install.sh                       (executable bit set in the zip)
├── README.md
├── fleet-config.json                (the wizard answers, kept for reference)
├── fleet-generator.html             (workshop mode only — captured live page)
├── GUIDE.html                       (workshop mode only — best-effort fetch)
├── cli/
│   ├── CLAUDE.md
│   ├── settings.json                (hooks wiring; selected hooks only)
│   ├── agents/<slug>.md             (one per enabled agent)
│   ├── skills/<name>/SKILL.md       (mandatory + selected optional + mode-specific)
│   │   └── references/<file>.md     (progressive disclosure for skills with depth)
│   ├── rules/
│   │   ├── repo-layout.md
│   │   ├── compaction.md            (compactor preservation instructions)
│   │   └── hazmat.md                (the 7 always-on rules)
│   ├── hooks/<key>.sh               (selected hooks only; chmod +x)
│   └── missions/
│       ├── MISSION_EXAMPLE.md
│       ├── MISSION_SELF_AUDIT.md            (Quick Start project mode)
│       ├── MISSION_SELF_AUDIT_GENERATOR.md  (workshop)
│       └── MISSION_TUTORIAL_{1,2,3}_*.md    (workshop)
└── chat/
    ├── README.md
    ├── {scope-word}.zip
    ├── {draft-word}.zip
    ├── {submit-word}.zip
    ├── communication.zip
    ├── bootstrap.zip
    ├── continuity.zip
    ├── notebooklm-prep.zip          (when toggled on; Quick Start auto-enables)
    └── memory-interface.zip         (when toggled on; ships in NexusMCP-preview state)
```

Each `chat/*.zip` is its own zip-within-a-zip (one folder per skill, `SKILL.md` + optional `references/`), ready to drag into claude.ai → Settings → Capabilities → Skills.

## Generated content catalog

### CLI skills

**Mandatory (10, always shipped):** `pre-commit`, `self-review`, `mission-template`, `git-workflow`, `communication`, `human-patterns`, `bootstrap`, `agent-commits`, `safety-rules`, `subagent-orchestration`.

**Optional (8, wizard checkboxes):** `blast-radius`, `mission-scoping`, `tdd`, `deep-research`, `documentation-rev`, `source-of-truth`, `branch-hygiene`, `nexusmcp`.

**Maintenance (Quick Start project mode only):** `agent-fleet-builder` (A-grade rubric across 7 categories + wave methodology), `canonical-skill-source` (single-source authoring rule).

**Workshop (Workshop mode only):** `fleet-generator-anatomy` (where every data structure lives in this HTML, three-place patterns for adding agents/skills/hooks).

Each skill body uses progressive disclosure: short `SKILL.md` + a `references/` folder containing detail files linked from the body.

### Chat skills (claude.ai uploads)

**Mandatory (6):** `{scope}` (investigation, read-only, anti-bolt mandate, Workspace artifact for compaction survival), `{draft}` (spec refinement via artifacts), `{submit}` (formats the draft and prints the CLI launch command), `communication`, `bootstrap`, `continuity`.

**Optional (2):** `notebooklm-prep` (curate sources + customization prompt; direct mode via notebooklm MCP, or paste mode), `memory-interface` (operating guide for NexusMCP — ships with a "PREVIEW — coming soon" banner until `NEXUS_MCP_LIVE = true`).

### Hooks (9 optional)

| Key | Event | Purpose |
|---|---|---|
| `log-stop-failure` | Stop | Append exit codes |
| `log-instructions-loaded` | PostStart | Audit which CLAUDE.md/rules loaded |
| `gate-push` | PreToolUse `Bash(git push *)` | Auto-approve routine pushes |
| `log-subagent-start` | SubagentStart | Structural audit per spawn |
| `log-subagent-stop` | SubagentStop | Closes the start/stop pair |
| `save-pre-compact` | PreCompact | Lossless transcript dump |
| `verify-post-compact` | PostCompact | Diagnostic note about whether the active mission survived |
| `enforce-write-scope` | PreToolUse `Edit\|Write\|MultiEdit` | Gates writes against active mission's "Files to Modify"; default WARN, BLOCK via `CLAUDE_HOOK_MODE=block` |
| `prompt-memory-curation` | Stop | Nudges curation note when ≥10 hook events in last 60 min |

All scripts: `set -euo pipefail`, jq with grep fallback, fail-open on errors, audit-log to `~/.claude/audit/`.

### Rules (always shipped)

- **`repo-layout.md`** — generated table of repos and conventions
- **`compaction.md`** — instructions to the compactor: preserve mission title, Files-to-Modify list, Blast Radius scope, current Part + verify line, latest test exit code, RESCOPE_REQUIRED items, etc.
- **`hazmat.md`** — the seven always-on rules: SPEC-BEFORE-REALITY, LOOK-BEFORE-WRITE, WRITE-SURFACE, NO-OVERWRITE, MISSION-SCOPE-IS-A-BOUNDARY, ASK-WHEN-CROSSING-LANES, REPORT-CONFLICTS-IMMEDIATELY.

### Top-level files

- **`CLAUDE.md`** — project header, repos table, team list, vocabulary mapping, standard subagent flow (synthesized from which agents are enabled), working-style block, "Locked Decisions" stub, where-things-live block.
- **`settings.json`** — JSON with `hooks[]` entries for each selected hook (event/pattern/command).
- **`install.sh`** — bash that takes a target path (defaults to `.`). If the target isn't a git repo, prompts to `git init` it (default Y), or auto-inits with `--init`/`-y` flag, or auto-inits when stdin is non-tty. Then `mkdir -p` the `.claude/` skeleton, copies agents/skills/rules/missions, copies hooks with `chmod +x`, refuses to overwrite existing `CLAUDE.md` or `.claude/settings.json` (lands them as `*.fleet`).
- **`README.md`** — different copy for workshop vs. project mode.
- **`fleet-config.json`** — the raw wizard state for re-running.

## Substitution & templating

Skill and reference bodies are JS template literals containing `{{token}}` placeholders. Three-pass resolution:

1. **`unescapeBackticks(s)`** — converts source `\`` (escaped because the body lives inside a template literal) back to literal `` ` `` so fenced code blocks render.
2. **`sub(s)`** — state-derived tokens via `subVars()`: `{{project}}`, `{{project_kebab}}`, `{{worker}}`/`{{worker_lc}}` (and same for orch/rev/pre/arch/doc/sec/a11y/perf), `{{scope}}`/`{{draft}}`/`{{submit}}` (lowercase) and `{{SCOPE}}`/`{{DRAFT}}`/`{{SUBMIT}}` (upper), `{{repo}}` (first repo path), `{{date}}`.
3. **`postSub(s)`** — preference-derived tokens: `{{VERB_LINE}}`, `{{EMOJI_LINE}}`, `{{UNCERT_LINE}}`, `{{VERB_HEADLINE}}`, `{{VERB_DETAIL}}`, `{{UNCERT_HEADLINE}}`, `{{UNCERT_DETAIL}}`, `{{REPO_TABLE}}`, `{{NEXUS_BANNER}}`.

Order: `postSub(sub(unescapeBackticks(body)))`.

Frontmatter is built by `fm(name, description, when_to_use)` and prepended.

## Mode-conditional behavior

| Flag | Effect |
|---|---|
| `state.quickStart` | Adds `MAINT_CLI_SKILLS` (`agent-fleet-builder`, `canonical-skill-source`) and `MISSION_SELF_AUDIT.md` |
| `state.workshopMode` | Adds `WORKSHOP_CLI_SKILLS` (`fleet-generator-anatomy`); adds three tutorial missions + workshop self-audit; bundles captured live `fleet-generator.html` (and best-effort `GUIDE.html`) at the root; root folder named `{project}/` instead of `{project}-fleet/` |
| `NEXUS_MCP_LIVE` (top-of-script constant) | When `false`, `nexus-mcp` CLI skill and `memory-interface` chat skill prepend a "PREVIEW — coming soon" banner. Flip the flag → banner disappears. Skill bodies are otherwise complete. |

## ZIP writer

Hand-rolled, no dependencies. STORE mode (no compression). `crc32` + `makeZip(entries)`: writes Local File Headers + Central Directory + EOCD. Honors an `executable` bit per entry → external attrs `0o100755 << 16` so `install.sh` and hook scripts land executable. Output is a `Blob`, served as an object URL into a hidden `<a download>` element.

## Technical constraints

- Single HTML file. Tailwind via CDN. DM Sans + JetBrains Mono via Google Fonts.
- No build step, no React, no external JS libraries.
- Must work on `file://` (Workshop mode best-effort `fetch('GUIDE.html')` may fail under file CORS — handled silently).
- Reserved-slash-command set is hardcoded (~60 commands); update when Claude ships new built-ins.
- File size: aspirationally under 5,500 lines (currently 6,289). Splitting breaks the single-file `file://` deployment property.

## Verification recipe (post-edit)

```bash
# 1. JS syntax — extract last <script> block, run node --check
python3 -c "
import re
html = open('fleet-generator.html').read()
script = re.findall(r'<scr' + r'ipt>(.*?)</scr' + r'ipt>', html, re.DOTALL)[-1]
open('/tmp/fc.js','w').write(script)"
node --check /tmp/fc.js

# 2. No untranslated tokens in generated output
grep -oE '\{\{[A-Z_a-z][^}]*\}\}' fleet-generator.html | sort -u

# 3. End-to-end smoke (if the test harness exists)
node /tmp/fleet_e2e_v2.mjs
```

## Drift from the original V2 mission

The mission file in `web/MISSION_FLEET_GENERATOR_V2.md` is a slightly stale snapshot. Notable evolutions since then:
- Added Path 2 (Quick Start) and Path 3 (Workshop) on top of the wizard.
- Hook count grew from 3 to 9; a `subagent-orchestration` mandatory skill was added (10 mandatory now, not 9).
- Chat skills grew beyond `scope/draft/submit/communication` to add `bootstrap`, `continuity` (mandatory) and `notebooklm-prep`, `memory-interface` (optional).
- Three rules files (`repo-layout`, `compaction`, `hazmat`) added to the always-on set.
- Maintenance kit (`agent-fleet-builder`, `canonical-skill-source`, `MISSION_SELF_AUDIT`) and the workshop tutorial ladder were added later.
- The 3,000-line target is gone — current file is 6,289 lines.
- Reserved-slash-command validation in Step 3 is new.
- `NEXUS_MCP_LIVE` flag and the preview banner mechanism are new.
