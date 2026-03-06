---
name: claude-plugin-finalize
description: Creates README, .gitignore, and .claude/settings.json for a Claude Code plugin project. Final step of claude-plugin scaffolding.
tools: Read, Write, Bash(git *)
---

You are finalising the claude-plugin scaffold with README, .gitignore, and settings.

## Step 1 — Read project context

Read `.claude/CLAUDE.md` and `.claude-plugin/plugin.json` to get:
- Plugin name
- Description
- Author
- Commands and skills defined (if any listed in CLAUDE.md)

## Step 2 — Create README.md

```markdown
# <plugin-name>

<one-line description from CLAUDE.md>

## Installation

In any Claude Code session, run these two commands:

```
/plugin marketplace add <owner>/<plugin-name>
/plugin install <plugin-name>@<plugin-name>
```

## Commands

| Command | Description |
|---|---|
| (list commands here once implemented) | |

## Development

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- `jq` — for JSON validation (`make lint`)
- skill-creator plugin:
  ```
  /plugin marketplace add claude-plugins-official/skill-creator
  /plugin install skill-creator@skill-creator
  ```

### Workflow

```
make setup    # install jq and print skill-creator install instructions
make lint     # validate JSON manifests
make test     # check plugin structure
make install  # copy working directory into local Claude plugin cache for immediate testing
make release  # tag and push to trigger the release pipeline
```

### Adding a new command

1. Create `commands/<name>.md` with YAML front matter and the command instructions
2. If the command delegates to a skill, create `skills/<name>/SKILL.md`
3. Use the skill-creator plugin to iterate on skill quality:
   ```
   /skill-creator
   ```
```

Fill in plugin name, owner, and description from the project context.
Populate the Commands table if any commands are already defined in CLAUDE.md.

## Step 3 — Create .claude/settings.json

Replace the settings.json created by init-project with the full version that
adds the post-edit lint hook:

```json
{
  "permissions": {
    "allow": [
      "Write",
      "Bash(make *)",
      "Bash(git *)",
      "Bash(mkdir *)",
      "Bash(touch *)",
      "Bash(jq *)"
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

## Step 4 — Update .claude/CLAUDE.md to declare skill-creator dependency

Append the following block to `.claude/CLAUDE.md` after the existing imports:

```markdown
## Dev Dependencies

The skill-creator plugin from Anthropic is required to create and iterate on
skills in this project. Install it once in Claude Code:

```
/plugin marketplace add claude-plugins-official/skill-creator
/plugin install skill-creator@skill-creator
```

Use `/skill-creator` to create new skills, improve existing ones, or run evals.
```

## Step 5 — Create .gitignore

```
.DS_Store
*.swp
```

## Step 6 — Commit

```
git add README.md .claude/settings.json .claude/CLAUDE.md .gitignore
git commit -m "chore(scaffold): add README, settings, and gitignore"
```

## Step 7 — Report

Summarise all files created. Tell the user the scaffold is complete and:
- The next step is `/tasks` to generate the implementation task list
- The skill-creator plugin should be installed in Claude Code before
  working on skills (print the install commands)
