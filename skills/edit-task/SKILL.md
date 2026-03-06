---
name: edit-task
description: Edit an existing task in TASKS.md. Use when the user wants to change a task's scope, acceptance criteria, dependencies, or any other attribute. Can be invoked with a task number or will ask the user to pick one.
disable-model-invocation: true
allowed-tools: Read, Write, Agent
---

# Edit Task

You are editing an existing task in `TASKS.md`. You will clarify which
task and what to change, then delegate research and rewriting to a
subagent. You will not write any implementation code.

---

## Step 1 — Read TASKS.md

Read `TASKS.md` from the project root. If it does not exist, tell the
user to run `/tasks` first.

---

## Step 2 — Select the task

Number every task in TASKS.md sequentially (both checked and unchecked),
starting from 1.

If a task number was provided as an argument, locate that task directly.

If no argument was provided, present the numbered list and ask:

```
Which task would you like to edit? (enter a number)
```

Wait for the user's answer before continuing.

---

## Step 3 — Enter planning mode and present the current task

Enter planning mode now.

Show the full current task entry exactly as it appears in TASKS.md:

```
Current task #<N>:

<full task block>
```

Then ask:

```
What would you like to change?
```

Wait for the user's answer before continuing.

---

## Step 4 — Confirm the change

Summarise what you understood:

```
Task: "<task title>"
Changes: <one-line summary of what will change>

Is that right?
```

Wait for confirmation. If the user corrects anything, update your
understanding and confirm again before proceeding.

---

## Step 5 — Delegate research and rewriting

> Use the task-editor agent to edit task: "<task title>" with the
> following changes: "<confirmed change description>"

The task-editor will research the codebase, apply the changes to the
task entry in TASKS.md, and return the updated block.

---

## Step 6 — Present and stop

Show the returned updated task entry and output:

```
Task updated in TASKS.md.

No code has been written. Run /execute to continue implementation.
```

Stop here. Do not proceed to implementation.
