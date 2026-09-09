# State files - `meta/`

Everything in `<project>_plan/meta/` is provenance and state: how the plan was
arrived at, and where execution has got to. Nothing in `meta/` tells anyone what to
build - that is the job of `PRD.md`, `architecture.md`, and `tasks/`.

```
<project>_plan/meta/
|-- context.md         Phase 0 record: idea, references, research, Q&A, mode
|-- decisions.md       Architectural decision records
|-- progress.json      Machine state - workflow phases and the nanotask ledger
`-- execution-log.md   Sequential narrative of what happened
```

---

## `progress.json`

The only machine-readable file in the plan. Two jobs: track which planning phase is
current, and hold the **nanotask ledger** that the implementing agent flips as it
works.

```json
{
  "project": "<name>",
  "mode": "web-app",
  "design_doc": true,
  "current_phase": 3,
  "phases": {
    "0": { "status": "approved",    "completed_at": "2026-01-01T00:00:00Z" },
    "1": { "status": "approved",    "completed_at": "2026-01-01T00:00:00Z" },
    "2": { "status": "approved",    "completed_at": "2026-01-01T00:00:00Z" },
    "3": { "status": "in_progress", "completed_at": null },
    "4": { "status": "pending",     "completed_at": null }
  },
  "nanotasks": [
    { "id": "00",   "behavior": "Project builds and tests run",        "status": "failing", "depends_on": [] },
    { "id": "01",   "behavior": "User can sign up with email",         "status": "failing", "depends_on": ["00"] },
    { "id": "03.1", "behavior": "Endpoint returns a session on valid credentials", "status": "failing", "depends_on": ["01"] },
    { "id": "03.2", "behavior": "Login form shows the server error on 401",        "status": "failing", "depends_on": ["03.1"] }
  ],
  "deferred_features": [
    { "feature": "notification centre", "reason": "email digest meets the need", "deferred_at": "phase-1" }
  ]
}
```

**Phase status:** `pending`, `in_progress`, `written`, `approved`. A phase becomes
`approved` only after the user has replied `APPROVED`.

**`design_doc`:** set in Phase 0 from the project mode. Consumers branch on this
field, never on whether `design.md` happens to exist on disk.

### The nanotask ledger

Phase 3 writes one entry per nanotask, every one seeded `"status": "failing"`.

Seeding them failing is deliberate. An empty ledger looks the same as a finished
one, and an agent reading an empty list has no way to tell a plan that has not
started from a plan that is complete. A list of known-failing entries is an
instruction: these are the things that must become true.

**Status values:** `failing`, `passing`, `blocked`.

The implementing agent flips an entry to `passing` only when every acceptance check
in that nanotask file passes. It may set `blocked` with a reason. It may never
delete an entry or edit a `behavior` string - that would let it quietly redefine
what it was asked to build.

The ledger holds the behavior sentence and status only. **It does not copy the
acceptance checks.** Those live in the nanotask file, once. The ledger says whether
they pass; the file says what they are.

---

## `execution-log.md`

Append-only, newest entry last. One entry per phase completion and per significant
decision.

```markdown
## 2026-01-01T09:14Z - Phase 1 approved
PRD written. 3 core features, 7 base features.
Challenged the notification centre; user accepted an email digest instead.
```

This is the narrative that git history cannot provide during planning, because
planning happens before there is anything to commit. Once implementation starts,
git history takes over and this log stops growing.

Never rewrite an entry. If something recorded here turns out to be wrong, append a
correction with its own timestamp.

---

## `context.md`

The Phase 0 record. See `phase-0-context.md` for its required contents.

It holds **what was said and what was found** - the idea verbatim, the reference
inventory, research findings, and the questions with their answers as given.

`PRD.md` holds **what we decided to build**. It analyses the context; it does not
transcribe it. If a sentence would be identical in both files, it belongs in
`context.md` and `PRD.md` should cite it.

---

## `decisions.md`

One entry per decision that was genuinely contested, or that a future reader would
otherwise reverse by accident.

Each entry: what was decided, what else was considered, why this one won, and what
it costs. The cost line matters most - a decision recorded without its downside
reads as free, and gets overturned the first time the downside is felt.

Do not record decisions that had no alternative. "We used the language the existing
codebase is written in" is not a decision.
