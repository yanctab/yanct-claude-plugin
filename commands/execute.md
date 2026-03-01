---
description: Execute tasks from TASKS.md — foundation phase then implementation
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
- After completing each task, mark it done in TASKS.md: `- [x]`
- After each task, briefly report: what was done, what changed,
  acceptance criteria met
- If you hit a blocker, stop and ask — never guess and proceed
- Never modify task titles or acceptance criteria — only tick checkboxes
- Always use `make` targets — never call build tools directly

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

Ask the user:
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
- Repository name (suggest the project name from CLAUDE.md)
- Visibility: public or private
- Organisation or personal account

Then create and push:
```
gh repo create <name> --<visibility> --source=. --remote=origin --push
```

After pushing, enable branch protection on main:
```
gh api repos/<owner>/<repo>/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews=null \
  --field restrictions=null
```

Mark task complete only after remote is configured and scaffold is pushed.

### Verify CI pipeline is live

Open a test PR:
```
git checkout -b ci/verify-pipeline
git commit --allow-empty -m "ci: verify pipeline is live"
git push -u origin ci/verify-pipeline
gh pr create --title "ci: verify pipeline is live" --body "Foundation verification PR — safe to merge or close"
```

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

### 1. Implement

Write the code for the task. Follow all rules in .claude/CLAUDE.md.
Never call build tools directly — all checks go through make targets.

### 2. Lint (automatic)

The post-edit hook runs `make lint` automatically after each file edit.
If the hook reports a failure, fix it before continuing.
Do not manually run lint — the hook handles it.

### 3. Test

After implementation is complete, delegate to the test-runner agent:
> Use the test-runner agent to run the test suite

If all tests pass: proceed to commit.
If tests fail: fix the failures, then re-run the test-runner agent.
Repeat until all tests pass.

### 4. Commit

When the task passes all tests, invoke the commit command:
> /commit

Do not run git commit directly — always go through /commit to ensure
the commit message follows the Conventional Commits format.

### 5. Mark complete and continue

Tick the task in TASKS.md and move to the next one.

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
