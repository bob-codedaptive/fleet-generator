# NexusMCP Tool Reference

## Search

```
nexus_search(query, wing?, limit?)
```

Semantic search over indexed content. Returns drawers (verbatim
atoms) and KG facts.

## Knowledge graph

```
nexus_kg_add(subject, predicate, object, reason?)
nexus_kg_query(subject?, predicate?, object?)
nexus_kg_invalidate(fact_id, reason)
nexus_kg_timeline(subject)
```

Facts are temporal. `invalidate` doesn't delete — it marks the
fact as superseded so the timeline stays intact.

## Diary

```
nexus_diary_read(limit?, since?)
nexus_diary_write(topic, entry)
```

Append-only narrative log. Use for session summaries and decisions
that don't fit the KG triple shape.

## Status

```
nexus_status()
```

Returns connection status, drawer counts, last update. Run at
session start to confirm the palace is alive.

## When in doubt

The palace is hint, not authority. Filesystem wins. If the palace
disagrees with reality, the palace is wrong — invalidate the stale
fact and move on.
