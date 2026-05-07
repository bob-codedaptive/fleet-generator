# Adding a Skill

Skills auto-load when the worker / orchestrator encounters language
that matches the skill's `use` (when_to_use) field.

## The three-place pattern (for optional skills)

1. **Body in a SKILL map** — `CLI_SKILLS` (mandatory),
   `OPTIONAL_CLI_SKILLS` (wizard checkbox), `MAINT_CLI_SKILLS`
   (Quick Start project mode), or `WORKSHOP_CLI_SKILLS` (workshop)
2. **Wizard array entry** in `OPTIONAL_SKILLS` if it goes in
   `OPTIONAL_CLI_SKILLS` (drives the checkbox)
3. **Preview/tree update** — happens automatically via
   `previewTree()`, no manual edit needed

## Step-by-step (mandatory skill)

### 1. Add a body to `CLI_SKILLS`

In the SKILL CONTENT section. Each entry looks like:

```js
'naming-conventions': {
  desc: "Naming conventions for fleet-generator — kebab-case files, ...",
  use: "Naming a new file, function, or variable. Trigger phrases: ...",
  body: `# Naming Conventions

Some prose body with **markdown**.

\\`\\`\\`bash
# fenced code uses escaped backticks: \\\\\\` becomes \\` in output
echo "hi"
\\`\\`\\`
`,
  refs: {
    'examples.md': `# Examples\n\nMore prose...`
  }
}
```

### 2. (For optional) add to `OPTIONAL_SKILLS` array

In CONSTANTS, the `OPTIONAL_SKILLS` array carries the wizard label
and one-line description. Match the key.

```js
{ key:'naming-conventions', label:'Naming conventions',
  desc:'Kebab-case files, camelCase variables, etc.' },
```

### 3. Body authoring tips

- **Backticks must be escaped** as `\\`` inside the template literal.
  The `unescapeBackticks()` post-processor flips them back.
- **Use `{{ tokens }}`** (without the spaces in real usage) for
  project name, agent names, vocab words. See `subVars()` for the
  full token list.
- **Reference files** are siblings under `references/`. Link them
  from the body as `[references/example.md](references/example.md)`.
- **Frontmatter** is automatic — `fm()` builds it from `desc` and `use`.

### 4. Verify

```bash
node --check /tmp/fc.js
node /tmp/fleet_e2e_v2.mjs
```

Then download a fleet, unzip, and inspect `cli/skills/<name>/SKILL.md`
to confirm the body rendered correctly.

### 5. Commit

```
feat(generator): add <name> skill
```
