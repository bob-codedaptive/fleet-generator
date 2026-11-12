# Anti-Patterns to Reject Before Committing

These patterns appear when scope pressure tempts the worker into a
shortcut. Reject them in pre-commit; Marvin catches them in
post-flight as CRITICAL findings.

## 1. Bridge / shim helpers

Functions named `legacy*`, `compat*`, `oldX`, or `bridgeY` that
preserve the old behavior to avoid completing the migration. If the
mission is to migrate, migrate. Don't ship the bridge.

## 2. Orphan deprecation markers

`@available(*, deprecated)`, `@Deprecated`, or equivalent on a
symbol with no follow-up removal queued. Either remove the symbol now
(if scope allows) or split into two missions: deprecate-then-remove,
with the removal queued before this mission lands.

## 3. Same-symbol TODOs

A TODO/FIXME added to the very symbol the mission is changing. If
the work is in scope, do it now. If it's out of scope, the TODO
documents avoidance, not progress.

## 4. Silenced warnings

Compiler warnings on changed code that the mission was supposed to
fix, but were suppressed instead. The pattern: warning fires →
mission claims to address it → diff shows the warning silenced or
the call site cast away. Reject.

## 5. Partial migrations

Half the codebase migrated, half left on the old pattern. If the
blast radius exceeds the scope, the mission must split — never
ship partial.

## 6. "Tests pass" without proof

A completion claim of "tests pass" with no test-runner output and no
exit code recorded. Marvin reads the pasted output; a claim with no
output, or output that shows the suite did not run or did not exit 0, is
a finding.
