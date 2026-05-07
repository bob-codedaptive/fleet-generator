# Version Bumping Examples

## Patch bump (v0.8 → v0.8.1)

A new field added to the API response. Existing readers still work,
but the doc needs to record the new field.

```
docs(api): v0.8 → v0.8.1 — document new `createdAt` field
```

## Minor bump (v0.8 → v0.9)

A section rewrite — the same information presented more clearly,
or new material that doesn't break existing references.

```
docs(user-guide): v0.8 → v0.9 — rewrite "Getting Started"
```

## Major bump (v0.8 → v1.0)

Structural change — sections reordered, terminology changed,
backward-compatibility broken in a way readers will notice.

```
docs(schema): v0.8 → v1.0 — rename `User` → `Account` throughout
```

## No bump

Typo fix. Cross-reference correction. Update the `updated:`
frontmatter if you have one; that's it.

```
docs(api): typo in section header
```

## Bad example — code without doc

```
feat(api): add createdAt to user response

Shipped the field. Will document later.
```

→ Rejected at post-flight. The doc lives next to the code, not
"later." Garfield bounces the commit; worker amends with the doc
update.
