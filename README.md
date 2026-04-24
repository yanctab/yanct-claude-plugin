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
Write CLAUDE.md → /init-project → /new-prd → /prd-to-issues → /execute <issue>
```

Each phase has a clear purpose and produces a concrete artifact:

**`/init-project`** reads your `CLAUDE.md` (the project plan you write),
asks what type of project this is, creates the `.claude/` directory
structure with a Makefile, then hands off to the appropriate type skill
to implement the targets and set up the toolchain, CI pipeline, and
packaging stubs. This bootstrap is the only non-issue-driven step.

**`/new-prd`** captures a feature idea as a Product Requirements
Document and files it as a GitHub issue — no code changes. Claude
delegates codebase research to the prd-researcher subagent,
synthesises a module sketch from the current conversation and the
codebase (no interview), checks the sketch with you (the only
freeform confirmation step), then drafts a PRD — Problem Statement,
Solution, User Stories, Implementation Decisions, Testing Decisions,
Out of Scope, Further Notes — and runs `gh issue create` to file it.
The intended workflow: spend planning tokens up front with a capable
model, then hand the resulting issue to a cheaper coding session for
implementation.

**`/prd-to-issues`** takes a PRD issue (the one `/new-prd` just filed,
or any existing PRD-shaped GitHub issue) and breaks it into
independently-grabbable implementation issues using vertical
tracer-bullet slices — each slice a narrow but complete path through
every relevant layer. The issue-slicer subagent fetches the PRD,
explores the codebase, drafts a numbered breakdown (title, HITL/AFK,
blocked-by, user stories covered, layers touched), iterates with you
until you approve, then files each slice as its own issue in
dependency order so *Blocked by* fields reference real issue numbers.

**`/execute`** implements a single GitHub issue using test-driven
development. It takes an issue number or URL as input, hands off to
the issue-runner subagent, and prints the resulting PR URL. The agent
rejects PRD issues (run `/prd-to-issues` on those first), creates a
branch, then runs a red-green-[refactor] loop per acceptance criterion
on the issue: write one failing test, write the minimum code to make
it pass, commit, optionally refactor only the code just written.
Every test and every line of code traces back to an acceptance
criterion on the issue — no speculative features. One issue, one
squash-merged PR.

### Context management

Subagents keep verbose output out of the main session:

- **issue-runner** — implements a single GitHub issue in a subagent using
  test-driven red-green-[refactor] cycles, commits per cycle, and opens
  a squash-merge PR. The main session only sees the final report.
- **prd-researcher** — does deep codebase research for `/new-prd`, then
  drafts the PRD and files it as a GitHub issue. Heavy research and
  template synthesis happen in the subagent, so the main session only
  sees the resulting issue URL.
- **issue-slicer** — for `/prd-to-issues`: fetches the parent PRD,
  explores the codebase for integration layers, drafts vertical
  tracer-bullet slices, and files each approved slice as a GitHub
  issue. The main session only sees the slice breakdown and the
  filed issue URLs.
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
be filled in. Finalise the packaging as its own PRD → issue → `/execute`
flow once the feature set stabilises.

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
`/new-prd` can synthesise feature specs.

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

### 3. Capture a feature as a PRD

Every feature starts as a PRD filed on GitHub. Spend the planning
tokens up front with a capable model; the resulting issue can be
handed to a cheaper coding session later.

```
/new-prd
```

Claude researches the codebase via the prd-researcher subagent,
synthesises a module sketch from the current conversation and the
codebase (no interview), shows it to you to sanity-check, then drafts
a PRD (Problem, Solution, User Stories, Implementation Decisions,
Testing Decisions, Out of Scope, Further Notes) and files it as a
GitHub issue via `gh issue create`.

### 4. Break the PRD into implementation slices

```
/prd-to-issues <PRD-issue-number-or-URL>
```

Claude fetches the PRD, researches integration layers via the
issue-slicer subagent, and proposes a numbered breakdown of vertical
tracer-bullet slices — each a narrow end-to-end path through every
relevant layer. Iterate with Claude on granularity and dependencies;
on approval, the agent files each slice as a GitHub issue in
dependency order.

### 5. Execute each slice

To implement a single slice using test-driven development:

```
/execute <issue-number-or-URL>
```

Claude invokes the issue-runner subagent which:

- Fetches the issue and rejects it if it looks like a PRD (run
  `/prd-to-issues` on the PRD first to get implementation slices).
- Creates a feature branch off `main`.
- For each checkbox in the issue's `## Acceptance criteria`, runs a
  red-green loop: write one failing test through the public interface,
  write the minimum code to make it pass, commit, optionally refactor
  only the code just written.
- Runs the doc-update checklist (README, manpage stubs, inline examples)
  if any user-facing interface changed.
- Opens a squash-merge PR with `Closes #<issue-number>` and prints the
  URL.

Review the PR and squash-merge it. Run `/execute` again on the next
issue when you are ready.

---

## Commands reference

| Command | Description |
|---|---|
| `/init-project` | Scaffold a new project — creates Makefile, CI, packaging stubs, initial commit |
| `/new-prd` | Synthesise a PRD from conversation + codebase context, confirm modules with you, file as a GitHub issue |
| `/prd-to-issues <issue>` | Break a PRD issue into vertical tracer-bullet implementation slices, iterate on granularity, file each as a dependent GitHub issue |
| `/execute <issue>` | Implement a single non-PRD GitHub issue using test-driven development — one squash-merged PR per issue |
| `/commit` | Stage changes and create a conventional commit with approval |
| `/pr-creator` | Push the current branch and open a GitHub pull request |
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
incomplete at this stage. Finalise them as their own PRD → issue →
`/execute` flow once the full set of installed files is known.

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
6. Tell the user to run `/new-prd` to capture their first feature

Register the new type in `skills/init-project/SKILL.md` under Step 2 so
`/init-project` knows to offer it.

### Adding a new project-type skill for a different package manager

If your project type uses a different packaging format (Homebrew, npm,
PyPI, snap, flatpak), create the equivalent of `init-rust-cli` for your
type. The packaging stubs pattern — create templates with `TODO` markers,
leave them incomplete until the feature set stabilises — applies to all
types.
