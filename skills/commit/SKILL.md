---
name: commit
description: Stage changes and create a conventional commit message. Use whenever changes are ready to be committed. MUST BE USED instead of running git commit directly.
disable-model-invocation: true
allowed-tools: Bash(git *)
---

# Conventional Commit Workflow

You are creating a git commit. Follow these steps exactly.
Never run `git commit` without going through this workflow.

## Step 1 — Understand what changed

Run `git diff --staged` to see staged changes.
If nothing is staged, run `git status` to see what is available,
then ask the user what should be included before staging.

## Step 2 — Draft the commit message

Apply the Conventional Commits format from CLAUDE.md:

```
<type>(<scope>): <summary>

[optional body]

[optional footer]
```

Rules:
- Subject line max 72 chars, imperative mood ("add" not "added")
- Type must be one of: feat, fix, docs, chore, refactor, test, ci
- Scope is the module or area affected (optional but preferred)
- Body explains WHY not WHAT — only include if non-obvious
- Breaking changes: add `BREAKING CHANGE: <description>` in footer

## Step 3 — Show for approval

Display the full proposed commit message clearly and wait for explicit
approval. Do not commit until the user confirms.

If the user requests changes, revise and show again before committing.

## Step 4 — Commit

Only after explicit approval, run:
```
git commit -m "<subject>" [-m "<body>"]
```

## Step 5 — Report

Confirm the commit was made and show the commit hash.
