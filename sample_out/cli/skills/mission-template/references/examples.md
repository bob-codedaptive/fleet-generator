# Mission Examples

## Example 1 — Tier 1: primitive touch (3 files)

```markdown
# Mission: Make User.email optional

## Context

We're adding social login. Some social providers don't return email,
so the User type must accept email as optional. Touches a primitive
type used in 12 call sites; blast-radius pre-flight required.

## Blast Radius Scope

**Symbols being changed:**
- `User.email` — type `string` → `string | undefined`

## Files to Modify

| File | Change |
|---|---|
| src/auth/user.ts | Type change |
| src/auth/validation.ts | Handle undefined email |
| src/auth/__tests__/user.test.ts | Update tests |

## Files NOT to Modify
- src/billing/**
- src/admin/**

## Implementation Parts

### Part 1 — Update User type

In `src/auth/user.ts`, change `email: string` to `email?: string`.

**Commit:** `feat(auth): make User.email optional`
→ verify: type-check passes, no errors in other modules

### Part 2 — Update validation

In `src/auth/validation.ts`, handle the undefined case.

**Commit:** `feat(auth): validation handles undefined email`
→ verify: validation tests still green

### Part 3 — Update tests

Update `user.test.ts` to cover the undefined case.

**Commit:** `test(auth): cover optional email`
→ verify: full test suite green

## Test Requirements
- New test: User with no email validates successfully
- Existing tests unchanged

## Verification
- `npm test` exits 0
- `tsc --noEmit` exits 0

## Success Criteria
- [ ] All 3 Parts committed
- [ ] Tests pass with email-optional user
- [ ] No call sites broken outside the listed files
```

## Example 2 — Tier 3: net-new feature

```markdown
# Mission: Add health-check endpoint

## Context

Add a `/health` endpoint that returns 200 OK with build info.
All-new files. No edits to existing code.

## Files to Modify

| File | Change |
|---|---|
| src/routes/health.ts | New file: handler |
| src/routes/__tests__/health.test.ts | New file: tests |
| src/routes/index.ts | Register the new route |

## Files NOT to Modify
- src/auth/**
- src/database/**

## Implementation Parts

### Part 1 — Create handler

```typescript
// src/routes/health.ts
export const healthHandler = (_req, res) => {
  res.status(200).json({ status: 'ok', version: process.env.BUILD_ID });
};
```

**Commit:** `feat(routes): add health handler`
→ verify: file exists, exports default handler

### Part 2 — Tests

```typescript
// src/routes/__tests__/health.test.ts
test('GET /health returns 200', async () => { ... });
```

**Commit:** `test(routes): cover health endpoint`
→ verify: tests pass

### Part 3 — Register

In `src/routes/index.ts`, add `router.get('/health', healthHandler)`.

**Commit:** `feat(routes): register /health`
→ verify: `curl localhost:3000/health` returns 200

## Test Requirements
- New test: GET /health returns 200 with status field

## Verification
- `npm test` exits 0
- `curl http://localhost:3000/health` returns 200

## Success Criteria
- [ ] All 3 Parts committed
- [ ] /health responds 200
- [ ] No existing files modified except routes/index.ts
```
