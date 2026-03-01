---
name: rust-cli-finalize
description: Creates docs, README, .claude/settings.json, and .gitignore for a Rust CLI project. Final step of rust-cli scaffolding.
tools: Read, Write, Bash(mkdir *), Bash(rustup *), Bash(git *)
---

You are finalising the rust-cli scaffold with docs, settings, and project housekeeping files.

## Step 1 — Read project context

Read `.claude/CLAUDE.md` and `Cargo.toml` to get:
- Binary name
- Project description
- Subcommands

## Step 2 — Create docs/man/<binary>.1.md

```markdown
% BINARY(1) Version VERSION | User Commands

# NAME

binary - one-line description

# SYNOPSIS

**binary** [*OPTIONS*] *COMMAND*

# DESCRIPTION

Project description here.

# COMMANDS

List subcommands here.

# OPTIONS

**--verbose**
: Enable verbose output

**--no-color**
: Disable colored output

**--help**
: Print help

**--version**
: Print version

# EXAMPLES

Usage examples here.

# AUTHOR

Author here.

# SEE ALSO

**ssh**(1)
```

Fill in BINARY, VERSION, description, and subcommands from the project context.

## Step 3 — Create README.md

```markdown
# <binary-name>

One-line description from CLAUDE.md.

## Installation

### Arch Linux (AUR)
\`\`\`
yay -S <binary-name>
\`\`\`

### Debian / Ubuntu
Download the latest `.deb` from the [releases page](https://github.com/OWNER/REPO/releases) and install:
\`\`\`
sudo dpkg -i <binary-name>_<version>_amd64.deb
\`\`\`

### From source
\`\`\`
cargo build --release --target x86_64-unknown-linux-musl
\`\`\`

## Usage

\`\`\`
<binary-name> [OPTIONS] COMMAND
\`\`\`

See `man <binary-name>` for full documentation.

## Development

\`\`\`
make build    # compile
make test     # run tests
make lint     # format + clippy
make release  # tag and trigger release pipeline
\`\`\`
```

Replace OWNER/REPO and description with actual values.

## Step 4 — Create .claude/settings.json

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/plugins/cache/yanct-claude-plugin/yanct-claude-plugin/0.1.0/hooks/post-edit-lint.sh"
          }
        ]
      }
    ]
  }
}
```

## Step 5 — Install musl target

Run: `rustup target add x86_64-unknown-linux-musl`
If rustup is not available, note it and skip — CI will handle it.

## Step 6 — Create .gitignore

```
/target
dist/
*.deb
docs/man/*.1
```

## Step 7 — Commit

```
git add docs/ README.md .claude/settings.json .gitignore
git commit -m "chore(scaffold): add docs, settings, and gitignore"
```

## Step 8 — Report

Summarise all files created. List the stub files that need implementation.
Tell the user the scaffold is complete and the next step is `/tasks`.
