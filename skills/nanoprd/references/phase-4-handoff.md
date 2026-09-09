# Phase 4 - Handoff

**Goal:** Produce `AGENT.md`, the directive the implementing coding agent runs
against, and `VERIFY.md`, the contract that decides whether its work is accepted.

Use `templates/AGENT.md` and `templates/VERIFY.md`.

Phase 4 writes no new requirements. If you find yourself deciding something here
that belongs in the PRD or the architecture, stop - it means an earlier phase left
a gap, and the right fix is to name it rather than to quietly settle it in the
handoff document.

---

## Context recovery - the rule that matters most

Include this in `AGENT.md` explicitly:

> Before starting a nanotask, re-read the code produced by the nanotasks it depends
> on. Do not rely on your memory of code you wrote earlier in the session.

An agent twenty turns into an implementation has a compressed, lossy memory of what
it built. It will re-implement a helper it already wrote, use an old function
signature, or duplicate a type. Re-reading the dependency code costs a few thousand
tokens. Not re-reading costs a rewrite.

---

## `AGENT.md` - mandatory sections

**Role and context.** What the agent is building, in two sentences. Which documents
to read, in what order.

**Tools and capabilities.** Which tools the agent needs and what each is for. If a
tool is unavailable, what to do instead.

**Context links.** Relative paths to `PRD.md`, `architecture.md`, `design.md` where
one exists, `tasks/`, and `reference/`. Say when to read each. "Read the whole plan
first" is bad advice - it fills the context window before any work starts.

**Data initialization.** How to get the system into a runnable state: migrations,
seed data, fixtures, environment variables and where their values come from. Never
put actual secrets in this file.

**File and folder conventions.** Where code goes, how files are named, how modules
are structured. An agent that guesses will guess differently each time.

**Validation commands.** The exact commands for lint, test, build, and typecheck.
Copy them from the project mode defaults in `context.md`.

**Acceptance gate.** What must pass before a nanotask counts as done. Binary
criteria only. Include a dependency vulnerability scan.

**Self-reflection step.** Before requesting review, the agent checks its own work
for: duplicated logic that already exists in a dependency, missing input validation,
missing error handling, secrets in source, and unhandled failure paths.

**Failure protocol.** Maximum three attempts at the same failing check. After the
third, stop, revert the working tree to the last good state, and report what was
tried and what is needed. An agent that grinds on attempt seven produces damage,
not progress.

**Pacing.** Stop after every nanotask and wait for review. Do not chain nanotasks.

**Evaluation loop.** Every three nanotasks, pause and check the whole system
against the PRD rather than the individual nanotask. Drift accumulates below the
threshold of any single check.

---

## `VERIFY.md` - the acceptance contract

`AGENT.md` tells the agent what to do. `VERIFY.md` tells the reviewer - human or
agent - how to decide whether it worked. Keeping them separate matters: an agent
that can edit its own acceptance criteria has no acceptance criteria.

**It does not list the per-nanotask checks.** Those are written once, in the
nanotask file, and their pass/fail state lives in the ledger at
`meta/progress.json`. A second copy here would drift from the first, and no
reviewer could tell which was current. `VERIFY.md` points at both instead.

Contents:

- **Whole-system checks.** Lint, typecheck, build, full test suite, dependency
  audit - the commands that must pass regardless of which nanotask was last touched.
- **Regression checks.** For Rewrite mode, what the old system did that must still
  work. Skip for Greenfield.
- **Non-functional checks.** The measurable requirements from the PRD, each with its
  measuring command.
- **How to run everything.** One command sequence a reviewer can paste, in order.

Every entry is pass or fail. No entry says "review manually" without stating what
the reviewer is looking for and what makes it a failure.

---

## `meta/decisions.md`

An architectural decision record. See `state-files.md` for what belongs in it and
what does not.

---

## The ledger is the agent's obligation

`AGENT.md` must tell the implementing agent that `meta/progress.json` carries a
nanotask ledger, that every entry starts `failing`, and that flipping an entry to
`passing` is part of finishing a nanotask - not an afterthought.

State the constraints plainly, because an agent under pressure to report progress
will otherwise take the shortest path:

- Flip to `passing` only when every acceptance check in that nanotask file passes.
- Set `blocked` with a reason rather than skipping an entry.
- Never delete an entry, and never edit a `behavior` string. Editing the behavior
  is how an agent quietly redefines what it was asked to build.

---

## Checkpoint

Phase 4 ends the workflow. The final checkpoint lists every produced file and tells
the user to hand `AGENT.md` to their coding agent.
