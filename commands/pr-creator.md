---
description: Push the current branch and open a GitHub pull request
allowed-tools: Bash(git *), Bash(gh *)
---

Derive the PR title and body from the current branch, then delegate to the pr-creator agent.

## Step 1 — Gather context

Run the following commands to collect the information needed for the PR:

```
git branch --show-current
git log main..HEAD --oneline
git log main..HEAD --format="%B" | head -80
```

## Step 2 — Derive title and body

Use the git log output to produce:

- **title** — a short imperative summary (max 72 chars) drawn from the
  most recent commit subject, or from the branch name if no commits exist
  yet. If the user typed text after `/pr-creator` treat that text as the
  title instead and skip the derivation.
- **body** — a markdown summary with two sections:

  ```
  ## Summary
  <bullet points from the commit messages since main>

  ## Test plan
  - [ ] CI passes
  - [ ] Manual smoke test
  ```

  If there are no commits ahead of main, set body to `"No commits yet."`.

Ask the user to confirm or edit the title before proceeding. Do not
open the PR with a title the user has not approved.

## Step 3 — Open the PR

Invoke the pr-creator agent with the confirmed title and body:

@${CLAUDE_PLUGIN_ROOT}/agents/pr-creator.md

Pass:
- **title** — the confirmed PR title
- **body** — the generated PR body

## Step 4 — Report

Print the PR URL returned by the agent.
