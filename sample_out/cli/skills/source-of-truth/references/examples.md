# Canon Conflict Examples

## Example 1 — schema vs implementation

Canon: `schemas/user.json` says email is required.
Implementation: `User` type has email as optional.

Wrong move: silently update schemas/user.json to match the code.
Right move: stop, ask the human which one is correct, then update
the loser in the same commit as the discovery.

## Example 2 — two competing docs

`docs/api.md` says POST /users returns 201.
`docs/openapi.yaml` says POST /users returns 200.

Wrong move: pick one and silently update the other.
Right move: figure out which is canonical (probably openapi.yaml in
this case), mark it as such in CLAUDE.md, update the other to point
to it: "Authoritative spec lives in openapi.yaml."
