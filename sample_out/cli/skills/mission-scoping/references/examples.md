# Mission Scoping — Worked Examples

## Tier 1 at cap (3 files, primitive)

```
Mission: Make User.email optional
- src/types/user.ts        ← primitive (User type)
- src/auth/validation.ts   ← consumes User.email
- tests/user.test.ts
```

3 files. User type is a primitive. At the cap. Adding any 4th file
forces RESCOPE_REQUIRED.

## Tier 2 within cap (5 files, UI-bounded)

```
Mission: Add date filter to InvoiceList
Bounded by: InvoiceList component
- src/components/InvoiceList.tsx
- src/components/InvoiceListFilters.tsx
- src/components/__tests__/InvoiceList.test.tsx
- src/styles/InvoiceList.module.css
- src/components/InvoiceListEmpty.tsx
```

5 files, all within the InvoiceList cluster. Within Tier 2 cap.

## Tier 3 no cap (15 new files)

```
Mission: Add analytics module
- src/analytics/index.ts (new)
- src/analytics/events.ts (new)
- ... 13 more new files
- src/index.ts                    ← edits existing!
```

The single existing-file edit disqualifies Tier 3. Either move the
`src/index.ts` edit to a follow-up mission (recover Tier 3) or
classify as atomic exception with justification.

## Atomic exception

```
Mission: Migrate User schema (atomic)
Atomic justification: schema + repository + DTO + validator must
update together or the build is broken.
- prisma/schema.prisma
- src/repos/user.ts
- src/dto/user.ts
- src/validators/user.ts
- tests/user.repo.test.ts
```

5 files, primitive touched, but atomic. Cap doesn't apply because
splitting breaks the build mid-migration.
