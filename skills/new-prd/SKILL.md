---
name: new-prd
description: Capture a feature as a PRD and file it as a GitHub issue. Synthesises from the current conversation and the codebase — does not interview.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Agent, Bash
---

# New PRD

Capture a feature idea as a PRD and file it as a GitHub issue. Do not
interview the developer — synthesise from what's already in the
conversation and what the codebase tells you. No code changes.

## Process

1. If no feature title was supplied as an argument, ask for a one-line
   description. Echo your interpretation and confirm.

2. Invoke the `prd-researcher` agent in `research` mode with the
   confirmed title. It returns a module sketch.

3. Show the sketch and ask the developer two questions:
   - Do these modules match your expectations?
   - Which modules do you want tests written for?

4. Invoke the `prd-researcher` agent in `draft` mode with the title,
   the sketch, and the developer's answers. It writes the PRD and
   files the GitHub issue.

5. Print the returned issue URL.
