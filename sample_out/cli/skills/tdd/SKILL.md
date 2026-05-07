---
name: tdd
description: >-
  Test-driven development discipline on fleet-generator — RED → GREEN → REFACTOR → COMMIT cycle, never write production code without a failing test first.
when_to_use: >-
  Implementing or modifying a public function with a test harness. Adding a new behavior. Mission spec calls for test-first work. Trigger phrases: TDD cycle, RED GREEN REFACTOR, write the test first, test-first, test-driven, exit 0, baseline test count.
status: active
tags: [skill]
updated: 2026-05-07
---

# Test-Driven Development

Any time you are writing or modifying production code in fleet-generator
where a test harness exists. RIGID — follow exactly.

## When this skill applies

- Public functions in any module with a test runner
- New behaviors being added to existing functions
- Bug fixes (write the failing test first)

Does NOT apply to:
- View / UI components (test through the layer that exercises them)
- Documentation-only changes
- One-off scripts, configuration files
- Hook scripts (no unit harness)

## The cycle: RED → GREEN → REFACTOR → COMMIT

### Step 1: RED — write the test FIRST

Before writing any implementation code, write a test that describes
the behavior you want.

```
# Run the test runner. Watch it fail.
<your-runner> path/to/new.test.ext
```

If it doesn't fail, your test is wrong — it's testing something that
already exists.

A test that passes before the code is worthless.

### Step 2: GREEN — write the MINIMUM code to pass

Simplest possible implementation. Don't write extra code. Don't
optimize. Don't handle edge cases you haven't tested.

Run the runner. Watch it pass. If it doesn't pass, fix the
implementation — not the test.

### Step 3: REFACTOR — clean up without changing behavior

Extract helpers. Rename variables. Reduce duplication. Run the
runner after every change. Tests stay green throughout refactoring.

### Step 4: COMMIT

One test + one implementation + one refactor = one commit.

```
feat(<scope>): <behavior> — N tests passing
```

### Step 5: REPEAT

Next behavior → next test → next implementation → next commit.

## What NOT to do

- Don't write implementation first and tests second. Tests written
  after the code confirm bugs instead of catching them.
- Don't write 10 tests then 10 implementations. One cycle at a time.
- Don't skip the RED step. If you can't make a test fail first, you
  don't understand the behavior you're implementing.
- Don't mock what you can construct. Mocks are for external
  dependencies (network, filesystem). Construct real objects when
  construction is cheap.
- Don't test private methods. Test the public interface.

For language-specific patterns, see
[references/language-matrix.md](references/language-matrix.md).
