# Mission: Example — Add a Hello Endpoint

## Context

This is an example mission file showing the format the worker
expects. Replace this content with a real task before launching.

## Files to Modify

| File | Change |
|---|---|
| src/routes/hello.ts | Create new file: handler returning "Hello, world." |
| src/routes/index.ts | Register the new `/hello` route |
| README.md | Document the new endpoint under "API" |

## Files NOT to Modify

- src/auth/**
- src/database/**
- Anything in tests/ except tests for the new route

## Implementation Parts

### Part 1 — Create the handler

Create `src/routes/hello.ts` with a function that returns "Hello, world."

**Commit:** `feat(routes): add hello handler`
→ verify: file exists, exports a default handler

### Part 2 — Register the route

Open `src/routes/index.ts` and register `/hello`.

**Commit:** `feat(routes): register /hello route`
→ verify: `curl localhost:3000/hello` returns "Hello, world."

### Part 3 — Document

Update README.md under the "API" section.

**Commit:** `docs(readme): document /hello endpoint`

## Test Requirements

- New unit test for the hello handler
- All existing tests still pass

## Verification

1. Run the test suite — all green
2. Start the dev server. Hit `/hello`. Expect "Hello, world."
3. Read `git log --oneline` — three commits, one per Part

## Success Criteria

- [ ] All three Parts committed
- [ ] Tests pass
- [ ] README updated
- [ ] No files outside the list above were modified
