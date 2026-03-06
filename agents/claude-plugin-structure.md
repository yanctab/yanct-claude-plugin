---
name: claude-plugin-structure
description: Creates plugin manifests (.claude-plugin/plugin.json and marketplace.json), directory skeleton (commands/ skills/ agents/ hooks/), and Makefile with JSON-validation targets. Use as the first step of claude-plugin scaffolding.
tools: Read, Write, Bash(mkdir *), Bash(touch *), Bash(git *)
---

You are creating the plugin manifest files, directory structure, and Makefile
for a new Claude Code plugin project.

## Step 1 — Read project context

Read `.claude/CLAUDE.md` to extract:
- Plugin name (must be kebab-case)
- Description
- Author / organisation name

## Step 2 — Create .claude-plugin/plugin.json

```json
{
  "name": "<plugin-name>",
  "version": "0.1.0",
  "description": "<one-line description from CLAUDE.md>",
  "author": {
    "name": "<author>"
  },
  "repository": "https://github.com/<owner>/<repo>",
  "license": "MIT",
  "keywords": []
}
```

Use the actual plugin name, description, and author from CLAUDE.md.
Leave `repository` with a placeholder if the GitHub URL is not yet known —
it will be updated once the repo is created.

## Step 3 — Create .claude-plugin/marketplace.json

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "<plugin-name>",
  "description": "<one-line description>",
  "owner": {
    "name": "<author>"
  },
  "plugins": [
    {
      "name": "<plugin-name>",
      "description": "<one-line description>",
      "source": {
        "source": "url",
        "url": "https://github.com/<owner>/<repo>.git"
      },
      "category": "development",
      "homepage": "https://github.com/<owner>/<repo>"
    }
  ]
}
```

## Step 4 — Create directory skeleton

```
mkdir -p commands skills agents hooks
touch commands/.gitkeep skills/.gitkeep agents/.gitkeep hooks/.gitkeep
```

## Step 5 — Replace Makefile stub targets

Overwrite the existing Makefile with the Claude plugin implementation.
Read plugin name and version from `.claude-plugin/plugin.json` at runtime via jq:

```makefile
# Makefile

.PHONY: build lint test clean install setup release package docs help

PLUGIN_NAME := $(shell jq -r '.name'    .claude-plugin/plugin.json)
VERSION     := $(shell jq -r '.version' .claude-plugin/plugin.json)
CACHE_DIR   := $(HOME)/.claude/plugins/cache/$(PLUGIN_NAME)/$(PLUGIN_NAME)/$(VERSION)

## help - show available targets
help:
	@grep -E '^## [a-zA-Z_-]+ - ' Makefile | awk 'BEGIN {FS=" - "} {printf "  %-15s %s\n", substr($$1, 4), $$2}'

## build - validate plugin structure (no compile step for plugins)
build:
	@$(MAKE) lint
	@$(MAKE) test

## lint - validate JSON manifests with jq
lint:
	@echo "Validating .claude-plugin/plugin.json..."
	@jq . .claude-plugin/plugin.json > /dev/null
	@echo "Validating .claude-plugin/marketplace.json..."
	@jq . .claude-plugin/marketplace.json > /dev/null
	@echo "JSON validation passed."

## test - check required plugin files exist
test:
	@echo "Checking plugin structure..."
	@test -f .claude-plugin/plugin.json     || (echo "ERROR: missing .claude-plugin/plugin.json"     && exit 1)
	@test -f .claude-plugin/marketplace.json || (echo "ERROR: missing .claude-plugin/marketplace.json" && exit 1)
	@test -d commands || (echo "ERROR: missing commands/ directory" && exit 1)
	@test -d skills   || (echo "ERROR: missing skills/ directory"   && exit 1)
	@test -d agents   || (echo "ERROR: missing agents/ directory"   && exit 1)
	@echo "Structure check passed."

## clean - nothing to clean for a plugin
clean:
	@echo "Nothing to clean for a Claude plugin."

## install - copy working directory into the local Claude plugin cache
install:
	@echo "Installing $(PLUGIN_NAME)@$(VERSION) to local Claude plugin cache..."
	@mkdir -p "$(CACHE_DIR)"
	@rsync -a --delete --exclude='.git/' --exclude='.claude/' . "$(CACHE_DIR)/"
	@echo "Installed to: $(CACHE_DIR)"
	@echo "Reload Claude Code to pick up changes."

## setup - install tools required to work on this plugin
setup:
	@command -v jq    >/dev/null 2>&1 || sudo apt-get install -y jq
	@command -v rsync >/dev/null 2>&1 || sudo apt-get install -y rsync
	@echo ""
	@echo "Install the skill-creator plugin in Claude Code (required for development):"
	@echo "  /plugin marketplace add claude-plugins-official/skill-creator"
	@echo "  /plugin install skill-creator@skill-creator"

## release - tag the current version and push to trigger the release pipeline
release:
	git tag v$(VERSION)
	git push origin v$(VERSION)

## package - no packaging step for Claude plugins
package:
	@echo "Claude plugins are distributed via GitHub — no packaging step needed."

## docs - no doc generation step for Claude plugins
docs:
	@echo "Document your plugin in README.md and the individual command/skill files."

# ── Project-specific targets ──────────────────────────────────────────────────
# Add targets below that are unique to this project. They will appear in
# `make help` automatically if you use the `## target - description` convention.
```

## Step 6 — Commit

```
git add .claude-plugin/ commands/ skills/ agents/ hooks/ Makefile
git commit -m "chore(scaffold): add plugin manifests, directory structure, and Makefile"
```

## Step 7 — Report

Confirm the files created. List the Makefile targets. Note that `repository`
and `homepage` fields in the manifests may need to be updated once the
GitHub repository URL is known.
