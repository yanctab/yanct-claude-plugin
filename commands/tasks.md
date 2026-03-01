---
description: Break down CLAUDE.md into an ordered task list in TASKS.md
disable-model-invocation: true
allowed-tools: Read, Write
---

# Task Breakdown

You are breaking down a project plan into an ordered, actionable task list.

## Step 1 — Read project context

Read `.claude/CLAUDE.md`. This file imports the root `CLAUDE.md` via
`@../CLAUDE.md` so you will get the full project plan, architecture,
and Claude Code rules transitively in a single read.

If `.claude/CLAUDE.md` does not exist, tell the user to run
`/init-project` first before planning tasks.

## Step 2 — Foundation phase tasks (always required, always first)

The following tasks are mandatory for every project. They must appear
as a dedicated Foundation section at the top of TASKS.md and must all
be completed and verified before any implementation task is started.
They cannot be reordered or skipped.

```
## Foundation (must complete before any implementation)

- [ ] **Verify make build** [foundation] S
  - Acceptance: `make build` exits 0 and produces a binary
  - Depends on: nothing

- [ ] **Verify make lint** [foundation] S
  - Acceptance: `make lint` exits 0 with no warnings or errors
  - Depends on: Verify make build

- [ ] **Verify make test** [foundation] S
  - Acceptance: `make test` exits 0 — all tests pass (stubs are fine at this stage)
  - Depends on: Verify make lint

- [ ] **Set up GitHub repository** [foundation] S
  - Acceptance: remote configured, initial scaffold pushed to main,
    branch protection on main enabled
  - Note: Claude will ask whether to create the repo via gh CLI or
    whether the user has already created it
  - Depends on: Verify make test

- [ ] **Verify CI pipeline is live** [foundation] S
  - Acceptance: a PR is opened, GitHub Actions runs ci.yml, all
    checks pass — pipeline is confirmed working end to end
  - Note: may require the user to configure GitHub Actions secrets
    or tokens before this step — Claude will pause and ask
  - Depends on: Set up GitHub repository

- [ ] **Verify make package runs in CI** [foundation] M
  - Acceptance: release.yml triggered by a test tag (v0.0.1-test),
    all expected release artifacts present in the GitHub Release
    (exact artifacts depend on project type — check .github/workflows/release.yml)
  - Note: test tag should be deleted after verification
  - Depends on: Verify CI pipeline is live
```

Only after all Foundation tasks are checked off may implementation begin.

## Step 3 — Derive implementation tasks

Break the architecture and feature set into tasks. For each task:

- Write a clear one-line title
- State acceptance criteria (how to know it is done)
- Tag it: `[core]`, `[cli]`, `[config]`, `[test]`, `[docs]`, `[packaging]`
- Note dependencies: "depends on: <task title>"
- Estimate complexity: S, M, L

Rules:
- Every implementation task must include tests as part of its
  acceptance criteria — never defer testing to a separate task
- Tasks must be ordered so each one builds on a stable, tested base
- No task should touch more than one module — keep scope narrow
- Packaging scripts and distribution templates created by the project-type
  init skill are stubs — they carry TODO markers and must be finalised once
  the full set of installed files, runtime dependencies, and config locations
  is known. Read the project type's init skill output to understand what
  packaging stubs were created, then add appropriate finalisation tasks
  at the end of the implementation list. Do not hardcode packaging format
  names — derive them from what actually exists in the project (e.g. if
  scripts/build-deb.sh exists add a deb finalisation task; if it does not,
  do not add one).

## Step 4 — Write TASKS.md

Produce TASKS.md in the project root:

```markdown
# Tasks: <project name>

## Foundation
> All foundation tasks must be complete and verified before
> any implementation task is started.

- [ ] **Verify make build** [foundation] S
  - Acceptance: `make build` exits 0 and produces a binary
  - Depends on: nothing

- [ ] **Verify make lint** [foundation] S
  - Acceptance: `make lint` exits 0, no warnings
  - Depends on: Verify make build

- [ ] **Verify make test** [foundation] S
  - Acceptance: `make test` exits 0
  - Depends on: Verify make lint

- [ ] **Set up GitHub repository** [foundation] S
  - Acceptance: remote configured, scaffold pushed, branch protection on main
  - Depends on: Verify make test

- [ ] **Verify CI pipeline is live** [foundation] S
  - Acceptance: PR opened, ci.yml passes end to end
  - Depends on: Set up GitHub repository

- [ ] **Verify make package runs in CI** [foundation] M
  - Acceptance: release.yml triggered by test tag, all expected release artifacts produced
  - Depends on: Verify CI pipeline is live

## Implementation

- [ ] **Implement <module>** [core] M
  - Acceptance: <specific behaviour from CLAUDE.md>, unit tests pass
  - Depends on: Foundation complete

...
```

## Step 5 — Confirm

Tell the user to review TASKS.md. Remind them that the Foundation
section is fixed and cannot be reordered. Implementation tasks can be
reordered or removed as needed. When ready, say "start" to begin execution.
