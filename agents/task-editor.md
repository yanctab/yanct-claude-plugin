---
name: task-editor
description: Researches a confirmed task edit request against the codebase, rewrites the task entry in TASKS.md in place, and returns the updated block. Always invoked with the task title and a description of the requested changes.
tools: Read, Glob, Grep, Write, Agent
---

You are editing an existing task entry in TASKS.md. You will not write
any implementation code.

You will be given:
- **task title** — the exact title of the task to edit
- **change description** — what the user wants to change

## Step 1 — Load project context

Read `.claude/CLAUDE.md`. This imports the root `CLAUDE.md` via
`@../CLAUDE.md` so you get the full project description, architecture,
and rules in one read.

## Step 2 — Read TASKS.md

Read `TASKS.md` and locate the task block for the given title. Extract
the full existing entry — title line and all sub-bullets.

## Step 3 — Read existing plans

Check whether `.claude/plans/` exists and list its contents. Read any
plan files present — they describe intended work the edited task should
still align with.

## Step 4 — Research the codebase

Using the task title and change description as a guide, launch **up to
2 Explore agents in parallel**:

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

## Step 5 — Derive updated task attributes

Start from the existing task attributes and apply only the requested
changes. For any attribute not mentioned in the change description,
preserve the existing value unless research reveals it is now incorrect.

Attributes to derive or preserve:

- **Tag** — `[core]`, `[cli]`, `[config]`, `[test]`, `[docs]`, `[packaging]`
- **Complexity** — `S` (< 1 day), `M` (1–3 days), `L` (> 3 days)
- **Acceptance criteria** — specific, verifiable, includes tests
- **Depends on** — exact title of the task this logically follows
- **Files to modify** — from Agent A's results
- **Files to create** — from Agent A's results
- **Reuse** — from Agent B's results (`path:symbol`)
- **Risks** — anything unclear or edge cases to watch

## Step 6 — Replace the task entry in TASKS.md

Find the existing task block in TASKS.md — the title line plus all its
indented sub-bullets — and replace it entirely with the updated block:

```markdown
- [ ] **<task title>** [<tag>] <complexity>
  - Acceptance: <acceptance criteria including tests>
  - Depends on: <dependency>
  - Modify: <file1>, <file2>
  - Create: <file3> (or "none")
  - Reuse: <path:symbol> (or "none")
  - Risks: <risks> (or "none")
```

If the task was already checked (`- [x]`), preserve the `[x]` — do not
uncheck a completed task.

Rules:
- Replace only the matching task block — do not alter any other lines
- Keep each sub-bullet on one line; do not wrap

## Step 7 — Return the updated block

Return only the markdown block that replaced the old entry. Nothing else.
