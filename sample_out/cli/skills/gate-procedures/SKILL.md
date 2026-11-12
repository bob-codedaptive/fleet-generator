---
name: gate-procedures
description: >-
  How a reviewer decides whether a change is proven - who runs the tests, running the artifact, the three written checks, one severity scale, when FAIL is right, and report and stop.
when_to_use: >-
  Reviewing a returned diff. Deciding whether a test gates the change it claims to. Writing a PASS or FAIL. A change claims to be already fixed. Judging whether a green suite is evidence.
status: active
tags: [skill]
updated: 2026-11-12
---

# Gate procedures

How a reviewer decides whether a change is proven. The reviewer's agent
file says which gate it runs; this says how. Where the two seem to
disagree, the agent file wins: say so in your report.

## Who runs what

The worker runs the tests and pastes the command and the last lines of
its output; the coordinator runs the request check. The reviewer reads
that output and does not re-run the suite: a second full run proves
nothing the first did not, and it takes the machine from everyone else.
Run one test only to settle a doubt the diff raises, and say which.

A pass claim with no pasted output is a finding. Output that contradicts
the code is a finding, quoting the failing line.

## Run the artifact

A green suite is not evidence. Measured across eight parallel
implementations of one identical task: every code review passed, and two
of the resulting binaries crashed on ordinary input. A script that built
and ran each artifact found six of the eight failures in seconds.

When the artifact is executable, build it and run it once on ordinary
input before you read the diff.

## Three checks, every review

Do each check and write its result. Each has a yes or no answer and a
fixed consequence.

1. **Would the test fail if the code were wrong?** For every assertion the
   diff adds or changes, name one wrong output the code could produce and
   say whether the assertion fails on it. An assertion that still passes
   on a plausible wrong output (a contains that also matches the broken
   form, a count with no content check, a bound wide enough for the old
   behaviour) proves nothing: FAIL, reason evidence-missing, with the
   wrong output it lets through. A new test the worker did not show
   failing before the fix is the same finding.
2. **Is every checkable claim in a changed comment true?** A comment or
   doc line in the diff that states a count, an order, a range, a unit or
   a reference: open what it cites or the code it describes and check it.
   False: FAIL, reason comment-false, quoting the claim and what the
   source says.
3. **Is every item of the mission's done list done?** List the done items
   one by one: done (with the file:line or output that shows it) or
   missing. A missing item: FAIL, reason code-wrong.

Write them after the verdict line as:

    Checks: assertions <n checked, n weak>; claims <n checked, n false>; done list <n of m>

## Read what the test asserts, not what it is named

A test named testDeletionRemovesRow that asserts "no row with the flag
set" passes when the flag is cleared and the row survives, still holding
the data that was supposed to be deleted. The name says deletion; the
assertion says flag.

Where the property is a side effect, the assertion has to reach the side
effect. Asserting on a return value is not asserting on what persisted.

## Inherited verdicts are claims, not facts

A change that says "already fixed by X" is offering a conclusion someone
else reached. Check it. In one case the earlier fix covered only the
wholesale path while the per-item path never reached it. Taking the claim
would have closed a live defect twice.

## Verdicts

- **PASS**: the change does what the mission asks and its tests prove it.
- **PASS WITH FINDINGS**: it can merge; the findings are listed for the
  worker to weigh.
- **FAIL**: one or more findings at severity 1 or 2.

The first line of your return is the verdict, written as VERDICT: PASS,
VERDICT: PASS WITH FINDINGS or VERDICT: FAIL. A hook reads that line.

## One severity scale, every reviewer

- **1**: wrong behaviour a user can reach, a secret exposed, or something
  exploitable now.
- **2**: a real defect: a test that cannot fail, a missing test for
  changed behaviour, a missing done item, a false comment or contract
  line, a check that is missing or broken.
- **3**: everything else worth saying: hardening, a clearer name, a note
  for another owner. Never blocks.

Not a FAIL: style you would prefer, work outside the mission, how the
evidence was formatted, and a finding you are not sure of (report it with
your confidence instead).

## Each finding

The file:line, the severity, what is wrong, what correct looks like, and
one line Reason: with exactly one of code-wrong (the code does not do what
the mission asks), comment-false (the code is right and a comment or doc
says otherwise), evidence-missing (the code may be right and no test
proves it) or needs-ruling (the mission is ambiguous or conflicts with a
rule). Report every finding, including uncertain ones, with your
confidence: the worker decides what to fix first.

After the verdict, one line: Reasons: <value> <count>, ... or Reasons: none.

## Report and stop

One review, then stop. Do not start extra rounds or other reviewers, and
do not edit: rework is the worker's, and an edit by the reviewer would
land unreviewed. When you are resumed to re-review, read the diff since
your last review and say for each earlier finding: fixed, not fixed, or
moved.

If the same finding has gone back and forth three times, stop and return
both positions plainly to the person above you.
