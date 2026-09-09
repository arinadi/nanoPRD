# Phase 3 - Decomposition into nanotasks

**Goal:** Turn the PRD and architecture into `tasks/` - a dependency-ordered set of
nanotasks, each implementable by a coding agent without asking a follow-up
question.

This is the phase the rest of the workflow exists to serve. Everything before it is
input. Everything after it is packaging.

Use `templates/nanotask.md` for the file structure.

---

## Before you write anything: populate `reference/`

Fill `<project>_plan/reference/` with the API and library documentation the
implementing agent will need.

Do this first. A spec written against remembered API surface is a spec written
against an API that may not exist. The implementing agent will follow it anyway,
because the spec is the most authoritative thing it can see.

---

## The nanotask contract

> A nanotask is an atomic, doable task. It covers exactly one user-observable
> behavior, and it carries everything needed to do it.

Both halves are required, and they fail in different directions.

**Atomic** means it cannot be usefully split further. The behavior sentence below
is the test. A task that is doable but not atomic - "build the admin panel" - is a
module wearing a task's name: it cannot be reviewed in one sitting, and a partial
result leaves the system in a state nobody specified.

**Doable** means everything needed is already decided and written in the file. No
missing choice, no unstated dependency, no "work out the API shape first". A task
that is atomic but not doable - "add the caching layer", with no decision on which
cache - stalls on the first turn, and the implementing agent will make the decision
for you, silently, in code.

Before writing any nanotask to disk, check both:

| Test | Question | If it fails |
|---|---|---|
| Atomic | Does it state one behavior in one sentence? | Split it |
| Doable | Can an agent start it now, with no unanswered question? | Answer the question, or move it to an earlier nanotask |

"User-observable" is the load-bearing phrase in the behavior test. The observer can
be a person or another system, but the behavior must be visible from outside the
code. "Refactor the auth module" is not a nanotask. "User stays logged in after
closing the browser" is.

### The validity test

State the nanotask as a single sentence, in one of two forms:

```
"User can <verb> <object>."
"System <verb>s <object> when <trigger>."
```

If the sentence needs *and*, *then*, or a comma-separated list to stay true, it
describes more than one behavior. Split it before writing it to disk.

```
"User can log in with email"                     -> 1 nanotask
"User can log in and reset their password"       -> 2 nanotasks
"System retries failed webhooks"                 -> 1 nanotask
"System retries failed webhooks and alerts ops"  -> 2 nanotasks
"User can filter, sort, and export the report"   -> 3 nanotasks
"System validates input when a form is submitted" -> 1 nanotask
```

Run this test on every nanotask before writing the file. It takes one sentence and
it is the only thing standing between a set of nanotasks and a set of modules.

### Watch for the hidden conjunction

A sentence can smuggle a second behavior in without using the word "and":

| Sentence | Problem | Split into |
|---|---|---|
| "User can manage their team" | "manage" is CRUD in a trench coat | invite, remove, change role |
| "User can configure notifications" | "configure" hides every setting | one per setting that changes behavior |
| "System syncs with the CRM" | "sync" is read plus write plus conflict resolution | pull, push, resolve conflict |
| "User can check out" | a checkout is a flow, not a behavior | address, payment, confirmation |

If a verb could expand into a list, it is a category, not a behavior.

---

## Numbering

Two levels. Never three.

```
NN      major - one user-observable behavior
NN.M    minor - one independently verifiable increment of that behavior
```

| Level | Owns | Example |
|---|---|---|
| Major `03` | The behavior. What the user sees, and what gets accepted. | `03-user-can-log-in` |
| Minor `03.1` | One verifiable increment of it. | `03.1-email-password-endpoint` |

**A major is either one file or a set of minors. Never both.**

```
tasks/
  00-setup.md                        <- behavior needs no split: one file
  01-user-can-sign-up.md
  03.1-email-password-endpoint.md    <- behavior split into minors:
  03.2-session-cookie-issued.md         no 03-*.md file exists
  03.3-login-form-error-states.md
  04-user-can-log-out.md
```

There is no index file for a split major. A file that is not a task is a file the
implementing agent has to read and cannot act on.

### When to split a behavior into minors

The behavior test at the major level has already passed - `03` is one behavior. So
the minor split trigger is a different question:

> Split into minors when the behavior cannot be delivered as one reviewable
> increment.

**Each minor must be independently verifiable.** It has its own acceptance check
that passes on its own, against the running system. If a step cannot be verified
alone, it is not a minor - it is part of the step next to it.

This is the rule that stops minors from degrading into a task list:

| Not a valid split | Why | What to do |
|---|---|---|
| `03.1` write the handler, `03.2` write its test | `03.1` cannot be verified alone | One minor. Tests are part of the work, not a step after it |
| `03.1` add the column, `03.2` use the column | `03.1` changes nothing observable | One minor |
| `03.1` backend, `03.2` frontend | Layer split, not increment split | Split by what becomes verifiable, or do not split |
| `03.1` endpoint returns a session, `03.2` form shows the 401 error | Each passes its own check against the running system | Valid |

