# Six Forbidden Responses to Blast Radius

When the worker hits a RESCOPE_REQUIRED, the WRONG response is one
of these six. Each is a CRITICAL finding in post-flight.

## 1. Bridge / shim helpers

Adding a function that wraps the old behavior so call sites don't
need to change. Defers the work; doesn't do it.

## 2. Orphan deprecation

`@deprecated` on the symbol with no removal queued. Creates debt
without paying it.

## 3. Silenced warnings

Suppress the compiler warning that would have caught the breakage.

## 4. Partial migration

Update the call sites that "really matter," leave the rest. Now the
codebase is in two states permanently.

## 5. Renaming the new thing instead

Old symbol stays. New symbol gets a slightly different name. Both
exist. No migration. This is bridges-by-other-means.

## 6. "Pre-existing, out of scope"

The classification used to skip MUST_UPDATE sites of the same
symbol. There is no such escape hatch. Same symbol → same scope.
Either rescope the mission or stop.
