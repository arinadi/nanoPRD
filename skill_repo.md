---
name: skill-repo-builder
description: Build an Agent Skills repository that installs into Claude Code (via plugin marketplace) and OpenCode (via skills sources). Use this whenever the user asks to create a skill repo, a plugin marketplace, a skills bundle, or wants to distribute SKILL.md files to a team or the public.
license: MIT
compatibility: Requires git. Optional - Claude Code 2.1+ for `claude plugin validate`, OpenCode 1.0.190+ for native skills.
---

# Building an Installable Skill Repository

You are building a repository that must install cleanly in **both** Claude Code
and OpenCode. Work in the order below. Do not start with the manifest files —
start with the skills themselves.

## The compatibility rule that governs everything

Both tools read the same open Agent Skills format. Only the install mechanism
differs.

| Target | Install mechanism | Extra files needed |
|---|---|---|
| Claude Code | plugin marketplace | `.claude-plugin/marketplace.json` + `plugin.json` |
| OpenCode V2 | `skills` array in `opencode.json`, or HTTP catalog | none |
| OpenCode V1 | built-in discovery paths, including `~/.claude/skills` | none |
| claude.ai / Cowork | manual upload (zip / `.skill`) | none, but frontmatter must be spec-only |

Therefore: **write every `SKILL.md` to the lowest common denominator (the spec),
then layer the Claude Code plugin manifests on top.** Never the reverse. A repo
built around Claude Code-only features cannot be made portable afterwards
without rewriting every skill.

## Step 1 — Establish what the skills actually do

Do not generate boilerplate before you know the content. Ask the user:

1. What should this skill let the agent do?
2. When must it trigger? What exact phrases will the user say?
3. What is the expected output format?
4. Does it need bundled files (scripts, references, templates), or is prose enough?

If the user says only "make me a skill repo" with no domain, ask before
scaffolding. An empty scaffold is not a deliverable.

## Step 2 — Use this layout

```
my-skills/
├── .claude-plugin/
│   ├── marketplace.json      # catalog; read by /plugin marketplace add
│   └── plugin.json           # plugin manifest
├── skills/                   # the single source of truth
│   ├── git-release/
│   │   ├── SKILL.md          # required
│   │   ├── references/       # docs read on demand
│   │   │   └── release-policy.md
│   │   ├── scripts/          # code that is executed, not read into context
│   │   │   └── changelog.py
│   │   └── assets/           # templates, icons, fonts
│   └── pr-review/
│       └── SKILL.md
├── install.sh                # symlinks into ~/.claude/skills; serves both tools
├── opencode.json.example
├── .github/workflows/validate.yml
├── LICENSE
└── README.md
```

Non-negotiable rules:

- The skill folder name **must** equal the frontmatter `name`. A mismatch means
  the skill silently fails to load.
- Every skill is self-contained. Never reference `../shared/` across skills.
  Claude Code copies the plugin directory into a cache on install, so anything
  outside the plugin directory is not copied and the path breaks.
- Put executables in `scripts/`. Do not create a top-level `bin/` directory —
  claude.ai rejects plugins that have one, on both marketplace sync and direct
  upload.
- Use only the three standard subdirectories: `scripts/`, `references/`,
  `assets/`. Keep reference files one level deep; do not nest them.

## Step 3 — Write portable SKILL.md files

Use **only these six frontmatter fields**: `name`, `description`, `license`,
`compatibility`, `metadata`, `allowed-tools`.

```yaml
---
name: git-release
description: Prepare release notes, version bumps, and GitHub releases from commits since the last tag. Use this whenever the user mentions releases, changelogs, version tagging, or asks what changed since the last version.
license: MIT
metadata:
  version: "1.0.0"
  author: your-name
---

## Workflow

1. Read `references/release-policy.md` for this project's versioning scheme.
2. Collect commits since the last tag with `git log <tag>..HEAD --oneline`.
3. Propose the new version and wait for confirmation before editing files.
4. Once approved, run `scripts/changelog.py`, then create the tag.

## Output format

Always use this template:

# v[VERSION] — [DATE]
## New features
## Fixes
## Breaking changes
```

Hard constraints:

- `name`: 1–64 characters, lowercase, matching `^[a-z0-9]+(-[a-z0-9]+)*$`, no
  leading or trailing hyphen, no `--`, and it must not contain the reserved
  words `anthropic` or `claude`.
