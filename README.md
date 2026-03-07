# yanct-claude-plugin

A Claude Code plugin that gives you a repeatable, deterministic development
workflow for new projects. Instead of rediscovering the same decisions on
every project — how to structure CI, what packaging format to use, how to
enforce commit messages — this plugin encodes those decisions once and
applies them automatically.

---

## Concept

The core idea is a **Makefile contract**. Every skill, agent, and hook in
this plugin talks to your project through six standard make targets:

```
make build    compile the project
make lint     format check + static analysis
make test     run the test suite
make package  build distribution packages (format depends on project type)
make docs     generate documentation
make release  tag and push to trigger the release pipeline
```

What is behind each target is the project's concern. The plugin only ever
calls these targets — it never invokes `cargo`, `npm`, `go build`, or any
other tool directly. This means the same workflow commands work identically
across different project types, and CI uses exactly the same interface as
your local development environment.

### The development loop

```
Write CLAUDE.md → /init-project → /tasks → review TASKS.md → /execute
```

Each phase has a clear purpose and produces a concrete artifact:

**`/init-project`** reads your `CLAUDE.md` (the project plan you write),
asks what type of project this is, creates the `.claude/` directory
structure with a Makefile, then hands off to the appropriate type skill
to implement the targets and set up the toolchain, CI pipeline, and
packaging stubs.

**`/tasks`** reads your `CLAUDE.md` architecture and breaks it into a
`TASKS.md` with strict ordering. The first section is always Foundation:
six mandatory tasks that verify every make target works, push the scaffold
to GitHub, and confirm the CI and release pipelines are live end-to-end
before a single line of implementation is written.

**`/execute`** works through `TASKS.md` one task at a time. Foundation
tasks are handled with specific logic for the human interaction points
(GitHub repo creation, CI secrets). Implementation tasks follow a strict
per-task loop: create branch → implement (via task-runner subagent) →
mark task done in TASKS.md → open PR with the implementation summary as
body → wait for merge confirmation → ask what to do next. Claude never
auto-continues to the next task and never skips the PR step.

**`/new-task`** adds a single new task to `TASKS.md` without touching
any code. Claude clarifies intent, delegates codebase research to the
task-researcher subagent, and appends a fully-specified task entry
(acceptance criteria, dependencies, files to modify, risks).

**`/edit-task`** selects an existing task by number, enters planning
mode, presents the current entry, and rewrites it in place after
confirming what to change. The task-editor subagent runs the same
codebase research as task-researcher before updating the block.

### Context management

Subagents keep verbose output out of the main session:

- **task-runner** — implements a task in a subagent (all file edits, shell
  commands, lint/test cycles). The main session only sees the summary.
- **task-researcher** — does deep codebase research for `/new-task` before
  writing a task entry. Reads files and traces dependencies without
  polluting the main context.
- **task-editor** — same as task-researcher, but for `/edit-task`. Reads
  relevant code before the task entry is rewritten.
- **pr-creator** — opens the GitHub PR and returns only the PR URL.
- **test-runner** — runs `make test`, returns only failing test names and
  error messages. If all tests pass you see two words: `All tests passed.`
- **lint-checker** — same pattern for `make lint`
- **ci-monitor** — watches a GitHub Actions run until complete, returns
  only failed job/step/error summaries

The **post-edit hook** runs `make lint` automatically after every file
edit. It is silent on success — nothing enters the context. On failure
it outputs the lint errors so Claude can fix them before moving on.

### Packaging is iterative

Distribution packaging (whatever form it takes for your project type)
is scaffolded as stubs during `/init-project`. The stubs are intentionally
incomplete — the exact set of installed files, runtime dependencies, config
paths, and optional extras is only known once the implementation is done.
Each generated file carries a `TODO` comment block listing what needs to
be filled in.

The `/tasks` skill detects which packaging stubs exist and adds the
appropriate finalisation tasks at the end of `TASKS.md`. These are
executed by `/execute` in the same lint/test/commit loop as every other
task.

---

## Project types

Each project type is a separate init skill that implements the Makefile
targets and sets up the type-specific toolchain, CI, and packaging.

| Type | Skill | Toolchain | Packaging |
|---|---|---|---|
| `rust-cli` | `/init-rust-cli` | cargo, clippy, rustfmt, musl static build | .deb + AUR PKGBUILD |
| `claude-plugin` | `/init-claude-plugin` | jq (JSON validation), skill-creator plugin | GitHub Release |
| `web` | `/init-web` | *(not yet implemented)* | — |

Adding a new type means writing a single `skills/init-<type>/SKILL.md`
that implements the six Makefile targets for that toolchain. Everything
else — agents, hooks, task generation, execution loop — works unchanged.

Contributions for `python-cli`, `go-cli`, `web`, and other types are
welcome.

---

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- `gh` CLI — authenticated: `gh auth login`
- Toolchain for your project type (e.g. `rustup` for rust-cli)

---

## Installation

In any Claude Code session, run these two commands:

```
/plugin marketplace add yanctab/yanct-claude-plugin
/plugin install yanct-claude-plugin@yanct-claude-plugin
```

The first command registers the GitHub repository as a plugin marketplace.
The second installs the plugin from it. All commands, agents, and hooks
are then available in every future session.

---

## Usage

### 1. Write your CLAUDE.md

