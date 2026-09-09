# Phase 1 - Requirements and PRD

**Goal:** Turn the Phase 0 context into a structured `PRD.md`.

Use `templates/PRD.md` for the document structure.

---

## Analyse, do not transcribe

`meta/context.md` holds **what was said and what was found**: the idea verbatim, the
reference inventory, the research, and the questions with their answers as given.

`PRD.md` holds **what we decided to build**. It is the analysis of that record, not
a second copy of it.

If a sentence would read identically in both files, it belongs in `context.md` and
the PRD should cite it. The two documents sit next to each other for the whole life
of the project - the moment they hold the same fact twice, they start drifting, and
no reader can tell which copy is current.

| Section | Context holds | So the PRD holds |
|---|---|---|
| Problem | The Q1 answer as the user phrased it | What that costs, who it affects, what changes if it is fixed |
| User | The Q2 answer as given | What that user's constraints mean for the product |
| Differentiation | Raw research findings per competitor | One sentence of position, naming the product it differs from |
| Success criteria | The Q5 answer as given | The same criterion expressed as a measurable check |
| Out of scope | Features deferred during Phase 0 | Those, cited by reference, **plus** anything deferred during Phase 1 |

The last row is the pattern for all of them: the PRD records the delta and the
judgement, not the transcript.

---

## Differentiation

The competitive research is already done. It happened in Phase 0, before the
questions, and it is recorded in `context.md`. Do not run it again. Search only to
close a specific gap that writing the PRD exposes.

Your job here is to turn those findings into a stated position. Apply this rule:

> A little bit different beats a little bit better.

A product that is slightly better than an incumbent has to win on execution against
a team with more resources. A product that is different has a reason to exist that
the incumbent cannot copy without abandoning its own users.

State the difference explicitly in the PRD, in one sentence, naming the comparable
product it is different from. If you cannot name a difference, say so directly -
that is a finding the user needs before Phase 2, not a failure to paper over.

If Phase 0 recorded that research was skipped, carry that note into the PRD rather
than filling the gap from memory.

---

## Requirement discovery

If any part of the scope is unclear after Phase 0, ask now.

Phase 1 is the last cheap place to resolve ambiguity. A question left unanswered
here becomes an assumption in `architecture.md`, then gets copied into every
nanotask that depends on it, and surfaces as rework during implementation.

Ask until the scope and the target user are unambiguous. There is no question
limit.

---

## The Scope Challenge

When the user requests a feature that does not serve the Phase 0 core problem, do
not silently accept it and do not simply refuse it. Run this sequence:

1. **Name the underlying need.** "You asked for a full notification center. The
   need underneath it is that users miss the weekly summary."
2. **Propose the cheaper path.** "An email digest meets that need with no new
   data model, no read state, and no UI surface."
3. **State the cost of the original.** Be specific: new entities, new screens,
   new failure modes, ongoing maintenance.
4. **Let the user decide.** If they choose the original, record the decision and
   its reasoning in the PRD, and move on. Do not relitigate it in Phase 2.

Record every challenge and its outcome. The PRD should show what was questioned
and what survived, not just the final list.

---

## Core features versus base features

- **Core features** are the differentiators. They are the reason the product
  exists. Keep this list short - if everything is core, nothing is.
- **Base features** are the table stakes: CRUD, auth, settings, export. They are
  required but they win nothing. List them granularly, because Phase 3 turns each
  one into nanotasks.

---

## Non-functional requirements

Every non-functional requirement must be measurable and carry the command or
method that measures it.

| Not usable | Usable |
|---|---|
| "Must be fast" | "p95 response under 200 ms, measured by `<command>`" |
| "Must be secure" | "No high or critical findings from `npm audit --production`" |
| "Must be accessible" | "Zero axe-core violations at WCAG 2.1 AA on all primary screens" |
| "Must scale" | "Sustains 500 concurrent sessions with error rate under 0.1%" |

An unmeasurable non-functional requirement cannot become an acceptance check in
Phase 3, which means it will never be verified.

---

## Checkpoint

The PRD must be reviewed and approved by the user before Phase 2 begins.
