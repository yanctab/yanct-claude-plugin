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
	@test -f .claude-plugin/plugin.json      || (echo "ERROR: missing .claude-plugin/plugin.json"      && exit 1)
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
