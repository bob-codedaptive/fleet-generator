# Mission Section Guide

## Header

```markdown
# Mission: [Title]
```

A title. One line. Specific enough to identify the work.

## Context

Background, rationale, references to prior decisions or designs.
Why is this work happening now? What is the user-visible outcome?
Two to four short paragraphs. Not a novel.

## Read First (optional)

Files or docs the worker should read before writing code. Use this
when a doc is necessary for understanding but isn't obvious from the
mission's prose.

```markdown
## Read First
- docs/architecture/auth.md
- src/auth/types.ts
```

## Blast Radius Scope (when touching existing code)

When the mission modifies, removes, renames, or changes the
semantics of an existing symbol, declare the scope here.

```markdown
## Blast Radius Scope

**Symbols being changed:**
- `User.email` field — type changed from string to optional string
- `validateUser()` — signature changed to accept partial user

**Expected blast radius:**
- Production code: ~6 sites
- Tests: ~3 files
- Docs: README §"User Model"
```

The worker runs the `blast-radius` skill to produce the
authoritative report. The mission's estimate is just a target.

For purely additive missions, omit this section.

## Files to Modify

Exact paths. Table format. The pre-flight scanner uses this as
scope; the reviewer uses the diff as scope. They must match.

```markdown
| File | Change |
|---|---|
| src/auth/user.ts | Add optional email field |
| src/auth/__tests__/user.test.ts | Update tests for optional email |
```

## Files NOT to Modify

Explicit exclusion list. Anything sensitive, anything out of scope,
anything that another agent owns.

## Implementation Parts

Numbered. Each Part = one logical change = one commit.

```markdown
### Part 1 — Update the type

In `src/auth/user.ts`, change `email: string` to
`email?: string`.

**Commit:** `feat(auth): make email optional on User`
→ verify: build succeeds, no other type errors introduced
```

## Test Requirements

Specific tests to write or modify. The minimum behavior to verify.

## Verification

Observable checks. Build commands, test commands, manual checks.
Specific enough that the worker knows what passing looks like.

## Success Criteria

Observable behaviors, not "it works."

```markdown
- [ ] All Parts committed
- [ ] All tests pass
- [ ] No files outside the list above were modified
- [ ] README updated to mention the optional email field
```
