---
name: rust-cli-makefile
description: Implements Makefile rust-cli targets. Use as the first step of rust-cli scaffolding.
tools: Read, Write, Bash(git *)
---

You are implementing the Makefile targets for a Rust CLI project.

## Step 1 — Read project context

Read `.claude/CLAUDE.md` to get the project name and any constraints.
Extract the binary name (use the project name in kebab-case if not explicit).

## Step 2 — Replace Makefile stub targets

Overwrite the existing Makefile with the Rust implementation:

```makefile
# Makefile

.PHONY: build fmt fmt-check lint test clean install setup release package publish docs help

BINARY  := $(shell grep '^name'    Cargo.toml | head -1 | sed 's/.*= "//' | sed 's/"//')
VERSION := $(shell grep '^version' Cargo.toml | head -1 | sed 's/.*= "//' | sed 's/"//')
TARGET  := x86_64-unknown-linux-musl
PREFIX  ?= /usr/local

## help - show available targets
help:
	@grep -E '^## [a-zA-Z_-]+ - ' Makefile | awk 'BEGIN {FS=" - "} {printf "  %-15s %s\n", substr($$1, 4), $$2}'

## build - compile a static musl release binary
build:
	cargo build --release --target $(TARGET)

## fmt - auto-format code with cargo fmt
fmt:
	cargo fmt

## fmt-check - check code formatting without modifying files
fmt-check:
	cargo fmt --check

## lint - check formatting and run clippy
lint:
	$(MAKE) fmt-check
	cargo clippy -- -D warnings

## test - run the test suite
test:
	cargo test

## clean - remove build artifacts
clean:
	cargo clean

## install - install the binary to $(PREFIX)/bin (default: /usr/local/bin)
install: build
	install -Dm755 target/$(TARGET)/release/$(BINARY) $(PREFIX)/bin/$(BINARY)

## setup - install all tools and dependencies required to work on this project
setup:
	rustup target add $(TARGET)
	sudo apt-get install -y musl-tools pandoc

## release - tag the current version and push to trigger the release pipeline
release:
	git tag v$(VERSION)
	git push origin v$(VERSION)

## package - build .deb and AUR packages from the release binary
package:
	$(MAKE) build
	$(MAKE) build-deb
	$(MAKE) build-aur

## publish - publish the crate to crates.io
publish:
	cargo publish

## docs - generate man page from markdown source
docs:
	pandoc docs/man/$(BINARY).1.md -s -t man -o docs/man/$(BINARY).1

build-deb:
	@scripts/build-deb.sh $(BINARY) $(VERSION)

build-aur:
	@scripts/build-aur.sh $(BINARY) $(VERSION)

# ── Project-specific targets ──────────────────────────────────────────────────
# Add targets below that are unique to this project. They will appear in
# `make help` automatically if you use the `## target - description` convention.
# Examples: database migrations, code generation, deployment steps, dev server.
```

## Step 3 — Commit

```
git add Makefile
git commit -m "chore(scaffold): implement Makefile rust-cli targets"
```

## Step 4 — Report

Confirm the Makefile was written and committed. List the targets implemented.
