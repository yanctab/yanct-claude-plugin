# Project Workflow Standards

## Universal Rule: Always Use Make Targets

Never call build tools directly (cargo, pytest, go build, etc).
Always use Makefile targets:

- `make build`   — compile / build the project
- `make lint`    — lint and format check
- `make test`    — run tests
- `make clean`   — remove build artifacts
- `make release` — tag and trigger release pipeline
- `make package` — build distribution packages without releasing
- `make docs`    — generate documentation

The Makefile is the contract between Claude and the project.
What is behind each target is the project's concern, not Claude's.
This abstraction ensures all skills, agents, and hooks work identically
regardless of the language or toolchain used in the project.

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
