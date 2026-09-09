# Acceptance Contract: [Project Name]

> Written by nanoPRD Phase 4. This file decides whether the work is accepted.
>
> The implementing agent does not edit this file. An agent that can edit its own
> acceptance criteria has no acceptance criteria.

Every entry below is pass or fail. No entry says "review manually" without stating
what the reviewer is looking for and what makes it a failure.

## How to run everything

*One command sequence a reviewer can paste, in order.*

```bash
```

## Whole-system checks

*Must pass regardless of which nanotask was last touched.*

| Check | Command | Pass condition |
|---|---|---|
| Lint | | exit 0 |
| Typecheck | | exit 0 |
| Test suite | | exit 0, no skipped tests |
| Build | | exit 0 |
| Dependency audit | | no high or critical findings |

## Per-nanotask checks

**Not listed here.** Each nanotask's acceptance checks live in its own file under
`tasks/`, written once. Their pass/fail state lives in the ledger at
`meta/progress.json`. Copying them into this file would create a second set that
drifts from the first, and no reviewer could tell which one was current.

To review nanotask state:

```bash
# what is still failing
<command that reads meta/progress.json and lists status != passing>
```

A behavior split into minors is not done until every minor under it passes. The
ledger shows this: `03.1` passing while `03.2` is still failing means behavior `03`
is not delivered.

## Non-functional checks

*The measurable requirements from `PRD.md`, each with its measuring command.*

| Requirement | Target | Command | Pass condition |
|---|---|---|---|
| | | | |

## Regression checks

*Rewrite mode only. What the old system did that must still work. Delete this
section for Greenfield.*

| Old behavior | How to verify it still works | Command |
|---|---|---|
| | | |

## Sign-off

The project is accepted when every check above passes and the success criteria in
`PRD.md` are met.

| | |
|---|---|
| Checks passing | / |
| Success criteria met | |
| Accepted by | |
| Date | |
