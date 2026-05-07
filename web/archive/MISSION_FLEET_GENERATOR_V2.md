# Mission: Fleet Generator v2 — Complete Rebuild

## Context

The Fleet Generator is a standalone HTML file that runs in any browser.
It is a multi-step wizard that asks questions about a user's project,
agents, skills, and preferences, then generates a downloadable zip
containing a complete, installable Claude agent team.

The current version at `tools/fleet-generator/fleet-generator.html`
has broken content generation. This mission rebuilds it from scratch
with full, production-quality generated content modeled on the actual
agent infrastructure in this repo.

**The audience is non-technical.** Amelia, friends, future Nexus
customers. They should never see `.claude/` as a raw directory to
copy. The output must be an installable package with clear instructions.

## Read First

Study these as the reference implementation. The generated output
must match this quality and structure:

1. `/Users/bob/devlop/fulcrum/.claude/` — full agent infrastructure
   - `agents/` — agent manifest format, YAML frontmatter, role instructions
   - `skills/` — skill format with SKILL.md + references/ subdirectories
   - `hooks/` — hook scripts
   - `rules/` — always-on rules
   - `settings.json` — settings format
2. `/Users/bob/devlop/fulcrum/CLAUDE.md` — project CLAUDE.md format
3. `/Users/bob/dev_docs/simple-machines-docs/shared/skills_desktop/` — chat skill format
   - `scope/SKILL.md` — scope mode chat skill
   - `draft/SKILL.md` — draft mode chat skill  
   - `submit/SKILL.md` — submit mode chat skill
4. `/Users/bob/dev_docs/simple-machines-docs/shared/agents_source/_skills/` — CLI skill format
   - Every skill: read the SKILL.md to understand the depth and quality expected
   - Skills with `references/` directories: understand progressive disclosure
5. `/Users/bob/dev_docs/simple-machines-docs/tools/fleet-generator/fleet-generator.html` — current broken version (UI works, content generation is wrong)

## Requirements

### UI (the wizard)
The current wizard UI mostly works. Keep the same 8-step flow:
0. Prerequisites, 1. Project, 2. Repos, 3. Vocabulary, 4. Team, 5. Preferences, 6. Preview, 7. Download

Fix these UI bugs:
- Step 2 (Repos): Next button must enable as user types (use oninput not onchange)
- All inputs must hold focus while typing (no DOM reconstruction on keystroke)
- Navigation must work on all steps including step 0

### Packaging (the zip output)
The zip must NOT contain a raw `.claude/` directory for the user to copy.
Instead, produce an installer script and organized packages:

```
{project}-fleet/
├── install.sh                    ← bash script that installs everything
├── README.md                     ← what this is and how to use it
├── cli/
│   ├── CLAUDE.md                 ← project CLAUDE.md to place in repo root
│   ├── settings.json             ← .claude/settings.json
│   ├── agents/                   ← agent manifests
│   │   ├── {name}.md
│   │   └── ...
│   ├── skills/                   ← skill directories with SKILL.md + references/
│   │   ├── pre-commit/
│   │   │   └── SKILL.md
│   │   ├── self-review/
│   │   │   └── SKILL.md
│   │   └── ...
│   ├── hooks/                    ← hook scripts (when selected)
│   │   └── ...
│   ├── rules/                    ← always-on rules
│   │   └── repo-layout.md
│   └── missions/
│       └── MISSION_EXAMPLE.md
├── chat/
│   ├── README.md                 ← chat skill install instructions
│   ├── {scope-word}/
│   │   └── {scope-word}/
│   │       └── SKILL.md
│   ├── {draft-word}/
│   │   └── {draft-word}/
│   │       └── SKILL.md
│   ├── {submit-word}/
│   │   └── {submit-word}/
│   │       └── SKILL.md
│   └── communication/
│       └── communication/
│           └── SKILL.md
└── fleet-config.json
```