- `description`: 1–1024 characters. This is the primary trigger mechanism.
  State both what the skill does and when to use it. Agents systematically
  under-trigger skills, so write descriptions that are slightly pushy and name
  the concrete phrases a user would actually type.
- `compatibility`: 500 characters maximum.
- Keep `SKILL.md` under 500 lines. Past that, move detail into `references/` and
  point at those files explicitly from `SKILL.md` with guidance on when to read
  them.
- Write instructions in the imperative. Explain why a step matters rather than
  stacking MUSTs.

**Do not use Claude Code-only frontmatter** in a portable repo:
`argument-hint`, `context`, `agent`, `disable-model-invocation`,
`user-invocable`, `model`, `effort`, `paths`, `hooks`, `when_to_use`, `shell`,
`disallowed-tools`, `background`. Claude Code accepts them, but claude.ai upload
and the Skills API fail with a hard error rather than ignoring them:

```
Unexpected key(s) in SKILL.md frontmatter: argument-hint.
Allowed properties are: allowed-tools, compatibility, description, license, metadata, name
```

Claude Code-only body syntax is equally off-limits: shell injection
(`` !`cmd` ``), `$ARGUMENTS`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PLUGIN_ROOT}`.
None of it functions in OpenCode or claude.ai chat. If a skill must run a
bundled script, write the command as a plain instruction using a path relative
to the skill directory.

## Step 4 — Add the Claude Code layer

`.claude-plugin/plugin.json`:

```json
{
  "name": "my-skills",
  "description": "Release and code-review skills",
  "author": { "name": "Your Name" },
  "homepage": "https://github.com/USER/my-skills",
  "license": "MIT"
}
```

`.claude-plugin/marketplace.json`:

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "my-skills",
  "owner": { "name": "Your Name" },
  "description": "Portable skills for Claude Code and OpenCode",
  "plugins": [
    {
      "name": "my-skills",
      "source": "./",
      "description": "Every skill in this repository",
      "category": "productivity"
    }
  ]
}
```

Get these right or the install fails:

- The catalog file **must** live at `.claude-plugin/marketplace.json` in the repo
  root. A repo with only `plugin.json` is rejected by `/plugin marketplace add`.
- Relative sources must start with `./` and resolve against the marketplace
  root, not against the `.claude-plugin/` directory. Never use `../`.
- Plugin skills load automatically from `skills/` under the entry's `source`.
  Do not list skills individually. The exception: if you split the repo into
  several plugin entries sharing one root `skills/` folder, list each entry's
  specific subdirectories in its `skills` field, otherwise every entry loads
  every skill.
- `version`: setting it pins the plugin, and users only receive updates when the
  string changes. For an actively developed repo, **omit it** so the version
  falls back to the resolved commit SHA and updates flow automatically. If you
  do set it, bump it on every release, and set it in one place only —
  `plugin.json` always wins over the marketplace entry, silently.
- Avoid marketplace names reserved for Anthropic (`claude-plugins-official`,
  `agent-skills`, `anthropic-plugins`, and similar) and names that impersonate
  official sources. Both are blocked.
- When renaming or removing a skill later, add a top-level `renames` map to
  `marketplace.json` so existing users migrate instead of hitting
  `plugin-not-found`. Treat `renames` as append-only history; never edit old
  entries.

## Step 5 — Add the OpenCode layer

No manifest is required. Ship both paths.

**Path A — symlink into `~/.claude/skills`, which serves both tools.**
OpenCode reads `~/.claude/skills` and `.claude/skills` as compatibility sources,
and Claude Code resolves a skill entry that is a symlink to a directory
elsewhere on disk. One symlink covers both.

`install.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${1:-$HOME/.claude/skills}"

mkdir -p "$DEST"
for dir in "$REPO"/skills/*/; do
  name="$(basename "$dir")"
  ln -sfn "${dir%/}" "$DEST/$name"
  echo "linked $name -> $DEST/$name"
done

echo
echo "Done. Claude Code: restart your session."
echo "OpenCode: skills load from ~/.claude/skills with no further config."
```

Mark it executable (`chmod +x install.sh`) before committing.

