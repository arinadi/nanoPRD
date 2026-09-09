# Phase 0 - Intake, research, and discovery

**Goal:** Establish the ground truth before any design work begins.

Everything downstream inherits from this phase. A wrong answer here is not
discovered until Phase 3, when it has already been copied into every nanotask.

Four steps, in this order. The order is the point: research before questions means
you ask about what is genuinely undecided, instead of asking the user to explain
their own market back to you.

---

## Step 1 - Intake

The user has created a project folder, invoked nanoPRD from inside it, and given
you an initial idea plus, usually, reference material.

**Record the initial idea verbatim.** Not your paraphrase of it. The original
wording carries intent that a summary loses, and Phase 1 needs it.

**Inventory the reference material.** Every file the user pointed at, plus anything
already in the project folder that bears on the idea: existing notes, an API
specification, a database schema, a design file, a previous attempt at a PRD, a
competitor teardown.

Read each one. For each, record one line: what it contributes, and what it settles.

| Reference | Contributes | Settles |
|---|---|---|
| `api-spec.yaml` | Existing endpoint surface, 14 routes | Data model for orders and customers |
| `notes.md` | Founder's feature wishlist, unordered | Nothing - opinions, not decisions |

**A question already answered by a reference file is not asked again.** State what
you took from the file and ask the user to confirm it. Asking a user to re-type
something they already handed you is how a planning tool loses trust in its first
five minutes.

If there is no reference material, say so and continue. It is common and fine.

---

## Step 2 - Research

Use WebSearch on the problem space before writing any question.

**Comparable products.** Find at least two products solving a similar problem. For
each, record what it does well and where it leaves this user unserved. This is what
makes the differentiation section of the PRD real rather than aspirational.

**Unfamiliar technology.** Research anything named in the idea or the reference
files that you cannot describe accurately from memory - a library, a protocol, a
regulation, a platform constraint. A plan built on a misremembered API is worse
than a plan that admits a gap.

**Domain constraints.** If the problem space carries known regulatory or technical
constraints (payments, health records, children's data, real-time media), find them
now. A constraint discovered in Phase 3 invalidates the architecture.

If WebSearch is unavailable, record "research skipped: WebSearch unavailable" in
`context.md` and continue. Do not invent findings from memory and present them as
research.

---

## Step 3 - The question list

Present the questions as one numbered message. The user sees the whole shape of
what is undecided and answers at their own pace.

Mark each question mandatory or optional, so the user knows what blocks progress.

### The five mandatory questions

Always ask all five, unless a reference file already answers one - in which case
state what you took from the file and ask for confirmation instead.

**1. Why does this exist? What happens if it is not built?**

Name the cost of inaction. Reject a benefit statement dressed as a reason.

- Usable: "Support answers the same three billing questions 40 times a week by hand."
- Not usable: "It would be nice to have analytics."

**2. Who is the specific user?**

One named role, with enough context to make a design decision from.

- Usable: "A non-technical HR manager at a 50-person company, using this once a
  month on a work laptop."
- Not usable: "Everyone", "businesses", "users".

If the answer is a segment rather than a person, ask who the first ten users are.

**3. What is the one feature that makes this viable?**

A single capability. If the product shipped with only this, it would still be worth
using. If the answer lists several, ask which one survives alone. The rest become
Base Features in Phase 1, or move to the deferred list.

**4. What is the landscape?**

| Mode | Meaning | What you must document |
|---|---|---|
| Greenfield | Nothing exists yet | Nothing to preserve, so nothing constrains the stack |
| Extension | Building on top of a running system | The existing stack, its versions, and its extension points |
| Rewrite | Replacing something that works | What the current system does that must not regress |

Extension and Rewrite both require an asset audit in Step 4. Greenfield does not.

**5. How do we know it worked?**

A measurable, binary criterion. It must be answerable yes or no without discussion.

- Usable: "Support ticket volume for billing questions drops below 10 per week."
- Not usable: "Users are happier."

### Project-specific questions

Add questions raised by the research or by gaps in the reference material. These
are where Phase 0 earns its cost - they are the questions a generic template cannot
produce.

Good sources for them:

- A comparable product solved this problem in a way the user has not mentioned.
  Do they want that, or deliberately not?
- A reference file implies a constraint the user has not stated.
- Two reference files disagree.
- The research surfaced a regulatory requirement the idea does not account for.
- The idea assumes a technology whose limits change the design.

### Handling the answers

Wait for the answers. If a mandatory answer is missing or unusable, ask for that
one again specifically. Do not proceed with five answers when you have three.

---

## Step 4 - Mode, constraints, and state

**Select the project mode.** One only. It sets the validation defaults for every
nanotask and decides whether Phase 2 produces a design document.

| Mode | Primary concern | Default validation | Design doc |
|---|---|---|---|
| `web-app` | Scalability and UX | E2E (Playwright or Cypress), unit, build, lint | Yes |
| `mobile` | Performance and platform fit | Device tests, platform build checks | Yes |
| `cli-tool` | Speed and reliability | Integration tests, smoke tests, distribution check | No |
| `data-pipeline` | Integrity and latency | Data validation, schema checks, dry runs | No |
| `ml-service` | Accuracy and evaluation | Eval metrics, benchmarks, drift detection | No |

If the project spans two modes, pick the one carrying the user-facing risk and note
the second in constraints. Do not select two.

**Constraint framework.** Document budget, timeline, team size, and any regulatory
requirement (GDPR, HIPAA, PCI DSS, data residency).

**Asset audit.** For Extension and Rewrite modes, identify every existing
repository, database, API, and piece of infrastructure that must be integrated.
Record versions. "We have a Postgres database" is not an audit. "Postgres 14.9,
~2M rows in `orders`, read replica in eu-west-1" is.

**Deferred list.** Name every feature raised so far that does not serve the answer
to question 3. Do not delete these - record each with a one-line reason. A deferred
feature that is written down can be reconsidered. One silently dropped comes back
as a surprise in Phase 3.

**Initialize state.** Create `<project>_plan/`, then write `progress.json` and
`execution-log.md`.

---

## What `context.md` must contain

- The initial idea, verbatim
- Reference inventory: file, contributes, settles
- Research findings: comparable products, technology notes, domain constraints
- The five mandatory questions and their answers, verbatim
- Project-specific questions and their answers
- Selected project mode, and why
- Constraints: budget, timeline, team, regulatory
- Asset audit (Extension and Rewrite only)
- Deferred features, each with a one-line reason

---

## Checkpoint

Phase 0 output must be reviewed and approved by the user before Phase 1 begins.
