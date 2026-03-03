---
name: new-task
description: Research a task idea, derive acceptance criteria and implementation approach, then append it as a detailed task entry to TASKS.md so /execute can pick it up.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Agent
---

# New Task

You are adding a task to `TASKS.md`. You will clarify intent with the
developer, then delegate all research and writing to a subagent. You will
not write any implementation code.

---

## Step 1 — Clarify intent with the developer

**Always ask for clarification before proceeding**, regardless of whether
a description was supplied as an argument.

If an argument was provided, treat it as a hint — not a complete
specification. Present your interpretation and ask them to confirm or
correct it:

```
Task: "<your interpretation of the task title>"

Is this what you had in mind, or would you like to adjust the scope,
title, or focus?
```

If no argument was provided, ask:

```
What task would you like to add?
Describe it in one line (e.g. "Add rate limiting to the API"):
```

In both cases, wait for the developer's answer before continuing.
Use their response as the confirmed task title going into Step 2.

---

## Step 2 — Delegate research and writing

> Use the task-researcher agent to research and append the following task: "<confirmed task title>"

The task-researcher will read project context, research the codebase, and
append the task entry to TASKS.md. It will return the appended block.

---

## Step 3 — Present and stop

Show the returned task entry to the user and output:

```
Task appended to TASKS.md.

No code has been written. Run /execute to start implementation.
```

Stop here. Do not proceed to implementation.
