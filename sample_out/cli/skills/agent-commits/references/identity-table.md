# Full Identity Table

## When in doubt about identity

- **Doing your normal job** → use your own identity
- **Acting as another agent's body** (e.g., Hobbes commits the
  worker's work because the worker can't run commits) → use the
  identity of whose work it is, not the body's. The worker's work
  commits as the worker even if Hobbes ran the command.
- **Cleaning up something a human did** → don't. Humans clean up
  after humans.
- **Genuinely unclear** → use the orchestrator identity (hobbes)
  and add a note in the commit body explaining what was done.

## Verifying identity at commit time

```bash
git log -1 --format='%an <%ae>'
```

Output should match the identity table for the agent who did the work.

## Pre-receive hook (optional, future)

A pre-receive hook can verify commits to certain branches use the
expected identity. For example: commits to the worker's feature
branches must come from woodstock or the human; commits to docs
folders must come from linus or hobbes.

This is not shipped by default — discipline first, automation if
discipline slips.
