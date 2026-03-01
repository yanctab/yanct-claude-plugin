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

.PHONY: build lint test clean release package docs

BINARY := $(shell grep '^name' Cargo.toml | head -1 | sed 's/.*= "//' | sed 's/"//')
VERSION := $(shell grep '^version' Cargo.toml | head -1 | sed 's/.*= "//' | sed 's/"//')
TARGET := x86_64-unknown-linux-musl

build:
	cargo build --release --target $(TARGET)

lint:
	cargo fmt --check
	cargo clippy -- -D warnings

test:
	cargo test

clean:
	cargo clean

release:
	git tag v$(VERSION)
	git push origin v$(VERSION)

package:
	$(MAKE) build
	$(MAKE) build-deb
	$(MAKE) build-aur

docs:
	pandoc docs/man/$(BINARY).1.md -s -t man -o docs/man/$(BINARY).1

build-deb:
	@scripts/build-deb.sh $(BINARY) $(VERSION)

build-aur:
	@scripts/build-aur.sh $(BINARY) $(VERSION)
```

## Step 3 — Commit

```
git add Makefile
git commit -m "chore(scaffold): implement Makefile rust-cli targets"
```

## Step 4 — Report

Confirm the Makefile was written and committed. List the targets implemented.
