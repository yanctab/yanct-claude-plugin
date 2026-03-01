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

## Step 4 — Report

Confirm both workflow files were created and committed.
