---
name: rust-cli-ci
description: Creates GitHub Actions CI and release workflows for a Rust CLI project. Use as the third step of rust-cli scaffolding.
tools: Read, Write, Bash(mkdir *), Bash(git *)
---

You are creating the GitHub Actions workflows for a Rust CLI project.

## Step 1 — Create .github/workflows/ci.yml

```yaml
name: CI

on:
  pull_request:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
        with:
          components: rustfmt, clippy
      - run: make lint
      - run: make test
```

## Step 2 — Create .github/workflows/release.yml

Read `Cargo.toml` to get the binary name for the release artifacts list.

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
      - name: Extract binary name
        run: echo "BINARY=$(grep '^name' Cargo.toml | head -1 | sed 's/.*= \"//;s/\"//')" >> $GITHUB_ENV
      - uses: dtolnay/rust-toolchain@stable
        with:
          targets: x86_64-unknown-linux-musl
      - run: sudo apt-get install -y musl-tools
      - run: make build
      - run: make package
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: |
            target/x86_64-unknown-linux-musl/release/${{ env.BINARY }}
            dist/*.deb
            dist/PKGBUILD
```

## Step 3 — Commit

```
git add .github/
git commit -m "ci(scaffold): add GitHub Actions CI and release workflows"
```

## Step 4 — Explain pipeline requirements and confirm with developer

Present the following summary to the developer and ask them to confirm
before continuing:

---

**CI pipeline — what is needed**

Two workflows have been created:

`ci.yml` — runs on every pull request
- Runs `make lint` and `make test`
- Required: GitHub Actions must be enabled on the repository (it is by
  default on public repos; check Settings → Actions on private repos)
- No secrets required

`release.yml` — runs when a `v*` tag is pushed
- Builds a musl static binary, creates .deb and PKGBUILD, publishes a
  GitHub Release with all artifacts
- Required: `GITHUB_TOKEN` with write permissions — this is automatically
  provided by GitHub Actions, but the workflow explicitly requests
  `permissions: contents: write`. Confirm that your repository does not
  have a restrictive organisation-level token policy that would block this.
- No additional secrets required for the basic scaffold

**What to check now**
1. Is GitHub Actions enabled on your repository? (Settings → Actions → Allow all actions)
2. Does your organisation restrict `GITHUB_TOKEN` permissions? If so, you
   may need to set `Allow GitHub Actions to create and approve pull requests`
   and grant write access to contents at the repo or org level.
3. Do you plan to add any additional publishing steps (crates.io, package
   registry, notifications)? If so, those secrets will need to be added to
   the repository before the release pipeline can use them.

**Both pipelines will be tested end-to-end during the Foundation phase of
`/execute`** — a test PR will verify `ci.yml` and a test tag will verify
`release.yml` before any implementation work begins.

---

Ask: "Do you have any questions about the pipeline setup, or are there
additional secrets you need to configure before we continue?"

Wait for the developer's response. If they need to configure secrets or
permissions, help them do so or note what needs to be done. Once they
confirm they are ready, proceed to report.

## Step 5 — Report

Confirm both workflow files were created and committed. Summarise any
actions the developer said they need to take before the Foundation phase.
