---
name: pre-commit
description: >-
  Mandatory pre-commit checklist for Woodstock streams — scope check, identity check, test verification, anti-pattern detection, and the type(scope): description commit-message format.
when_to_use: >-
  About to run git commit. Mid-mission verification before each Part's commit. Verifying that tests pass with real exit-0. Checking for prohibited bridge / shim / orphan-deprecation patterns. Final check before declaring a Part done. Trigger phrases: ship a commit, land the commit, run the pre-commit checklist, identity check, scope check, anti-pattern detection, formatting noise, type(scope) commit message.
status: active
tags: [skill]
updated: 2026-05-07
---

# Pre-Commit Verification

Before EVERY `git commit`. No exceptions. Run through this checklist
mechanically. If any item fails, fix it before committing.

## 1. Am I in the right place?

```bash
pwd
git branch --show-current
```

- [ ] I am on the correct branch for this mission
- [ ] The branch name matches the mission

## 2. Does it build / lint?

Run the project's build or lint command.

- [ ] Zero build errors
- [ ] Zero lint errors

## 3. Do tests pass?

This is a verification gate, not a checkbox.

- [ ] The test runner was actually invoked (not skipped)
- [ ] Exit code is 0
- [ ] Pass count is at or above the baseline recorded at mission start
- [ ] Zero test failures
- [ ] Tail output captured to the completion notes (verbatim)

If the test runner does not exit 0, you do not commit. Garfield
re-verifies this claim in post-flight. Reports claiming tests pass
without genuine output are CRITICAL findings.

## 4. Is my identity set?

```bash
echo $GIT_AUTHOR_NAME
echo $GIT_AUTHOR_EMAIL
```

- [ ] Author identifies the agent making the commit (see `agent-commits` skill)

## 5. Did I only touch what the mission says?

```bash
git diff --name-only
```

- [ ] Every changed file is within mission scope
- [ ] For missions touching existing code: every file in the diff is
      either listed in the mission's "Files to Modify" list or is a
      blast-radius report

## 6. No prohibited patterns?

See [references/anti-patterns.md](references/anti-patterns.md). The
short list:

- No `legacy*` / `compat*` named functions that shim old behavior
- No `@available(*, deprecated)` (or equivalent) without a queued removal
- No TODO / FIXME on the same symbols the mission is changing
- No debug print statements / `console.log`
- No secrets, API keys, or credentials in the diff

## 7. Is the commit message correct?

Format: `type(scope): description`
Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

- [ ] Message follows the format
- [ ] Description is specific, not vague

## After committing

```bash
git log --oneline -1
```

Verify the commit landed with right author and message.

## If a check fails

Do NOT commit with a known failure. The checklist exists because
"fix later" means "never."