### install.sh
The install script must:
```bash
#!/bin/bash
# Fleet installer for {project-name}
# Usage: ./install.sh /path/to/your/repo

REPO_PATH="${1:-.}"

if [ ! -d "$REPO_PATH/.git" ]; then
  echo "Error: $REPO_PATH is not a git repo"
  exit 1
fi

# Create .claude/ structure (don't overwrite existing settings.json)
mkdir -p "$REPO_PATH/.claude/agents"
mkdir -p "$REPO_PATH/.claude/skills"
mkdir -p "$REPO_PATH/.claude/hooks"
mkdir -p "$REPO_PATH/.claude/rules"

# Copy agents
cp cli/agents/*.md "$REPO_PATH/.claude/agents/"

# Copy skills (preserving references/ subdirs)
cp -r cli/skills/* "$REPO_PATH/.claude/skills/"

# Copy hooks
if [ -d "cli/hooks" ] && [ "$(ls cli/hooks/)" ]; then
  cp cli/hooks/*.sh "$REPO_PATH/.claude/hooks/"
fi

# Copy rules
cp cli/rules/*.md "$REPO_PATH/.claude/rules/"

# Copy CLAUDE.md (warn if exists)
if [ -f "$REPO_PATH/CLAUDE.md" ]; then
  echo "CLAUDE.md already exists. Saved new version as CLAUDE.md.fleet"
  cp cli/CLAUDE.md "$REPO_PATH/CLAUDE.md.fleet"
else
  cp cli/CLAUDE.md "$REPO_PATH/CLAUDE.md"
fi

# Merge settings.json (warn if exists)
if [ -f "$REPO_PATH/.claude/settings.json" ]; then
  echo "settings.json already exists. Saved new version as settings.json.fleet"
  cp cli/settings.json "$REPO_PATH/.claude/settings.json.fleet"
else
  cp cli/settings.json "$REPO_PATH/.claude/settings.json"
fi

echo ""
echo "Fleet installed to $REPO_PATH"
echo "Agents: $(ls cli/agents/ | wc -l | tr -d ' ')"
echo "Skills: $(ls cli/skills/ | wc -l | tr -d ' ')"
echo ""
echo "To run a mission:"
echo "  cd $REPO_PATH"
echo "  claude --agent {worker-name} --model opus --dangerously-skip-permissions"
echo "  # paste your mission file content"
```

### Content Quality

**Agent manifests** must include:
- YAML frontmatter with name, description (up to 1024 chars from persona), model
- Full role instructions (What You Do / What You Do NOT Do)
- Persona if provided
- Skills reference
- Communication preferences from wizard

Model these on the actual agents in `/Users/bob/devlop/fulcrum/.claude/agents/`.

**Skills** must include:
- YAML frontmatter with name, description (trigger phrases included)
- Complete, actionable instructions (not "see documentation")
- Checklists, protocols, and rules that an agent can follow immediately

Model these on the actual skills in the repo. Read at least:
- `pre-commit/SKILL.md`
- `self-review/SKILL.md`
- `mission-template/SKILL.md`
- `blast-radius/SKILL.md`
- `git-workflow/SKILL.md`

Every generated skill must be AT LEAST as detailed as these references.

**Chat skills** must include:
- Full mode instructions with anti-bolt mandate (scope), artifact workflow (draft), CLI launch instructions (submit)
- Memory edit state management
- Mode footer reminder
- Workspace artifact integration for compaction survival

Model these on the actual chat skills in `shared/skills_desktop/scope/SKILL.md`, `draft/SKILL.md`, `submit/SKILL.md`.

**Hooks** (when selected) must include:
- Working bash scripts
- Proper settings.json hook configuration
- Model on actual hooks in the repo

### Agent Role Catalog

The wizard presents these roles with cartoon character defaults:

| Role | Default Name | Required |
|---|---|---|
| Orchestrator | Hobbes | Yes (coding team) |
| Code Worker | Woodstock | Yes (coding team) |
| Reviewer | Garfield | No |
| Pre-flight Scanner | Snoopy | No |
| Architect | Calvin | No |
| Doc Writer | Linus | No |
| Security Reviewer | Dogbert | No |
| Accessibility Reviewer | Cathy | No |
| Performance Reviewer | Opus | No |

Each role has a sample persona (300-400 chars) and role-specific instructions.

### Mandatory Skills (always generated)
pre-commit, self-review, mission-template, git-workflow, communication, human-patterns, bootstrap, agent-commits, safety-rules

