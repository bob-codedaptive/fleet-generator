# Pre-Commit Worked Examples

## Example 1 — clean commit (Part 2 of 4 in a mission)

```
$ git diff --name-only
src/parser/tokens.ts
src/parser/__tests__/tokens.test.ts
$ npm test 2>&1 | tail -5
Test Suites: 12 passed, 12 total
Tests:       148 passed, 148 total
$ git log --oneline -1
abc1234 feat(parser): handle escaped quotes in token stream
```

Both files in scope. Test count up by 3 from baseline. Identity set.
Commit message follows format. Ship it.

## Example 2 — caught at scope check

```
$ git diff --name-only
src/parser/tokens.ts
src/parser/__tests__/tokens.test.ts
src/style/colors.ts          ← not in mission
```

`colors.ts` is not in the mission. Two options: revert
(`git checkout -- src/style/colors.ts`) or expand the mission via
the orchestrator. Don't commit it through under the parser commit.

## Example 3 — tests didn't actually run

```
$ npm test 2>&1 | tail
TypeError: Cannot find module '@/parser'
$ echo $?
1
```

Exit 1. The test suite didn't compile. "Tests pass" is not true.
Stop. Fix the import. Re-run. Verify exit 0 before committing.
