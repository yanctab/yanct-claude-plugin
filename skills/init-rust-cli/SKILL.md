---
name: init-rust-cli
description: Implement Rust CLI scaffolding for a project initialised with /init-project. Implements Makefile targets, creates Cargo.toml, src/ structure, GitHub Actions, and packaging templates.
disable-model-invocation: true
allowed-tools: Read, Write, Bash(mkdir *), Bash(touch *), Bash(cargo init *), Bash(cargo add *), Bash(chmod *), Bash(rustup *), Bash(sudo apt-get *), Bash(git *), Bash(gh *)
---

# Rust CLI Initialisation

You are orchestrating the Rust-specific scaffolding for a project that has
already been initialised with /init-project. A Makefile and .claude/ directory
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

## Step 3 — Ask about crates.io publishing

Ask the developer:

```
Do you plan to publish this crate to crates.io?
  1. Yes — the release pipeline will publish automatically when a version
     tag is pushed. You will need a CRATES_IO_TOKEN secret in GitHub Actions.
  2. No — skip crates.io setup (can be added later via /update-project)
```

Note the answer. The CI phase will explain how to create and add the
token if the developer chooses yes. If they choose no, the publish step
will be included in the workflow but will skip silently until a token is added.

## Step 4 — Set up GitHub remote

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
- Repository name (suggest the project name from CLAUDE.md)
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

## Step 5 — Makefile phase

```
git checkout -b chore/scaffold/makefile
```

> Use the rust-cli-makefile agent to implement the Makefile targets

Push and open a PR:
```
git push -u origin chore/scaffold/makefile
gh pr create \
  --title "chore(scaffold): implement Makefile targets" \
  --body "Scaffold phase 1/5 — implements all Makefile targets for the Rust CLI project."
```

Show the PR URL. Tell the developer:
> Please review and merge this PR. Let me know when it is merged.

Wait for confirmation, then:
```
git checkout main && git pull
```

## Step 6 — Cargo phase

```
git checkout -b chore/scaffold/cargo
```

> Use the rust-cli-cargo agent to initialise the Cargo project and src/ structure

Push and open a PR:
```
git push -u origin chore/scaffold/cargo
gh pr create \
  --title "chore(scaffold): initialise Cargo project and module stubs" \
  --body "Scaffold phase 2/5 — cargo init, dependencies, and src/ module structure."
```

Show the PR URL. Tell the developer:
> Please review and merge this PR. Let me know when it is merged.

Wait for confirmation, then:
```
git checkout main && git pull
```

## Step 7 — CI phase

```
git checkout -b chore/scaffold/ci
```

> Use the rust-cli-ci agent to create the GitHub Actions workflows

Push and open a PR:
```
git push -u origin chore/scaffold/ci
gh pr create \
  --title "ci(scaffold): add GitHub Actions CI and release workflows" \
  --body "Scaffold phase 3/5 — ci.yml (PR checks) and release.yml (tag-triggered releases)."
```

Show the PR URL. Tell the developer:
> Please review and merge this PR. Let me know when it is merged.

Wait for confirmation, then:
```
git checkout main && git pull
```

## Step 8 — Packaging phase

```
git checkout -b chore/scaffold/packaging
```

> Use the rust-cli-packaging agent to create the packaging templates and build scripts

Push and open a PR:
```
git push -u origin chore/scaffold/packaging
gh pr create \
  --title "chore(scaffold): add packaging templates and build scripts" \
  --body "Scaffold phase 4/5 — .deb control file, AUR PKGBUILD template, and build scripts."
```

Show the PR URL. Tell the developer:
> Please review and merge this PR. Let me know when it is merged.

Wait for confirmation, then:
```
git checkout main && git pull
```

## Step 9 — Finalize phase

```
git checkout -b chore/scaffold/finalize
```

> Use the rust-cli-finalize agent to add docs, README, settings, and gitignore

Push and open a PR:
```
git push -u origin chore/scaffold/finalize
gh pr create \
  --title "chore(scaffold): add docs, settings, and gitignore" \
  --body "Scaffold phase 5/5 — man page stub, README, .claude/settings.json, .gitignore, and local toolchain setup."
```

Show the PR URL. Tell the developer:
> Please review and merge this PR. Let me know when it is merged.

Wait for confirmation, then:
```
git checkout main && git pull
```

## Step 10 — Report

When all phases are merged, summarise:
- The 5 PRs that were merged and what each contained
- Next step: run `/execute` — it will verify the Foundation (make build/lint/test,
  CI pipeline, release pipeline) before implementation begins
