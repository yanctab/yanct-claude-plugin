---
name: plan-task
description: Research and plan a single task from TASKS.md without implementing it. Produces a plan file at .claude/plans/<task-slug>.md and stops.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Agent
---

# Task Planning

You are researching the codebase and producing a written plan for one task
from TASKS.md. You will **not** write any implementation code. You stop
after presenting the plan.

---

## Step 1 — Load project context

Read `.claude/CLAUDE.md`. This file imports the root `CLAUDE.md` via
`@../CLAUDE.md` so you get the full project description, architecture,
and rules in one read.

If `.claude/CLAUDE.md` does not exist, tell the user to run
`/init-project` first and stop.

---

## Step 2 — Read TASKS.md

Read `TASKS.md` from the project root.

If `TASKS.md` does not exist, tell the user to run `/tasks` first
to generate the task list, and stop.

Identify:
- **Pending tasks** — lines matching `- [ ] **…**`
- **Completed tasks** — lines matching `- [x] **…**`

---

## Step 3 — Select the target task

**If the user provided a task name as an argument** (e.g.
`/plan-task "Implement auth module"`), match it against pending task
titles (case-insensitive, partial match is fine). Use the first match.
If no match is found, show the pending task list and ask the user to
pick one.

**If no argument was provided**, display the pending task list in this
format and ask the user which task to plan:

```
Pending tasks:
  1. <title> [<tag>] <complexity>
  2. <title> [<tag>] <complexity>
  ...

Which task would you like to plan? (enter number or title)
```

Wait for the user's answer before continuing.

---

## Step 4 — Research the codebase

Using the selected task title, acceptance criteria, and tags as a guide,
launch **up to 2 Explore agents in parallel** to research the codebase:

**Agent A — affected files**
> Search the codebase for files most likely touched by: "<task title>".
> Look for existing modules, source files, and tests related to the
> task's scope. Report file paths and a one-line description of each.
> Do not suggest changes — only report what exists.

**Agent B — reusable utilities and patterns**
> Search the codebase for existing utilities, helpers, types, and
> patterns that could be reused when implementing: "<task title>".
> Report concrete file paths and function/type names.
> Do not suggest changes — only report what exists.

Collect both agents' results before proceeding.

---

## Step 5 — Write the plan file

Derive the task slug:
- Take the task title
- Lowercase it
- Replace spaces with hyphens
- Remove all characters that are not alphanumeric or hyphens

Ensure `.claude/plans/` exists (create it if needed).

Write the plan to `.claude/plans/<task-slug>.md`:

```markdown
# Plan: <task title>

## Task

> Copied verbatim from TASKS.md (title, tag, complexity, acceptance
> criteria, dependencies)

## Approach

### Files to modify
- `<path>` — <what changes and why>

### Files to create
- `<path>` — <purpose>

### Existing code to reuse
- `<path>:<symbol>` — <how it will be used>

## Test plan

- [ ] <test case that satisfies acceptance criterion 1>
- [ ] <test case that satisfies acceptance criterion 2>
- …

## Known unknowns / risks

- <anything unclear from the codebase research>
- <edge cases that need clarification>
- (write "None" if there are none)
```

Fill every section from the codebase research. Do not leave placeholders.

---

## Step 6 — Present and stop

Display the full contents of the plan file inline.

Then output exactly:

```
Plan written to .claude/plans/<task-slug>.md

No code has been written. Run /execute or confirm to start implementation.
```

Stop here. Do not proceed to implementation.