### Optional Skills (checkboxes)
blast-radius, mission-scoping, tdd, deep-research, documentation-rev, source-of-truth, branch-hygiene, nexusmcp

### Optional Hooks (checkboxes)
log-stop-failure, log-instructions-loaded, gate-push

### settings.json
Generate a proper settings.json that wires up:
- Hook configurations for selected hooks
- Agent permissions

Model on the actual `fulcrum/.claude/settings.json`.

## Technical Constraints

- Single HTML file, vanilla JavaScript, no frameworks
- Tailwind CSS via CDN (`<script src="https://cdn.tailwindcss.com"></script>`)
- DM Sans font from Google Fonts
- Client-side zip generation (pure JS, no external libraries)
- Must work when opened as a local file (file:// protocol) or served
- No React, no Babel, no build step
- All inputs must use oninput (not onchange) to update state immediately
- No innerHTML reconstruction of containers that hold active inputs
- File should be under 3000 lines total

## Files to Modify

| File | Change |
|---|---|
| `tools/fleet-generator/fleet-generator.html` | REWRITE — complete rebuild |

## Files NOT to Modify

- Everything outside `tools/fleet-generator/`
- Existing repo `.claude/` directories (read-only reference)

## Implementation Parts

### Part 1 — Study reference implementation
Read every file listed in "Read First." Understand the structure, format, and depth of content in actual agents, skills, hooks, and rules. Take notes on patterns.

**No commit.** This is research.

### Part 2 — Build content generators
Write all JavaScript functions that generate:
- CLAUDE.md
- Agent manifests (per role type with full instructions)
- Every mandatory skill (complete content)
- Every optional skill (complete content)
- Chat mode skills (scope, draft, submit, communication)
- Hook scripts and settings.json entries
- install.sh
- README.md
- INSTALL instructions for chat

Test each generator by calling it with sample config and verifying the output matches the quality of the reference files.

**Commit:** `feat(fleet-generator): content generators with full skill/agent content`

### Part 3 — Build wizard UI
Rebuild the 8-step wizard with working navigation, inputs, agent cards with persona editor, preference controls, optional skill/hook checkboxes, preview panel, and download button.

**Commit:** `feat(fleet-generator): wizard UI with all 8 steps`

### Part 4 — Wire download
Connect the download button to the content generators. Generate the zip with proper directory structure, install.sh, and all content.

**Commit:** `feat(fleet-generator): zip generation with install script`

### Part 5 — Test end-to-end
Run through the wizard, download the zip, unzip it, verify:
1. install.sh runs without errors on a test directory
2. Every agent manifest has complete role instructions
3. Every skill has complete actionable content
4. Chat skills have full mode instructions
5. settings.json is valid JSON with hook configs
6. CLAUDE.md references the correct agent names and repos

**Commit:** `test(fleet-generator): end-to-end verification`

## Test Requirements

- Wizard navigation works on all 8 steps
- All inputs hold focus while typing
- Next button enables/disables correctly on every step
- Download produces a valid zip
- install.sh creates proper .claude/ structure
- Zero stub content ("see documentation", "placeholder", etc.)
- Every generated skill has YAML frontmatter + complete instructions
- Agent manifests include full role-specific What You Do / What You Do NOT Do
- Chat skills include memory_user_edits, workspace artifact, mode footer

## Verification

1. Open fleet-generator.html in Chrome
2. Walk through all 8 steps
3. Download zip
4. Unzip and run `./install.sh /tmp/test-repo` (create a git repo at /tmp/test-repo first)
5. Verify .claude/ structure matches expected output
6. Read every generated file — zero stubs, zero placeholders

## Success Criteria

- [ ] Single HTML file works in any browser
- [ ] All 8 wizard steps functional with working inputs
- [ ] Download produces valid zip with install.sh
- [ ] Every agent manifest has complete role instructions
- [ ] Every skill has complete, actionable SKILL.md
- [ ] Chat skills have full mode instructions
- [ ] settings.json includes hook configurations
- [ ] install.sh safely installs without overwriting existing config
- [ ] Zero stub content anywhere in generated output
- [ ] Content quality matches the reference implementation in this repo
