---
name: continue
description: Resume an interrupted /execute session. Inspects git and GitHub state to determine where the session stopped, takes the correct recovery action, and advances to the next unchecked task in TASKS.md without repeating completed work.
disable-model-invocation: true
allowed-tools: Read, Bash(git *), Bash(gh *)
---

# Resume Interrupted Session

You are resuming an interrupted `/execute` session. Your job is to
determine exactly where the session stopped, recover from that state,
and continue from the correct point — without re-implementing anything
already marked `[x]` in TASKS.md.

## Step 1 — Read TASKS.md

Read `TASKS.md`. If it does not exist, tell the user and stop — there
is nothing to resume.

Find the **last checked task** (`- [x]`) and the **first unchecked
task** (`- [ ]`) in the Implementation section. Record both. If all
tasks are checked off, go to Step 6 (post-completion state).

## Step 2 — Collect git and GitHub state

Run these commands and record every output:

```
git branch --show-current
git status --short
git log --oneline -10
gh pr list --state all --limit 10 --json number,title,state,headRefName,mergedAt
```

## Step 3 — Classify the session state

Use the outputs from Step 2 to determine which state applies. Work
through the decision rules **in order** — apply the first rule that
matches and skip the rest.

### Rule A — Uncommitted work on a feature branch

Condition: `git status --short` shows modified or staged files AND
the current branch is not `main`.

Recovery:
1. Show the user a summary of the uncommitted changes.
2. Delegate to the task-runner agent to finish the current task:
   > Use the task-runner agent to implement task: "<last unchecked task title>"
3. After the task-runner commits, mark the task `[x]` in TASKS.md.
4. Open a PR: invoke the pr-creator agent with the commit summary as body.
5. Show the PR URL and say:
   > Please review and merge the PR. Run `/continue` again once it is merged.
6. Stop.

### Rule B — Clean branch with commits ahead of main, no open PR

Condition: `git status --short` is empty AND the current branch is not
`main` AND `git log main..HEAD` shows at least one commit AND `gh pr
list` shows no open PR for this branch.

Recovery:
1. Derive the PR title from the most recent commit subject.
2. Derive the PR body from all commits ahead of main.
3. Confirm the PR title with the user before creating.
4. Invoke the pr-creator agent with the confirmed title and body.
5. Show the PR URL and say:
   > Please review and merge the PR. Run `/continue` again once it is merged.
6. Stop.

### Rule C — Open PR exists and is not yet merged

Condition: `gh pr list` shows an open PR for the current branch with
state `OPEN`.

Recovery:
1. Show the PR URL and its title.
2. Tell the user:
   > The PR is still open. Please merge it, then run `/continue` again.
3. Stop.

### Rule D — PR merged but main not yet pulled

Condition: the current branch is not `main` AND `gh pr list` shows a
merged PR for this branch (state `MERGED`) AND `git log` on `main`
does not yet include the merge commit (i.e. `git log main..HEAD` still
shows commits).

Alternative trigger: current branch IS `main` AND `git log origin/main..HEAD`
shows no commits AND `git log HEAD..origin/main` shows commits (local
main is behind remote).

Recovery:
```
git checkout main
git pull
```

Then go to Step 4 to find the next task and continue.

### Rule E — Ambiguous or unexpected state

Condition: none of Rules A–D matched.

Recovery:
1. Print the raw output of `git status`, `git log --oneline -10`, and
   `gh pr list` so the user can see what was found.
2. Tell the user:
   > The session state is ambiguous. Please check the output above and
   > tell me what to do next, or run `/execute` to restart from the
   > next unchecked task.
3. Stop.

## Step 4 — Find the next unchecked task

After recovery (Rule D, or Rule A/B after PR merge), find the next
task to implement:

Grep `TASKS.md` for the first line matching `- [ ]` in the
Implementation section. If none exists, go to Step 6.

## Step 5 — Resume implementation

Create a task branch and delegate:

```
git checkout main
git pull
git checkout -b <type>/<slug>
```

- Type: use the task tag if present (`[feat]` → `feat`, `[fix]` →
  `fix`, `[cli]` → `feat`, `[core]` → `feat`); default to `feat`
- Slug: task title in lowercase, spaces → hyphens, special chars
  removed, max 40 chars

Then delegate to the task-runner agent:
> Use the task-runner agent to implement task: "<next task title>"

After the task-runner commits:
1. Mark the task `[x]` in TASKS.md.
2. Open a PR using the task-runner summary as body:
   > Use the pr-creator agent with title "<task title>" and body "<summary>"
3. Show the PR URL and say:
   > Please review and merge the PR. Let me know when it is merged.
4. Stop and wait for the user's confirmation before proceeding further.

## Step 6 — Post-completion state

If all tasks in TASKS.md are already checked `[x]` AND the working
tree is clean AND `main` is up to date:

Report:
```
All tasks complete.

  Last task: <title of last [x] task>
  Branch:    main (up to date)
  Status:    nothing to resume

Run /execute to start a new implementation phase, or make release
to publish the current version.
```

Then stop.

## Invariants (never violate these)

- Never re-implement a task already marked `[x]` in TASKS.md.
- Never commit directly to main.
- Never open a PR for a branch that already has an open PR.
- Never pull or reset a branch with uncommitted changes — report first.
- If a task is marked `[x]` but no commit and no PR exist for it,
  treat the task as complete and move to the next one (the mark is
  the source of truth, not the branch history).
