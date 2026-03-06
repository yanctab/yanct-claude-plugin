# Claude Code Context

@../CLAUDE.md

@~/.claude/plugins/cache/yanct-claude-plugin/yanct-claude-plugin/0.1.0/CLAUDE.md

## Version Control Rules

- Never push directly to main or master — always use a feature branch and PR
- All PRs must be merged with a squash commit — never merge commit or rebase merge

## Dev Dependencies

The skill-creator plugin from Anthropic is required to create and iterate on
skills in this project. Install it once in Claude Code:

```
/plugin marketplace add claude-plugins-official/skill-creator
/plugin install skill-creator@skill-creator
```

Use `/skill-creator` to create new skills, improve existing ones, or run evals.
