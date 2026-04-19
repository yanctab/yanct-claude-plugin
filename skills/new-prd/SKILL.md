---
name: new-prd
description: Synthesise a PRD from the current conversation and codebase context, confirm the module sketch with the developer, then file the PRD as a GitHub issue. Does not touch TASKS.md.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Agent, Bash
---

# New PRD

You are capturing a feature idea as a Product Requirements Document
(PRD) and filing it as a GitHub issue. You will delegate codebase
research and PRD drafting to the `prd-researcher` subagent. You will
not write any implementation code and you will not touch `TASKS.md`.

Follow the `to-prd` philosophy: **do not interview the developer**.
Synthesise from what's already in the conversation and what the
codebase tells you. The only direct question you ask the developer
(besides the opening title clarification) is a module-sketch check —
mirroring the single confirmation step in `to-prd`.

---

## Step 1 — Clarify the feature title

**Always confirm the title before proceeding**, regardless of whether
a description was supplied as an argument.

If an argument was provided, treat it as a hint — not a complete
specification. Echo your interpretation and ask them to confirm or
correct it:

```
Feature: "<your interpretation of the feature title>"

Is this what you had in mind, or would you like to adjust the title or
scope?
```

If no argument was provided, ask:

```
What feature would you like a PRD for?
Describe it in one line (e.g. "Add rate limiting to the API"):
```

Wait for the developer's answer. Use their response as the confirmed
feature title going into Step 2.

---

## Step 2 — Research the codebase (delegate)

> Use the prd-researcher agent in `research` mode for the following
> feature: "<confirmed feature title>"

The agent will explore the repo via parallel Explore subagents and
return a compact synthesis: candidate modules (flagged `[deep]` where
the agent identified a deep-module opportunity), reusable prior art,
and risks worth calling out. Keep the synthesis visible — the
developer needs to see it for Step 3.

---

## Step 3 — Confirm the module sketch

Present the module sketch from Step 2 to the developer and ask the two
`to-prd` confirmation questions, one message, both questions:

```
Do these modules match your expectations?
Which modules do you want tests written for?
```

Wait for the developer's answer. Capture:
- Any module corrections, additions, or removals
- The explicit list of modules the developer wants tests for

This is the only freeform question in the research-to-draft path. Do
not grill — resolve obvious ambiguities from the conversation context
and the research synthesis, not from the developer.

---

## Step 4 — Draft the PRD and file the issue (delegate)

> Use the prd-researcher agent in `draft` mode with:
> - Feature title: "<confirmed feature title>"
> - Research synthesis: <Step 2 output>
> - Module confirmation: <Step 3 developer response>
> - Tested modules: <explicit list from Step 3>

The agent will write the PRD using the `to-prd` template, stage it as
a tempfile, run `gh issue create --title "PRD: <feature title>"
--body-file <tempfile> --assignee @me`, and return the issue URL.

---

## Step 5 — Present and stop

Show the returned issue URL to the developer and output:

```
PRD filed as GitHub issue: <url>

No code has been written.
```

Stop here. Do not proceed to implementation.
