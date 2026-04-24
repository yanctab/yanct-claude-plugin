---
name: init-claude-plugin
description: Implement Claude Code plugin scaffolding for a project initialised with /init-project. Creates plugin manifests, directory structure, Makefile, GitHub Actions, and wires in the skill-creator plugin as a dev dependency.
disable-model-invocation: true
allowed-tools: Read, Write, Bash(mkdir *), Bash(touch *), Bash(git *), Bash(gh *), Bash(rsync *)
---

# Claude Plugin Initialisation

You are orchestrating the Claude-plugin-specific scaffolding for a project that has
already been initialised with /init-project. A Makefile stub and .claude/ directory
already exist.

## Step 1 — Read project context

Read `.claude/CLAUDE.md`. If it does not exist, tell the user to run
`/init-project` first and stop.

## Step 2 — Initialise git repository and commit scaffold files

If `.git` does not exist, run:
```
git init
```

Commit the files that /init-project created. This must always happen —
regardless of whether git was just initialised or already existed with commits.
Stage only the known init-project output files — never use `git add .` or
`git add -A`:
```
git add .claude/CLAUDE.md .claude/settings.json Makefile
git commit -m "chore: initial project structure"
```

## Step 3 — Set up GitHub remote

Run `git remote -v` to check if a remote is already configured.

If no remote exists, ask the developer:

```
To open a PR for each scaffold phase, a GitHub repository is needed.
Do you already have one?
  1. Yes — provide the repository URL and I will configure the remote
  2. No — I will create one for you via gh CLI
```

If option 1: ask for the URL, then:
```
git remote add origin <url>
git push -u origin main
```

If option 2: ask for:
- Repository name (suggest the plugin name from CLAUDE.md)
- Visibility: public or private
- Organisation or personal account

Then create and push:
```
gh repo create <name> --<visibility> --source=. --remote=origin --push
```

If a remote is already configured, push main if it has not been pushed yet:
```
git push -u origin main
```

Mark this step complete once the remote is configured and main is pushed.

## Step 4 — Structure phase

```
git checkout -b chore/scaffold/structure
```

> Use the claude-plugin-structure agent to create the plugin manifests,
> directory skeleton, and Makefile

> Use the pr-creator agent with title "chore(scaffold): add plugin manifests, directory structure, and Makefile" and body "Scaffold phase 1/3 — .claude-plugin/plugin.json, marketplace.json, commands/ skills/ agents/ hooks/ directories, and Makefile with validate targets."

Show the PR URL. Tell the developer:
> Please review and merge this PR. Let me know when it is merged.

Wait for confirmation, then:
```
git checkout main && git pull
```

## Step 5 — CI phase

```
git checkout -b chore/scaffold/ci
```

> Use the claude-plugin-ci agent to create the GitHub Actions workflows

> Use the pr-creator agent with title "ci(scaffold): add GitHub Actions CI and release workflows" and body "Scaffold phase 2/3 — ci.yml (JSON validation on every PR) and release.yml (GitHub Release on version tags)."

Show the PR URL. Tell the developer:
> Please review and merge this PR. Let me know when it is merged.

Wait for confirmation, then:
```
git checkout main && git pull
```

## Step 6 — Finalize phase

```
git checkout -b chore/scaffold/finalize
```

> Use the claude-plugin-finalize agent to add README, .gitignore, and settings

> Use the pr-creator agent with title "chore(scaffold): add README, .gitignore, and settings" and body "Scaffold phase 3/3 — README stub, .gitignore, and .claude/settings.json with skill-creator dev dependency note."

Show the PR URL. Tell the developer:
> Please review and merge this PR. Let me know when it is merged.

Wait for confirmation, then:
```
git checkout main && git pull
```

## Step 7 — Report

When all phases are merged, summarise:
- The 3 PRs that were merged and what each contained
- Remind the developer to install the skill-creator plugin in Claude Code:
  ```
  /plugin marketplace add claude-plugins-official/skill-creator
  /plugin install skill-creator@skill-creator
  ```
- Next step: run `/new-prd` to capture the first feature as a PRD,
  then `/prd-to-issues` to break it into implementation slices, and
  `/execute <issue>` to implement each slice test-first
