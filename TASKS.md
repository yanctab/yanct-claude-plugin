# TASKS

## Implementation

- [x] **Automate plugin version increment and git tag on release** [core] M
  - Acceptance: `make release` interactively prompts for major/minor/patch, writes the new semver into `.claude-plugin/plugin.json` via `jq`, commits the bump with message `chore(release): bump version to v<new>`, creates an annotated tag `v<new>`, and pushes both the commit and the tag; running `make release` with no uncommitted changes on a clean branch succeeds end-to-end with the correct version reflected in `plugin.json` and `git tag`
  - Depends on: none
  - Modify: `Makefile`
  - Create: none
  - Reuse: `Makefile:VERSION` (existing `jq -r '.version'` read pattern), `.claude-plugin/plugin.json` (sole version source of truth)
  - Risks: `make` variables (`VERSION`, `PLUGIN_NAME`, `CACHE_DIR`) are expanded at parse time, so the bumped version will not be visible to those variables within the same `make` invocation — the bump shell script must use local shell variables rather than make variables for the new version; interactive `read` prompts require the target to be run without `-n` or parallel flags; `jq` in-place edit requires a temp file then `mv` (no `--in-place` flag)

- [x] **Enforce documentation, examples, README.md, and manpage updates as a post-step in skill execution** [docs] M
  - Acceptance: the `task-runner` agent includes a mandatory post-implementation step that checks whether any user-facing commands, options, or examples changed and, if so, updates `README.md`, any `docs/man/*.md` manpage stubs, and inline skill/command examples before committing; a task that adds or modifies a command without updating docs causes the agent to block and apply the doc updates rather than skipping them; the doc-update step is verified by a checklist in the agent that must be satisfied before the commit step runs
  - Depends on: Automate plugin version increment and git tag on release
  - Modify: `agents/task-runner.md`, `skills/execute/SKILL.md`
  - Create: none
  - Reuse: `agents/rust-cli-finalize.md:Step 2` (manpage stub pattern), `agents/rust-cli-finalize.md:Step 3` (README pattern), `skills/execute/SKILL.md:Phase 2 Step 2` (task-runner invocation pattern)
  - Risks: skills are markdown instructions, not code — the "enforcement" is prompt-level and relies on the agent following instructions; projects that have no `docs/` directory or no manpage stub require the step to be conditional on what actually exists; the doc-update scope must be kept narrow to avoid spurious edits on unrelated files

- [ ] **Add /pr-creator slash command to invoke the pr-creator agent standalone** [cli] S
  - Acceptance: a `commands/pr-creator.md` file exists with a valid front-matter and delegates to `agents/pr-creator.md`; running `/pr-creator` in a Claude Code session with a feature branch presents the user with a PR title prompt, pushes the branch, and opens a GitHub PR; the command is listed in `README.md` alongside other commands
  - Depends on: Enforce documentation, examples, README.md, and manpage updates as a post-step in skill execution
  - Modify: `README.md`
  - Create: `commands/pr-creator.md`
  - Reuse: `agents/pr-creator.md:pr-creator` (existing agent definition), `commands/commit.md` (front-matter and delegation pattern)
  - Risks: the existing `agents/pr-creator.md` expects callers to supply both `title` and `body`; the standalone command must either prompt the user for these values or derive them from `git log` — the prompting strategy must be defined clearly in the command to avoid silent failures when invoked with no arguments

- [ ] **Add /continue skill to resume interrupted /execute sessions** [cli] M
  - Acceptance: `commands/continue.md` and `skills/continue/SKILL.md` exist; invoking `/continue` inspects `git status`, `git log`, and `gh pr list` to determine whether the session stopped mid-implementation (uncommitted work), after a commit but before a PR was opened, while waiting for a PR merge, or after a merge that was not yet pulled; for each state the skill takes the correct recovery action (commit and open PR, open PR only, pull and proceed, or prompt the user) without restarting already-completed work; a manually triggered `/continue` on a clean post-merge state correctly advances to the next unchecked task in TASKS.md and reports the recovered position
  - Depends on: Add /pr-creator slash command to invoke the pr-creator agent standalone
  - Modify: `README.md`
  - Create: `commands/continue.md`, `skills/continue/SKILL.md`
  - Reuse: `skills/execute/SKILL.md:Phase 2` (step ordering and task-finding pattern), `agents/pr-creator.md:pr-creator` (PR opening), `agents/task-runner.md:Step 7` (commit guard), `commands/commit.md` (front-matter and delegation pattern)
  - Risks: state detection relies entirely on git and gh output — ambiguous states (e.g. committed but branch not pushed, or PR open but already merged locally) require explicit decision rules to avoid looping; the skill must never re-implement a task already marked `[x]` in TASKS.md; the skill is prompt-only so recovery logic correctness depends on the model following branching instructions reliably
