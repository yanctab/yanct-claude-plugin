---
name: init-rust-cli
description: Implement Rust CLI scaffolding for a project initialised with /init-project. Implements Makefile targets, creates Cargo.toml, src/ structure, GitHub Actions, and packaging templates.
disable-model-invocation: true
allowed-tools: Read, Write, Bash(mkdir *), Bash(touch *), Bash(cargo init *), Bash(cargo add *), Bash(chmod *), Bash(rustup *), Bash(git *)
---

# Rust CLI Initialisation

You are orchestrating the Rust-specific scaffolding for a project that has
already been initialised with /init-project. A Makefile and .claude/ directory
already exist.

Run the following agents in order. Each agent performs one phase and commits
at the end. Wait for each agent to complete before starting the next.

## Step 1 — Read project context

Read `.claude/CLAUDE.md`. If it does not exist, tell the user to run
`/init-project` first and stop.

## Step 2 — Run scaffolding agents in sequence

> Use the rust-cli-makefile agent to implement the Makefile targets

> Use the rust-cli-cargo agent to initialise the Cargo project and src/ structure

> Use the rust-cli-ci agent to create the GitHub Actions workflows

> Use the rust-cli-packaging agent to create the packaging templates and build scripts

> Use the rust-cli-finalize agent to add docs, README, settings, and gitignore

## Step 3 — Report

When all agents have completed, summarise:
- What was created (one line per agent phase)
- The 5 commits that were made
- Next step: run `/tasks` to plan implementation
