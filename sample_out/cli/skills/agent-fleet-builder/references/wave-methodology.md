# Wave Methodology

## Wave principles

1. **Each wave has a single primary metric.** Wave success is binary
   against that metric. Auxiliary changes ride along, but the wave's
   gate is the primary metric.

2. **Diagnostic before improvement.** When a current-state metric is
   anomalous (zero hooks deployed, broken auto-load, etc.), spend a
   wave understanding *why* before changing anything. The most
   expensive refactor is the one based on a wrong mental model.

3. **Bespoke probe per wave; full integration test per phase.**
   Bespoke probes exercise just the new mechanism the wave introduced,
   so iteration is fast. Full integration tests run at phase boundaries
   to catch regressions across waves.

4. **Iteration within a wave is allowed and expected.** A wave may
   take 2 attempts, 5 attempts, 10 attempts to land its metric. The
   wave doesn't advance until the metric passes. This is more important
   than schedule.

5. **Bounded retry, then escalate.** Each wave declares max-attempts
   (typically 3–5). If the wave can't land in that many attempts,
   escalate: the metric may be wrong, the mechanism may be
   misunderstood, or there's a hidden dependency. Don't push past the
   bound.

6. **Phase grouping for full-test boundaries.** Group waves into phases
   (typically 2–4 waves per phase). At each phase boundary, run the
   full integration test before advancing. Catches integration
   regressions.

7. **Each wave produces a wave report** capturing what was attempted,
   what was measured, and what was learned.

## Wave shape

```markdown
# Wave N — <category>

## Primary metric
<single binary measurable target>

## Within-wave iteration mechanic
<what to try first; what to try if first attempt fails;
 max attempts before escalation>

## Bespoke probe
<small targeted test that exercises just this wave's changes>

## Success criteria
<what "wave passed" means>

## Phase membership
<which phase this wave belongs to;
 what full-test runs before advancing to the next phase>

## Dependencies
<prior waves that must complete first>

## Wave report (filled in at end)
<attempts, measurements, lessons>
```

## Bespoke probe vs full integration test

A bespoke probe should:
- Exercise only the new mechanism the wave introduced
- Run in 5–15 minutes (so iteration within the wave is fast)
- Have a clear binary pass/fail
- Not require subagent spawns unless the wave is about subagent
  spawn behavior

A full integration test should:
- Exercise the entire fleet end-to-end
- Run at phase boundaries (every 2–4 waves)
- Take 30–60 minutes; produce a comprehensive report
- Catch cross-wave regressions
