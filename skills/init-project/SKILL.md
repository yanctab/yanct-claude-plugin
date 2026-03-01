---
name: init-project
description: Initialise a new project repository with .claude/ structure, Makefile, and CI. Use when starting a new project from scratch or from an existing CLAUDE.md plan.
disable-model-invocation: true
allowed-tools: Read, Write, Bash(mkdir *), Bash(touch *), Bash(cp *)
---

# Project Initialisation

You are initialising a new project. Your job is to set up the generic
scaffolding that applies to every project regardless of type, then
hand off to a project-type specific skill to fill in the details.

## Step 1 — Read existing context

Check if a CLAUDE.md exists in the project root (not in .claude/):
- If yes: read it fully. It is the source of truth for project name,
  purpose, architecture, subcommands, modules, and constraints.
  Do NOT ask questions already answered there.
- If no: ask the user for a brief project description before continuing.

## Step 2 — Ask project type

Ask the user which type of project this is. Present the available types:

1. rust-cli — Rust binary, musl static build, .deb + AUR packaging
2. web — static or server-side web project (if /init-web skill is installed)
3. other — ask for details; Claude will set up a generic Makefile and note
   that no type-specific skill exists yet

Each project type has a dedicated init skill that implements the Makefile
targets and sets up the type-specific toolchain, CI, and packaging.
New types can be added by installing additional init skills (e.g.
`/init-python-cli`, `/init-web`, `/init-go-cli`).

Do not proceed until you have an answer.

## Step 3 — Create generic .claude/ structure

Create the following in the project root. Do not create any
language-specific files yet — that is handled in Step 5.

```
.claude/
├── CLAUDE.md          # project-specific context (see template below)
├── skills/            # empty, project-type skill will populate
├── agents/            # empty, project-type skill will populate
└── hooks/             # empty, project-type skill will populate
```

### .claude/CLAUDE.md template

Create .claude/CLAUDE.md with the following content exactly:

```markdown
# Claude Code Context

@../CLAUDE.md

@~/.claude/plugins/cache/claude-project-init/CLAUDE.md
```

The first import pulls in the root CLAUDE.md which is the source of
truth for project plan and architecture. The second import pulls in
the global plugin rules. Do not duplicate any content from either file.

If there is anything project-specific that is not covered by either
import — such as local paths, personal overrides, or toolchain notes —
add it below the imports. Otherwise leave the file as the two imports only.

## Step 4 — Create Makefile with stub targets

Create a Makefile with standard stub targets. The project-type skill
will replace these stubs with real implementations.

```makefile
# Makefile — targets implemented by project type initialisation
# Do not edit targets directly — run /init-<type> to implement them

.PHONY: build lint test clean release package docs

build:
	@echo "build: not implemented — run /init-<type>"
	@exit 1

lint:
	@echo "lint: not implemented — run /init-<type>"
	@exit 1

test:
	@echo "test: not implemented — run /init-<type>"
	@exit 1

clean:
	@echo "clean: not implemented — run /init-<type>"
	@exit 1

release:
	@echo "release: not implemented — run /init-<type>"
	@exit 1

package:
	@echo "package: not implemented — run /init-<type>"
	@exit 1

docs:
	@echo "docs: not implemented — run /init-<type>"
	@exit 1
```

## Step 5 — Hand off to project-type skill

Based on the user's answer in Step 2, immediately invoke the
appropriate skill:
- rust-cli → invoke /init-rust-cli
- web → invoke /init-web (if not installed, tell the user and stop)
- other → tell the user no type-specific skill exists yet; they should
  implement the Makefile targets manually and run /tasks when ready

If the requested type skill does not exist, list the currently available
type skills and suggest the user check the plugin repository for new ones
or implement their own `skills/init-<type>/SKILL.md`.

## Step 6 — Report

When the project-type skill completes, summarise:
- What was created
- What the next step is (e.g. "run /tasks to plan implementation")
