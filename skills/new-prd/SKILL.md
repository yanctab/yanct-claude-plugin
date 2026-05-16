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

## Step 1 — Detect mode

Check if the user provided an argument when invoking `/new-prd`:

- If **no argument** was provided: proceed to **synthesis-mode** (Step 3.1)
- If an argument **ends with `.md`**: attempt **file-mode** (Step 2.1)
- If an argument was provided **but does not end with `.md`**: treat it as a feature title and proceed to **synthesis-mode** (Step 3.1)

## File-mode (when argument is a `.md` file path)

**Important:** File-mode reads and validates the PRD directly from the file.
Do NOT invoke the `prd-researcher` agent in file-mode — only validate,
extract, and file.

### Step 2.1 — Read the file

Use the Read tool to load the entire file content from the provided path.

### Step 2.2 — Validate required sections

Check that the file contains all seven required section headings (case-sensitive, must be exact):
- `## Problem Statement`
- `## Solution`
- `## User Stories`
- `## Implementation Decisions`
- `## Testing Decisions`
- `## Out of Scope`
- `## Further Notes`

If any section is missing:
- List the missing sections to the user
- Halt without filing the issue

If all sections are present, proceed to Step 2.3.

### Step 2.3 — Extract the H1 title

Search the file for the first line matching the pattern `# <title>` (a single hash followed by a space and text).

If found, extract the title text (the part after `# `).

If not found, report "Error: no H1 heading found in file" and halt without filing.

### Step 2.4 — File the issue

Execute the command:
```
gh issue create --title "PRD: <extracted-title>" --body-file <absolute-path-to-file> --assignee @me
```

Use the absolute path to the file. Capture the command output.

### Step 2.5 — Report result

Extract the issue URL from the command output (a line like `https://github.com/...`). Print only this URL.

## Synthesis-mode (when no argument or argument is not a `.md` file)

### Step 3.1 — Infer feature title

If no explicit title was provided as an argument, use the current
conversation context to infer a clear, concise feature title.

If an argument was provided but it's not a file path, treat it as the
feature title.

### Step 3.2 — Invoke prd-researcher (first pass)

Call the `prd-researcher` agent with the feature title, passing the
current conversation context. The agent returns a module sketch.

### Step 3.3 — Ask confirmation questions

Relay the sketch to the developer and ask, in one turn:
- Do these modules match your expectations?
- Which modules do you want tests written for?

### Step 3.4 — Invoke prd-researcher (second pass)

Call the `prd-researcher` agent again with:
- The feature title
- The module sketch
- The developer's answers to the two questions

The agent writes the full PRD and files the GitHub issue, returning
the issue URL.

### Step 3.5 — Report result

Print the returned issue URL.
