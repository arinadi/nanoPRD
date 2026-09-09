# nanoPRD

Break an idea down into **nanotasks** — atomic, doable tasks. One user-observable
behavior each, carrying everything a coding agent needs to pick it up and finish it
in a single pass.

nanoPRD is an Agent Skill. It runs a five-phase workflow with a hard approval gate
between phases, and writes every deliverable to disk instead of into your chat
history.

Works in Claude Code, OpenCode, and claude.ai.

---

## The problem it solves

Hand a coding agent "build me a subscription tracker" and you get a plausible
first draft and a long argument. The agent invents requirements you never stated,
picks a data model you would not have picked, and thirty turns later has
forgotten the auth helper it wrote itself.

The fix is not a better prompt. It is a plan the agent cannot misread — one where
every unit of work states a single behavior, names its dependencies by number, and
carries the exact command that proves it works.

That is what nanoPRD produces.

---

## How a run goes

1. **You create a project folder** and open your agent inside it.
2. **You describe the idea** and point at whatever reference material you already
   have — notes, an API spec, a schema, an earlier attempt at a PRD.
3. **nanoPRD reads your references and researches the problem space** before
   asking you anything, so it asks about what is genuinely undecided rather than
   asking you to explain your own market back to you.
4. **It gives you a question list.** Five mandatory, plus whatever the research
   turned up. Anything your reference files already answered, it confirms instead
   of asking.
5. **It writes `meta/context.md`, then stops.** Every phase from here ends the same
   way: files on disk, a summary in chat, and a stop until you reply `APPROVED`.

```
Phase 0  Intake, research, discovery   -> meta/context.md, meta/progress.json
Phase 1  Requirements                  -> PRD.md
Phase 2  Architecture                  -> architecture.md, design.md*
Phase 3  Decomposition                 -> tasks/, ledger seeded failing
Phase 4  Handoff                       -> AGENT.md, VERIFY.md, meta/decisions.md

* design.md only for web-app and mobile modes.
```

Hand `AGENT.md` to your coding agent and it implements `tasks/` one at a time,
stopping for review after each.

---

## What a nanotask is

> A nanotask is an atomic, doable task. It covers exactly one user-observable
> behavior, and it carries everything needed to do it.

**Atomic** — it cannot be usefully split further. **Doable** — everything needed is
already decided and written down, so an agent can start it now without asking
anything.

Atomic without doable ("add the caching layer") stalls on the first turn. Doable
without atomic ("build the admin panel") is a module wearing a task's name.

The atomicity test is a single sentence:

```
"User can <verb> <object>."
"System <verb>s <object> when <trigger>."
```

If the sentence needs *and*, *then*, or a comma-separated list to stay true, it is
more than one behavior, and it gets split before it reaches disk.

```
"User can log in with email"                     -> 1 nanotask
"User can log in and reset their password"       -> 2 nanotasks
"System retries failed webhooks"                 -> 1 nanotask
"System retries failed webhooks and alerts ops"  -> 2 nanotasks
```

Each nanotask file carries the behavior sentence, its dependencies by number,
requirements, data and API surface, technical notes, and binary acceptance checks
with the command that proves each one.

### Numbering — two levels

```
NN      major   one user-observable behavior
NN.M    minor   one independently verifiable increment of it
```

A behavior that fits in one reviewable increment is one file. A behavior that does
not becomes a set of minors — and then the major has no file of its own:

```
tasks/
  00-setup.md                        unsplit major
  01-user-can-sign-up.md
  03.1-email-password-endpoint.md    03 split into minors,
  03.2-session-cookie-issued.md      so no 03-*.md exists
  03.3-login-form-error-states.md
  04-user-can-log-out.md
```

Every minor must be verifiable on its own. "Write the handler" then "write its
test" is not a valid split — the first proves nothing. "Endpoint returns a session"
then "form shows the 401 error" is, because each passes its own check against the
running system.

**There is no third level.** If you want `03.2.1`, then `03.2` was not atomic —
that is a decomposition error, and a deeper number only hides it. The guard: more
than five minors under one major means the behavior was too big, so split it at the
major level. For projects large enough to need grouping, use a directory
(`tasks/02-billing/`) and keep the leaf at two levels.

---

## Install

### Claude Code — in a session

```
/plugin marketplace add arinadi/nanoPRD
/plugin install nanoprd@nanoprd
```

If the install summary says `Run /reload-plugins to activate.`, run it.

### Claude Code — CLI

```bash
claude plugin marketplace add arinadi/nanoPRD
claude plugin install nanoprd@nanoprd
```

Pin to a tag:

```bash
claude plugin marketplace add arinadi/nanoPRD@v1.0.0
```

### OpenCode — one command, works on V1 and V2

