---
name: claude-plugin-ci
description: Creates GitHub Actions CI and release workflows for a Claude Code plugin project. Use as the second step of claude-plugin scaffolding.
tools: Read, Write, Bash(mkdir *), Bash(git *)
---

You are creating the GitHub Actions workflows for a Claude Code plugin project.

## Step 1 — Create .github/workflows/ci.yml

```yaml
name: CI

on:
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: sudo apt-get install -y jq rsync
      - run: make lint
      - run: make test
```

## Step 2 — Create .github/workflows/release.yml

```yaml
name: Release

on:
  push:
    tags: ['v*']

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: sudo apt-get install -y jq rsync
      - run: make lint
      - run: make test
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          generate_release_notes: true
```

## Step 3 — Commit

```
git add .github/
git commit -m "ci(scaffold): add GitHub Actions CI and release workflows"
```

## Step 4 — Explain pipeline requirements and confirm with developer

Present the following summary and ask the developer to confirm before continuing:

---

**CI pipeline — what is needed**

Two workflows have been created:

`ci.yml` — runs on every pull request
- Installs jq, runs `make lint` (JSON validation) and `make test` (structure check)
- No secrets required

`release.yml` — runs when a `v*` tag is pushed (triggered by `make release`)
- Validates the plugin, then creates a GitHub Release with auto-generated notes
- Required: `GITHUB_TOKEN` with write permissions — automatically provided by
  GitHub Actions. The workflow explicitly requests `permissions: contents: write`.
  Confirm your repository or organisation does not restrict this.

**What to check now**
1. Is GitHub Actions enabled on your repository? (Settings → Actions → Allow all actions)
2. Does your organisation restrict `GITHUB_TOKEN` permissions? If so, you may need
   to grant write access to contents at the repo or org level.

**Both pipelines will be tested end-to-end during the Foundation phase of
`/execute`** — a test PR will verify `ci.yml` and a test tag will verify
`release.yml` before any implementation work begins.

---

Ask: "Are there any pipeline configuration questions, or are you ready to continue?"

Wait for the developer's response. If they need to adjust settings, help them
or note what needs to be done. Once they confirm they are ready, proceed.

## Step 5 — Report

Confirm both workflow files were created and committed. Summarise any
actions the developer said they need to take before the Foundation phase.
