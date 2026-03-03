---
name: execute
description: Execute tasks from TASKS.md in order. Enforces foundation phase completion before implementation. Use after /tasks when the user is ready to start work.
disable-model-invocation: true
allowed-tools: Read, Write, Bash(make *), Bash(git *), Bash(gh *)
---

# Task Execution

You are executing the project task list. Read TASKS.md before doing
anything else. If TASKS.md does not exist, tell the user to run
/tasks first.

## Execution Rules

- Work through tasks **in the order defined in TASKS.md** — never reorder
- Complete **one task at a time** — never start the next until the current
  passes its acceptance criteria
- After each task, briefly report: what was done, what changed,
  acceptance criteria met
- If you hit a blocker, stop and ask — never guess and proceed
- Never modify task titles or acceptance criteria
- Always use `make` targets — never call build tools directly

The post-commit hook marks tasks done in TASKS.md automatically after
each commit — do not edit TASKS.md directly.

---

## Phase 1 — Foundation

Work through every Foundation task before touching any implementation.
The foundation phase has special handling for tasks that require
human interaction.

### Verify make build / lint / test

Run each target and confirm it exits 0. If a target fails:
- Show the error output
- Fix the issue (missing dependency, misconfiguration, etc.)
- Re-run until it passes
- Then mark the task complete

### Set up GitHub repository

Run `git remote -v` to check if a remote is already configured.

If a remote is already configured (set up by /init-rust-cli or manually),
skip straight to enabling branch protection.

If no remote exists, ask the user:
```
Do you already have a GitHub repository for this project?
  1. Yes — I have created it, please configure the remote and push
  2. No — please create it for me via gh CLI
```

If option 1: ask for the repository URL, then:
```
git remote add origin <url>
git push -u origin main
```

If option 2: ask for:
- Repository name (suggest the project name — run `grep -m1 "^# " .claude/CLAUDE.md` to get it)
- Visibility: public or private
- Organisation or personal account

Then create and push:
```
gh repo create <name> --<visibility> --source=. --remote=origin --push
```

After the remote is confirmed, enable branch protection on main:
```
gh api repos/<owner>/<repo>/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews=null \
  --field restrictions=null
```

Mark task complete only after remote is configured and main is pushed.

### Verify CI pipeline is live

Open a test PR:
```
git checkout -b ci/verify-pipeline
git commit --allow-empty -m "ci: verify pipeline is live"
```

> Use the pr-creator agent with title "ci: verify pipeline is live" and body "Foundation verification PR — safe to merge or close"

Use the ci-monitor agent to watch the pipeline:
> Use the ci-monitor agent to watch the PR pipeline until complete

If pipeline passes: mark task complete, tell the user they can merge
or close the PR.

If pipeline fails: show the failure summary from ci-monitor, fix the
issue, push a new commit to the same branch, and re-check. Pause and
ask the user if any step requires manual configuration such as:
- Adding GitHub Actions secrets
- Enabling Actions permissions on the repository
- Installing required tools or tokens

### Verify make package runs in CI

Push a test release tag:
```
git tag v0.0.1-test
git push origin v0.0.1-test
```

Use the ci-monitor agent to watch the release pipeline:
> Use the ci-monitor agent to watch the release pipeline for tag v0.0.1-test

If pipeline passes and artifacts are present in the GitHub Release:
mark task complete, then clean up:
```
gh release delete v0.0.1-test --yes
git push origin --delete v0.0.1-test
git tag -d v0.0.1-test
```

If pipeline fails: show failure summary, fix, re-tag and re-check.

### Foundation gate

When all Foundation tasks are checked off, report:

```
Foundation complete ✓

  make build  — working
  make lint   — working
  make test   — working
  CI pipeline — live and verified
  Release pipeline — live and verified

Ready to begin implementation.
```

Stop and wait for the user to confirm before proceeding to implementation.

---

## Phase 2 — Implementation (iterative loop)

Work through implementation tasks one at a time. For each task:

### 1. Create a task branch and record the current task

Before writing any code, create a branch and record the task title so the
post-commit hook can mark it done automatically:
- Type: use the task tag if present (`[feat]` → `feat`, `[fix]` → `fix`,
  `[refactor]` → `refactor`); default to `feat` for implementation tasks
- Slug: task title in lowercase with spaces replaced by hyphens,
  special characters removed (max 40 chars)

```
git checkout -b <type>/<slug>
echo "<exact task title>" > .claude/current-task
```

Never implement on main or on a previous task's branch.

### 2. Implement, test, and commit

Delegate the full implement → lint → test → commit cycle to the
task-runner agent, passing the task title:

> Use the task-runner agent to implement task: "<task title>"

The task-runner keeps implementation details out of this context.
It will read TASKS.md itself, implement the task, run tests, and
commit — returning only a summary.

If the task-runner reports test failures it could not resolve, stop
and ask the developer before continuing.

### 6. Open PR

> Use the pr-creator agent with title "<task title>" and body "Implements task: <task title>"

Show the PR URL to the developer and tell them:
> Please review and merge the PR. Let me know when it is merged.

Wait for the developer to confirm the PR is merged before continuing.

### 7. Continue to next task

Once the developer confirms the PR is merged, move to the next unchecked
task in TASKS.md — starting again from Step 1 with a new branch.
The post-commit hook already marked the task done when the commit was made.

### Checkpoints

Stop and wait for explicit user confirmation at these points:
- After all `[core]` tasks are complete
- After all `[cli]` tasks are complete
- When all tasks in TASKS.md are checked off

---

## Phase 3 — Completion

When all tasks are checked off:

1. Run a final verification:
   - Use the test-runner agent: all tests must pass
   - Use the lint-checker agent: lint must be clean
   - Confirm `make build` exits 0

2. Summarise what was built:
   - List all modules implemented
   - List all commands available
   - Confirm CI and release pipelines are live

3. Remind the user how to trigger a release:
   ```
   # Bump the version in the project's version file, then:
   make release
   ```
   The release pipeline will build and publish all release artifacts
   defined for this project type.
