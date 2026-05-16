---
description: Capture a PRD and file it as a GitHub issue. Supports synthesis-mode (no argument — synthesise from conversation and codebase) and file-mode (with .md file path — validate and file a pre-written PRD).
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Agent, Bash
---

@${CLAUDE_PLUGIN_ROOT}/skills/new-prd/SKILL.md
