---
name: new-task
description: Research a task idea, derive acceptance criteria and implementation approach, then append it as a detailed task entry to TASKS.md so /execute can pick it up.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Agent
---

# New Task

You are researching a task idea and producing a well-specified task entry
that gets appended to `TASKS.md`. You will **not** write any implementation
code. The task entry is the output — `/execute` will implement it later.

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

Note which tasks are already present so the new task can declare the
right `Depends on:` value.

---

## Step 3 — Read existing plans

Check whether `.claude/plans/` exists and list its contents. Read any
plan files present — they may describe intended work that the new task
should align with, extend, or avoid duplicating.

---

## Step 4 — Clarify intent with the developer

**Always ask for clarification before proceeding**, regardless of
whether a description was supplied as an argument.

If an argument was provided, treat it as a hint — not a complete
specification. You may have misunderstood the developer's intent.
Present your interpretation and ask them to confirm or correct it.

Format the question as:

```
Task: "<your interpretation of the task title>"

Is this what you had in mind, or would you like to adjust the scope,
title, or focus before I research the codebase?
```

If no argument was provided, ask:

```
What task would you like to add?
Describe it in one line (e.g. "Add rate limiting to the API"):
```

In both cases, wait for the developer's answer before continuing.
Use their response as the confirmed task title going into Step 5.

---

## Step 5 — Research the codebase

Using the confirmed task title as a guide, launch **up to 2 Explore
agents in parallel**:

**Agent A — affected files**
> Search the codebase for files most likely touched when implementing:
> "<task title>".
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

## Step 6 — Derive task attributes

From the confirmed task title, project context, plan files, and
research results, determine:

- **Tag** — pick the most appropriate: `[core]`, `[cli]`, `[config]`,
  `[test]`, `[docs]`, `[packaging]`
- **Complexity** — `S` (< 1 day), `M` (1–3 days), `L` (> 3 days)
- **Acceptance criteria** — one or two specific, verifiable statements
  describing the done state, including tests
- **Depends on** — the last completed or last pending task in TASKS.md
  that this task logically follows; use the exact title from TASKS.md
- **Files to modify** — list from Agent A's results
- **Files to create** — list from Agent A's results
- **Reuse** — list from Agent B's results (`path:symbol`)
- **Risks** — anything unclear or edge cases to watch

---

## Step 7 — Append to TASKS.md

Append the following block to the end of the `## Implementation`
section in TASKS.md (before any trailing newline or section):

```markdown
- [ ] **<task title>** [<tag>] <complexity>
  - Acceptance: <acceptance criteria including tests>
  - Depends on: <dependency>
  - Modify: <file1>, <file2>
  - Create: <file3> (or "none")
  - Reuse: <path:symbol> (or "none")
  - Risks: <risks> (or "none")
```

Rules:
- Do not alter any existing lines in TASKS.md
- Append only — never rewrite the file
- Keep each sub-bullet on one line; do not wrap

---

## Step 8 — Present and stop

Show the appended task entry to the user and output:

```
Task appended to TASKS.md.

No code has been written. Run /execute to start implementation.
```

Stop here. Do not proceed to implementation.