### The five-minor guard

**If a major needs more than five minors, the behavior was too big.** Go back and
split it at the major level instead.

This guard is the reason a third numbering level is never needed. Reaching for
`03.2.1` means `03.2` was not atomic, which is a decomposition error - a deeper
number would only hide it. Fix the split, do not add depth.

For a project large enough that majors run into the dozens, group with a directory
(`tasks/02-billing/`) and keep the leaf at two levels.

---

## Ordering and dependencies

Number in dependency order. **A nanotask may depend only on lower-numbered
nanotasks**, comparing major first and minor second. `03.2` may depend on `03.1`
and on anything below `03`. It may not depend on `03.3` or on `04`.

This makes the set implementable top to bottom with no backtracking, and it keeps
a partially built system coherent at every point.

`00-setup` is always first and has no dependencies. It covers project scaffolding,
dependency installation, configuration, and the first command that proves the
toolchain works. It may take minors like any other major.

Minors under one major are implemented in order, and the behavior is not done until
all of them pass.

Derive the order from the dependency graph in `architecture.md`. If two nanotasks
have no dependency relationship, order them by risk: the one that could invalidate
the architecture goes first. Discovering a broken assumption at nanotask 3 is
cheaper than at nanotask 19.

If you find yourself wanting a nanotask to depend on a higher-numbered one, the
decomposition is wrong. Either the two are one nanotask, or the order is wrong.
Fix it here, not later.

---

## What each nanotask file contains

Every nanotask file has these sections. They are not optional - a missing section
is a question the implementing agent has to ask.

1. **Behavior** - the one sentence, in the exact form from the validity test. On a
   minor, this is the major's behavior sentence, followed by an **Increment** line
   stating what this specific minor makes true.
2. **Depends on** - nanotask numbers, or `none`. Never a name, always a number.
   Minors carry their sibling dependency here too: `03.2` depends on `03.1`.
3. **Requirements** - what must be true when this is done. Specific, not general.
4. **Data and API** - entities touched, endpoints called or created, request and
   response shapes. Reference `architecture.md` rather than restating the model.
5. **UI structure** - components, states, and empty and error states. UI modes only;
   omit the section entirely for headless modes.
6. **Technical notes** - the non-obvious parts. Chosen approach, known trap, the
   reason a simpler option was rejected.
7. **Acceptance checks** - binary pass or fail, each with the exact command.

---

## Acceptance checks

Every check is binary and carries the command that proves it.

```
- [ ] A POST to /api/sessions with valid credentials returns 200 and a session cookie
      Command: npm run test -- auth/login.test.ts
- [ ] A POST to /api/sessions with a wrong password returns 401 and no cookie
      Command: npm run test -- auth/login.test.ts
- [ ] The login form shows the server error message on 401, not a generic string
      Command: npx playwright test e2e/login.spec.ts
```

A check without a command is an opinion. The implementing agent cannot act on it,
and the reviewer cannot settle a disagreement with it.

Pull the default commands from the project mode selected in Phase 0. If a nanotask
needs a check the mode's defaults do not cover, add it and say why.

---

## Common mistakes

| Mistake | Why it breaks | Fix |
|---|---|---|
| Splitting by layer | "Build the API" then "build the UI" - neither is observable alone, and the first cannot be verified | Split by behavior; each nanotask crosses the layers it needs |
| Restating the data model | Two copies drift, and nobody knows which is current | Reference `architecture.md` |
| "Refactor X" as a nanotask | Not user-observable, so it has no acceptance check | Fold into the nanotask whose behavior needs it |
| A dependency on a higher number | Cannot be implemented in order | Reorder, or merge if they are one behavior |
| Vague checks ("works correctly") | Cannot pass or fail | Rewrite as an observable outcome with a command |
| One nanotask per PRD bullet | PRD bullets are features, not behaviors | Run the validity test on each bullet |
| A third numbering level (`03.2.1`) | `03.2` was not atomic; depth hides the error | Split at the major level instead |
| Both `03-*.md` and `03.1-*.md` exist | Ambiguous which one is the task | A major is one file or a set of minors, never both |
| A minor that cannot be verified alone | It is half a step, not an increment | Merge it into the minor beside it |
| Six or more minors under one major | The behavior was too big | Split at the major level |

---

---

## Seed the ledger

When every nanotask file is written, write the ledger into `meta/progress.json`:
one entry per nanotask, carrying `id`, `behavior`, `depends_on`, and
`"status": "failing"`.

Seed them all failing. An empty ledger looks identical to a finished one, and an
agent reading an empty list cannot tell a plan that has not started from a plan
that is complete. A list of known-failing entries is an instruction.

The ledger carries the behavior sentence and status only. **It does not copy the
acceptance checks** - those live in the nanotask file, once. The ledger says
whether they pass; the file says what they are. See `state-files.md` for the shape.

---

## Checkpoint

Every nanotask must be reviewed and approved by the user before Phase 4 begins.
