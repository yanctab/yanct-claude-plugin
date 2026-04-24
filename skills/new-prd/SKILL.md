---
name: new-prd
description: Capture a feature as a PRD and file it as a GitHub issue. Synthesises from the current conversation and the codebase — does not interview.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Agent, Bash
---

# New PRD

Capture a feature idea as a PRD and file it as a GitHub issue.
Synthesise from the current conversation and the codebase — do NOT
interview the developer. No code changes.

## Process

1. Invoke the `prd-researcher` agent with the feature title. If no
   title was supplied as an argument, pass the current conversation
   context and let the agent infer one. The agent returns a module
   sketch.

2. Relay the sketch to the developer and ask, in one turn:
   - Do these modules match your expectations?
   - Which modules do you want tests written for?

3. Invoke `prd-researcher` again with the title, the sketch, and the
   developer's answers. It writes the PRD and files the GitHub issue.

4. Print the returned issue URL.