Before running anything, write a `CLAUDE.md` in your project directory.
This is the source of truth — describe what you are building, the module
structure, subcommands or routes, constraints, and anything else Claude
needs to understand the project. The more complete this is, the better
`/tasks` will plan the implementation.

Example structure:

```markdown
# myapp

One sentence describing what it does and why.

## Modules

- cli — argument parsing, entry point
- config — configuration read/write
- core — main business logic

## Commands / API / Routes

- <command or endpoint> — what it does
```

### 2. Initialise the project

```
cd ~/projects/myapp
/init-project
```

Claude asks what type of project this is, then runs the appropriate type
skill. For `rust-cli` this produces: a working Cargo project, Makefile
with real targets, GitHub Actions CI and release workflows, packaging
template stubs, and an initial git commit.

### 3. Generate the task list

```
/tasks
```

Claude reads your `CLAUDE.md` and produces `TASKS.md`. Review it — the
Foundation section is fixed and cannot be reordered. Implementation tasks
can be adjusted. When ready, confirm to continue.

### 3a. Refine the task list (optional)

Add tasks that were not captured automatically:

```
/new-task
```

Claude asks what you want to add, delegates codebase research to the
task-researcher subagent, then appends a fully-specified task entry with
acceptance criteria, dependencies, files to modify, and risks.

Edit an existing task that needs more detail or a different scope:

```
/edit-task [number]
```

If you omit the number, Claude lists all tasks and asks which one to
edit. The task-editor subagent reads relevant code before the entry is
rewritten in place.

### 4. Execute

```
/execute
```

**Foundation phase** — verifies each make target in order, asks whether
to create the GitHub repo via `gh` or use an existing one, opens a test
PR to confirm CI runs end to end, pushes a test release tag to confirm
the release pipeline runs end to end. Reports `Foundation complete ✓`
and waits for your confirmation before proceeding.

**Implementation phase** — one task at a time: implement → lint (hook
fires automatically on every file edit) → test (subagent returns failures
only) → doc update (task-runner checks README.md, manpage stubs, and
inline examples and blocks the commit if any need updating) → commit.
Checkpoints after major groups.

**Completion** — final lint + test pass, summary of what was built,
reminder of how to trigger a release with `make release`.

---

## Commands reference

| Command | Description |
|---|---|
| `/init-project` | Scaffold a new project — creates Makefile, CI, packaging stubs, initial commit |
| `/tasks` | Generate `TASKS.md` from `CLAUDE.md` with Foundation + Implementation sections |
| `/execute` | Work through `TASKS.md`: Foundation phase, then one implementation task at a time |
| `/new-task` | Research a task idea and append a fully-specified entry to `TASKS.md` |
| `/edit-task [N]` | Rewrite an existing task entry in place (number optional — lists tasks if omitted) |
| `/commit` | Stage changes and create a conventional commit with approval |
| `/update-project` | Audit an existing project against the current plugin workflow and apply missing pieces |
| `/init-rust-cli` | Type skill invoked by `/init-project` — can also be called directly |
| `/init-claude-plugin` | Type skill for Claude Code plugins — manifests, structure, CI, skill-creator wired in |

---

## Project structure after /init-project (rust-cli example)

```
myapp/
├── CLAUDE.md                        your project plan
├── Cargo.toml
├── Makefile                         build/lint/test/package/docs/release
├── .gitignore
├── README.md                        stub to fill in
├── src/
│   ├── main.rs                      wires clap, delegates to modules
│   └── <module>/mod.rs              one stub per module from CLAUDE.md
├── .github/
│   ├── workflows/ci.yml             lint + test on every PR
│   └── workflows/release.yml        build + package + publish on v* tags
├── packaging/
│   ├── deb/control                  stub — finalised during packaging task
│   └── aur/PKGBUILD.template        stub — finalised during packaging task
├── scripts/
│   ├── build-deb.sh                 stub — finalised during packaging task
│   └── build-aur.sh                 stub — finalised during packaging task
├── docs/
│   └── man/<binary>.1.md            man page skeleton
└── .claude/
    ├── CLAUDE.md                    imports ../CLAUDE.md + plugin rules
    └── settings.json                wires post-edit-lint hook
```

The packaging stubs under `packaging/` and `scripts/` are intentionally
incomplete at this stage. They are filled in by the **Finalise deb
packaging** and **Finalise AUR packaging** tasks that `/tasks` adds at
the end of `TASKS.md`, once the full set of installed files is known.

---

## Extending the plugin

### Adding a new project type

Create `skills/init-<type>/SKILL.md` in this repository. The skill must:

1. Read `.claude/CLAUDE.md` to get the project plan
2. Implement all six Makefile targets for the type's toolchain
3. Set up the type-appropriate CI pipeline in `.github/workflows/`
4. Create packaging stubs with `TODO` markers if the type has a distribution
   format (npm publish, PyPI, Homebrew, etc.) — or skip packaging entirely
   if the type has none
5. Make an initial `git commit`
6. Tell the user to run `/tasks`

Register the new type in `skills/init-project/SKILL.md` under Step 2 so
`/init-project` knows to offer it.

### Adding a new project-type skill for a different package manager

If your project type uses a different packaging format (Homebrew, npm,
PyPI, snap, flatpak), create the equivalent of `init-rust-cli` for your
type. The packaging stubs pattern — create templates with `TODO` markers,
let `/tasks` generate finalisation tasks — applies to all types.
