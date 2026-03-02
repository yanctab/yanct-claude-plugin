# Project Workflow Standards

## Universal Rule: Always Use Make Targets

Never call build tools directly (cargo, pytest, go build, etc).
Always use Makefile targets:

- `make setup`   — install all tools and dependencies to work on the project
- `make build`   — compile / build the project
- `make lint`    — lint and format check
- `make test`    — run tests
- `make clean`   — remove build artifacts
- `make install` — install the project locally
- `make release` — tag and trigger release pipeline
- `make package` — build distribution packages without releasing
- `make docs`    — generate documentation

The Makefile is the contract between Claude and the project.
What is behind each target is the project's concern, not Claude's.
This abstraction ensures all skills, agents, and hooks work identically
regardless of the language or toolchain used in the project.

## make setup is a living target

`make setup` must always reflect the complete set of tools and system
dependencies needed to work on the project from a clean machine.

**Whenever a task introduces a new external tool, system package, or
toolchain component, update `make setup` in the Makefile to include it.**

This applies to: new language runtimes, CLI tools, system libraries,
compiler targets, code generators, or any other dependency that is not
installed by the project's own package manager (i.e. not `cargo add`,
`npm install`, etc.).

## Version Control

- Always use GitHub
- Never commit directly to main — always feature branches + PRs
- Branch naming: `<type>/<short-description>`

## Commit Format

Conventional Commits — no exceptions:

```
<type>(<scope>): <summary>

[optional body — explain why, not what]

[optional footer]
BREAKING CHANGE: <description>
```

Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci`
Subject line: max 72 chars, imperative mood

## General Rules

- Never leave TODO comments in committed code
- Do not silently swallow errors
- Ask before making decisions outside the current task scope
- All user-facing output must be handled by a dedicated display module
