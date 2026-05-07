# Blast Radius Report Template

Write to `docs/blast_radius/<mission-id>_BLAST_RADIUS.md`.
Commit before any production change.

```markdown
# Blast Radius Report — <mission-id>

**Baseline:** test pass count at mission start: NNN
**Mission:** <mission title>

## Symbol 1: <full.symbol.path>

**Change class:** rename / signature / removal / deprecation / semantic
**Scope:** public / internal / private

### Grep results

| File | Line | Classification | Justification (INTENTIONALLY_LEFT only) |
|---|---|---|---|
| src/foo.ts | 42 | MUST_UPDATE | |
| src/bar.ts | 87 | INTENTIONALLY_LEFT | Local var in unrelated sort comparator |
| tests/foo.test.ts | 15 | MUST_UPDATE | |

### Summary
- MUST_UPDATE: N sites
- INTENTIONALLY_LEFT: M (all justified)
- RESCOPE_REQUIRED: P (if P > 0, mission blocks)

## Symbol 2: ...
```

Commit message:

```
docs(blast-radius): <mission-id> — call-site enumeration

MUST_UPDATE: N sites. INTENTIONALLY_LEFT: M (justified).
RESCOPE_REQUIRED: P.
```
