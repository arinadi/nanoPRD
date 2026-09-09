# Agent Directive: [Project Name]

> Written by nanoPRD Phase 4. Hand this file to your coding agent.
> Acceptance criteria live in `VERIFY.md`. Do not edit that file.

## Role

You are implementing [project]. The plan is complete. Your job is to execute it
one nanotask at a time, not to redesign it.

If you find a genuine problem with the plan, stop and report it. Do not route
around it silently.

## Reading order

Read these in order. Do not read the whole plan up front - it fills your context
before any work starts.

| When | Read |
|---|---|
| Once, at the start | `PRD.md`, `architecture.md` |
| Once, at the start (UI modes) | `design.md` |
| At the start of every session | `meta/progress.json` - what is still failing |
| Before each nanotask | `tasks/NN-*.md` or `tasks/NN.M-*.md` for that nanotask only |
| Before each nanotask | The code produced by the nanotasks it depends on |
| As needed | `reference/` for API and library documentation |
| Never | `meta/context.md` - Phase 0 provenance, not implementation input |

## The ledger

`meta/progress.json` holds one entry per nanotask. **Every entry starts
`"status": "failing"`.** That is the work list: these are the things that must
become true.

- Flip an entry to `passing` only when every acceptance check in that nanotask file
  passes. Updating the ledger is part of finishing a nanotask, not an afterthought.
- Set `blocked` with a reason rather than skipping an entry.
- Never delete an entry, and never edit a `behavior` string. That would redefine
  what you were asked to build.

## Context recovery

**Before starting a nanotask, re-read the code produced by the nanotasks it depends
on. Do not rely on your memory of code you wrote earlier in this session.**

Twenty turns into an implementation, your memory of what you built is compressed
and lossy. You will re-implement a helper you already wrote, use an old function
signature, or duplicate a type. Re-reading costs a few thousand tokens. Not
re-reading costs a rewrite.

## Conventions

*Where code goes, how files are named, how modules are structured. An agent that
guesses will guess differently each time.*

| Concern | Convention |
|---|---|
| Source layout | |
| File naming | |
| Test location | |
| Imports | |

## Data initialization

*Migrations, seed data, fixtures, environment variables and where their values come
from. Never put actual secret values in this file.*

## Validation commands

| Check | Command |
|---|---|
| Lint | |
| Typecheck | |
| Test | |
| Build | |
| Dependency audit | |

## Per-nanotask loop

1. Read the nanotask file and the code it depends on.
2. Implement. Stay inside the stated behavior - the "Out of scope" section is
   binding.
3. Run every validation command.
4. Run the nanotask's acceptance checks.
5. Self-reflect (below).
6. Flip the ledger entry in `meta/progress.json` to `passing`.
7. Stop and request review. Do not start the next nanotask.

Nanotasks are numbered `NN` (a whole behavior) or `NN.M` (one increment of one).
Work them in numeric order, major first and minor second. A behavior split into
minors is not done until every minor under it passes - do not report the behavior
complete at `03.1` when `03.2` and `03.3` remain.

## Self-reflection

Before requesting review, check your own work for:

- Logic duplicated from a dependency nanotask
- Missing input validation on anything crossing a trust boundary
- Missing error handling on any call that can fail
- Secrets, tokens, or credentials in source
- Unhandled failure paths - what happens when the network call times out

## Acceptance gate

A nanotask is done when every validation command passes, every acceptance check in
its file passes, and the dependency audit reports no high or critical findings.
Not before.

## Failure protocol

Maximum three attempts at the same failing check.

After the third, stop. Revert the working tree to the last good state. Report what
you tried, what failed, and what you need. Grinding on attempt seven produces
damage, not progress.

## Evaluation loop

Every three nanotasks, pause and check the whole system against `PRD.md` rather
than against the individual nanotask. Drift accumulates below the threshold of any
single check.
