---
name: rust-cli-finalize
description: Creates docs, README, .claude/settings.json, and .gitignore for a Rust CLI project. Final step of rust-cli scaffolding.
tools: Read, Write, Bash(mkdir *), Bash(rustup *), Bash(sudo apt-get *), Bash(git *)
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

Replace the settings.json created by init-project with the full version
that adds rust-specific permissions and the post-edit lint hook:

```json
{
  "permissions": {
    "allow": [
      "Write",
      "Bash(make *)",
      "Bash(git *)",
      "Bash(mkdir *)",
      "Bash(touch *)",
      "Bash(cp *)",
      "Bash(chmod *)",
      "Bash(cargo init *)",
      "Bash(cargo add *)",
      "Bash(rustup *)",
      "Bash(sudo apt-get *)"
    ]
  },
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
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/plugins/cache/yanct-claude-plugin/yanct-claude-plugin/0.1.0/hooks/post-commit-task-done.sh"
          }
        ]
      }
    ]
  }
}
```

Substitute the actual value of `$CLAUDE_PLUGIN_ROOT` in both hook command paths
before writing — the literal `$CLAUDE_PLUGIN_ROOT` must not appear in the output file.

## Step 5 — Install local toolchain

Install everything needed so that `make build`, `make lint`, and `make package`
all work locally before `/execute` is run.

If rustup is not available, note it and skip each rustup step — CI will handle it.

```
rustup component add rustfmt clippy
rustup target add x86_64-unknown-linux-musl
```

Install the musl linker if not already present:
```
sudo apt-get install -y musl-tools
```

If `apt-get` is not available (non-Debian system), note that `musl-tools` must
be installed manually before `make build` will succeed.

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
