# Language-Specific TDD Notes

## TypeScript / JavaScript (Jest, Vitest, Mocha)

```bash
# Run a single test
npm test -- --testPathPattern=foo  # or vitest run foo
# Watch mode for fast RED→GREEN
npm test -- --watch
```

Test file convention: `<src>.test.ts` next to the source, or
`__tests__/<src>.test.ts` in a sibling directory.

## Python (pytest)

```bash
pytest tests/test_foo.py::test_specific_behavior -x
pytest tests/ --tb=short
```

Test files mirror source: `src/foo.py` → `tests/test_foo.py`.

Use `@pytest.mark.parametrize` for table-driven tests.

## Swift (XCTest, swift-testing)

```bash
swift test --filter YourTestName
```

Tests live in `Tests/<Module>Tests/` mirroring `Sources/`.

## Go (go test)

```bash
go test -run TestSpecificBehavior ./pkg/foo
```

Test files: `<src>_test.go` next to the source.

## Deterministic time

Functions that depend on time should accept a clock or `now`
parameter. Tests pass a fixed value. Never call `Date.now()` or
`time.Now()` directly without a default-parameter override.

## Don't mock what you can construct

Plain data objects, simple callables, value types — construct them.
Reserve mocks for: network, filesystem, time, randomness.
