---
name: self-review
description: >-
  Final-commit quality gate before Garfield runs — mission spec match, scope check, formatting-noise revert, accessibility check, orphan-code detection, secrets scan.
when_to_use: >-
  After the final commit of a mission and before signaling completion. Verifying the diff matches the mission's 'Files to Modify' list. Sweeping for bridge helpers, orphan deprecation markers, and same-symbol TODOs. Final pass before declaring done. Trigger phrases: self-review, run self-review, final-commit verification, scope creep, formatting noise, orphan code, bridge helper, secrets check, check my work.
status: active
tags: [skill]
updated: 2026-05-07
---

# Self-Review Protocol

Run after the last `git commit` and BEFORE declaring the mission
complete. Self-review is a quality gate, not a reporting exercise.
If you find a problem, fix it before declaring done.

## Step 0: Mission scope correspondence

```bash
git diff --name-only <base>..HEAD > /tmp/diff_files.txt
```

For every file in the mission's "Files to Modify" list:
- [ ] The file appears in `/tmp/diff_files.txt`

For every file in `/tmp/diff_files.txt`:
- [ ] The file is in the mission's "Files to Modify" list, OR is a
      blast-radius / scoping artifact you produced

If any listed file is missing from the diff: touch it OR amend the
mission file to declare it intentionally untouched, with reason.
If any file in the diff is not listed: revert it OR add it to the
mission with justification.

## Step 1: Read the full diff

```bash
git diff <base>..HEAD
```

Read every line. Not skim — read.

## Step 2: Scope creep

For each changed file: am I "improving" something I wasn't asked to
improve? If so, revert it.

## Step 3: Formatting noise

```bash
git diff --ignore-all-space <base>..HEAD
```

Revert formatting-only changes that aren't part of the mission.

## Step 4: Accessibility (UI missions)

Every new interactive element needs an accessible label, keyboard
support, and adequate touch / contrast.

## Step 5: Orphan code

Helpers with no callers. Imports nothing uses. Bridge functions named
`legacy*` or `compat*`. Orphan deprecation markers without a queued
removal. TODO / FIXME on the same symbols the mission is changing.

See [references/orphan-patterns.md](references/orphan-patterns.md).

## Step 6: Secrets

```bash
git diff <base>..HEAD | grep -iE 'api.?key|secret|password|token|sk-ant'
```

If anything appears, stop and remove it.

## Step 7: Write the review summary

```markdown
## Self-Review

- Files changed: N
- Lines added: N, removed: N
- Scope: all within mission scope
- Accessibility: all interactive elements labeled
- Secrets: none found
- Orphan code: none
- Prohibited patterns: none
```

Hand off to Garfield.