**Path B — register as a skills source in OpenCode V2.**
`opencode.json.example`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "skills": ["~/src/my-skills/skills"],
  "permissions": [
    { "action": "skill", "resource": "*", "effect": "allow" }
  ]
}
```

Relative paths resolve against OpenCode's active working directory, not the
config file's location. `skills` entries from every discovered config are
additive rather than overriding each other.

Version differences to document in the README:

- Native skill support landed in OpenCode **v1.0.190**. The third-party
  `opencode-skills` plugin is deprecated; do not reference it.
- **V1** uses `permission.skill` with wildcard patterns
  (`"*": "deny"`, `"my-skill": "allow"`, values `allow` / `deny` / `ask`).
  **V2** uses a `permissions` array with `action: "skill"`.
- In V2 the skill ID comes from the **path**, not the frontmatter. `name` is
  only a display label. Keep folder names clean and deliberate.
- For git-free distribution on V2, publish an HTTP catalog: a base URL holding
  an `index.json` with `name`, `version`, and `files` per entry. Bump `version`
  whenever a file changes or OpenCode serves the cached copy. In an HTTP
  catalog use the named-Markdown form (`git-release.md`) — a root-level
  `SKILL.md` yields the literal ID `SKILL`.

## Step 6 — Ship these exact install commands in the README

**Claude Code, inside a session:**

```
/plugin marketplace add USER/my-skills
/plugin install my-skills@my-skills
```

If the install summary says `Run /reload-plugins to activate.`, run it. Plugin
skills are namespaced: invoke as `/my-skills:git-release`.

**Claude Code, CLI (provisioning scripts and CI):**

```bash
claude plugin marketplace add USER/my-skills
claude plugin install my-skills@my-skills
```

Pin to a tag with `@ref`:

```bash
claude plugin marketplace add USER/my-skills@v1.0.0
```

**Claude Code, local test before pushing:**

```
/plugin marketplace add ./my-skills
/plugin install my-skills@my-skills
```

**OpenCode, fastest path, works on V1 and V2:**

```bash
git clone https://github.com/USER/my-skills.git ~/src/my-skills
cd ~/src/my-skills && ./install.sh
```

**OpenCode V2, via config instead of symlinks:**

```bash
git clone https://github.com/USER/my-skills.git ~/src/my-skills
```

then add to `~/.config/opencode/opencode.json`:

```jsonc
{ "skills": ["~/src/my-skills/skills"] }
```

**Per-project, committed to the repo, read by both tools:**

```bash
git submodule add https://github.com/USER/my-skills.git .claude/skill-src
ln -s ../skill-src/skills/git-release .claude/skills/git-release
```

**claude.ai / Cowork:** zip the skill folder and upload it in claude.ai skills
settings. Cowork and cloud sessions do not read `~/.claude/skills` on the local
machine — the skill must be enabled on the account.

## Step 7 — Validate before releasing

```bash
claude plugin validate .          # marketplace.json + plugin.json
claude plugin validate ./skills   # frontmatter of every SKILL.md
```

The marketplace run checks schema, duplicate plugin names, and source path
traversal. The skills-directory run catches YAML frontmatter that fails to
parse — which matters, because broken frontmatter still lets the skill be
invoked by name while stripping the `description`, so it never triggers
automatically.

Add `.github/workflows/validate.yml` running both commands, plus a check that
each folder name equals its `name` field and that no non-spec frontmatter keys
appear.

Then test triggering for real, not just syntax. Open a fresh session, send two
or three realistic prompts that should invoke the skill, and compare against a
session with the skill disabled. The fresh session matters: leftover context
from authoring the skill masks gaps in the written instructions.

## Final checklist

- [ ] Every skill folder has a `SKILL.md` whose `name` equals the folder name
- [ ] Frontmatter uses only the six spec fields
- [ ] Each `description` states what and when, using the user's own phrasing
- [ ] `SKILL.md` under 500 lines; long detail lives in `references/`
- [ ] No cross-skill references (`../`)
- [ ] `.claude-plugin/marketplace.json` exists at the repo root
- [ ] Every `source` starts with `./`
- [ ] `install.sh` is executable
- [ ] README carries install commands for both Claude Code and OpenCode
- [ ] `claude plugin validate .` and `claude plugin validate ./skills` pass
- [ ] LICENSE present and consistent with the `license` frontmatter field

## Failure modes to avoid

1. Shipping `plugin.json` without `marketplace.json` — `/plugin marketplace add` fails.
2. Using Claude Code-only frontmatter in a skill destined for claude.ai — hard error at packaging.
3. Folder name not matching `name` — the skill never loads.
4. Setting `version` and never bumping it — users never receive updates.
5. Cross-referencing skills with `../` — paths break once the plugin is copied to cache.
6. A vague `description` ("Helps with git things") — the skill never triggers.
7. A top-level `bin/` directory — rejected by claude.ai organization distribution.
