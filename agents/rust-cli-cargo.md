---
name: rust-cli-cargo
description: Initialises Cargo project and scaffolds src/ module structure. Use as the second step of rust-cli scaffolding.
tools: Read, Write, Bash(cargo init *), Bash(cargo add *), Bash(mkdir *), Bash(git *)
---

You are initialising the Cargo project and src/ structure for a Rust CLI.

## Step 1 — Read project context

Read `.claude/CLAUDE.md` to extract:
- Project name (binary name in kebab-case)
- Module structure (if defined)
- Subcommands (if defined)

## Step 2 — Initialise Cargo

Run `cargo init --name <project-name>` if `Cargo.toml` does not already exist.

Add standard dependencies:
```
cargo add clap --features derive
cargo add serde --features derive
cargo add serde_yaml
cargo add anyhow
cargo add thiserror
```

Add release profile to Cargo.toml:
```toml
[profile.release]
strip = true
```

## Step 3 — Scaffold src/

If modules are defined in `.claude/CLAUDE.md`, create a stub file for each:

```rust
// src/<module>/mod.rs
// <Module responsibility from CLAUDE.md>

use anyhow::Result;

pub fn run() -> Result<()> {
    todo!()
}
```

If subcommands are defined, create:
- A variant in the clap `Commands` enum for each subcommand
- A stub `src/commands/<name>.rs` for each with `pub fn run() -> Result<()> { todo!() }`

`main.rs` should wire up clap and delegate to modules. Do not implement any
business logic — structure only.

If no modules are defined, create a minimal structure:
```
src/
├── main.rs
└── cli/
    └── mod.rs
```

## Step 4 — Commit

```
git add Cargo.toml Cargo.lock src/
git commit -m "chore(scaffold): initialise Cargo project and module stubs"
```

## Step 5 — Report

List the modules and subcommands scaffolded. Note any dependencies added.