```bash
git clone https://github.com/arinadi/nanoPRD.git ~/src/nanoPRD
cd ~/src/nanoPRD && ./install.sh
```

`install.sh` symlinks into `~/.claude/skills`, which both Claude Code and OpenCode
read. On Windows without Developer Mode it copies instead and tells you so — in
that case, re-run it after pulling an update.

### OpenCode V2 — via config instead of symlinks

```bash
git clone https://github.com/arinadi/nanoPRD.git ~/src/nanoPRD
```

Then add to `~/.config/opencode/opencode.json`:

```jsonc
{ "skills": ["~/src/nanoPRD/skills"] }
```

See `opencode.json.example` for the permission syntax, which differs between
OpenCode V1 and V2. Native skill support requires OpenCode **v1.0.190** or later.

### claude.ai and Cowork

Zip `skills/nanoprd/` and upload it in skills settings. Cloud sessions do not read
`~/.claude/skills` on your machine — the skill has to be enabled on the account.

### Local test before pushing

```
/plugin marketplace add ./
/plugin install nanoprd@nanoprd
```

---

## Use it

From inside your project folder:

- "I have an idea for a subscription tracker. Here are my notes in `notes.md`."
- "Plan a project for an internal invoice approval tool."
- "Rencanakan proyek untuk aplikasi absensi."

nanoPRD starts at Phase 0 and works down to nanotasks.

---

## What it produces

The root holds what to build and how to check it. `meta/` holds how you got there
and where you are.

```text
<project>_plan/
├── PRD.md              Problem, user, differentiation, features, success criteria
├── architecture.md     Stack, data model, components, dependency graph, risk chains
├── design.md           Design system                          (UI modes only)
├── tasks/              Nanotasks, dependency-ordered, NN or NN.M
│   ├── 00-setup.md
│   ├── 01-<behavior-slug>.md
│   ├── 03.1-<increment-slug>.md
│   └── 03.2-<increment-slug>.md
├── AGENT.md            Directive for the implementing coding agent
├── VERIFY.md           Acceptance contract — the agent does not edit this
├── reference/          API and library documentation
└── meta/
    ├── context.md         Initial idea, references read, research, answers, mode
    ├── decisions.md       Architectural decision records
    ├── progress.json      Machine state: phases + the nanotask ledger
    └── execution-log.md   Sequential narrative
```

**Every fact is written once.** `meta/context.md` records what you said and what
the research found; `PRD.md` analyses it rather than restating it. Acceptance
checks live in the nanotask file and nowhere else — `VERIFY.md` covers system-level
checks only, and `meta/progress.json` tracks pass/fail without copying the checks
themselves. Two copies of a fact drift, and then nobody knows which is current.

### The ledger

`meta/progress.json` carries one entry per nanotask, **every one seeded
`failing`**. That is the work list: an empty ledger looks exactly like a finished
one, but a list of known-failing entries is an instruction. The implementing agent
flips an entry to `passing` only when that nanotask's checks pass, and it may never
delete an entry or reword a behavior — that is how an agent quietly redefines what
it was asked to build.

`AGENT.md` and `VERIFY.md` are deliberately separate. An agent that can edit its
own acceptance criteria has no acceptance criteria.

---

## Repository layout

```text
nanoPRD/
├── .claude-plugin/
│   ├── marketplace.json      # catalog, read by /plugin marketplace add
│   └── plugin.json           # plugin manifest
├── skills/
│   └── nanoprd/
│       ├── SKILL.md          # the phase protocol
│       ├── references/       # loaded on demand, one per phase
│       └── templates/        # document skeletons
├── install.sh                # symlinks into ~/.claude/skills, serves both tools
├── opencode.json.example
└── skill_repo.md             # the rules this repo is built to
```

Every `SKILL.md` uses only the six spec frontmatter fields (`name`, `description`,
`license`, `compatibility`, `metadata`, `allowed-tools`) and no Claude Code-only
body syntax, so the same files work in all three targets without modification.

---

## Contributing

```bash
claude plugin validate .          # marketplace.json and plugin.json
```

Note: `claude plugin validate ./skills` does **not** work on current CLI versions.
It treats the target as a plugin root and fails with `No manifest found in
directory`, because `skills/` has no `.claude-plugin/` — by design. Older versions
accepted it as a components directory. SKILL.md frontmatter is validated by the
`structure` CI job instead, which checks the folder/name match, the six spec
fields, and Claude Code-only body syntax — more thoroughly than the CLI did.

Both CI jobs run on every push and both are hard gates. Before opening a PR, also test that the skill
actually triggers: open a **fresh** session and send two or three prompts you would
realistically type. Leftover context from editing a skill masks gaps in what it
actually says.

---

## License

MIT — see [LICENSE](LICENSE).
