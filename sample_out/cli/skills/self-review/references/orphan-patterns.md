# Orphan-Code Patterns

These patterns slip through code review more often than you'd think.

## Helpers without callers

A helper added "to make the change cleaner" that nothing calls.
Either it should be called, or it shouldn't exist. Delete it.

## Imports nothing uses

Editor auto-import or paste-then-edit. Run the linter / unused-import
check before commit.

## Bridge functions

Functions named to preserve old behavior alongside new behavior.
`getUserOld()`, `renderLegacy()`. If the migration is in scope,
do the migration. Don't keep the bridge.

## Orphan deprecation markers

`@available(*, deprecated)`, `@Deprecated`, or equivalent on a
symbol with no follow-up removal queued. The deprecation creates
debt; the removal pays it. Don't deprecate without queuing the pay.

## Same-symbol TODOs

`// TODO: handle the empty case` added to the very function the
mission was supposed to handle. Either fix it now or document why
it's deferred to a specific named follow-up.

## Tests for code that isn't there

Tests that import a symbol that no longer exists — compile fails or
test silently skips. Either delete the test or restore the symbol.
