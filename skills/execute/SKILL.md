---
name: execute
description: Implement a single non-PRD GitHub issue using test-driven development. Requires a GitHub issue number or URL as input. Delegates the full red-green-refactor loop to the issue-runner agent and prints the resulting PR URL.
disable-model-invocation: true
allowed-tools: Read, Write, Bash(make *), Bash(git *), Bash(gh *), Agent
---

# Execute

Implement one GitHub issue using test-driven development. Assumes the
project is already bootstrapped by `/init-project` (build, lint, test,
CI, and release pipelines working). Run `/prd-to-issues` first if your
input is a PRD rather than an implementation slice.

## Process

1. Require a GitHub issue number or URL as argument. If none was
   supplied, stop and ask the developer for one.

2. Invoke the `issue-runner` agent with the issue reference. The agent
   will:
   - Fetch the issue and reject it if it looks like a PRD (so `/execute`
     is never pointed at planning work).
   - Create a branch, run the red-green-[refactor] loop per acceptance
     criterion, commit per cycle, and open a squash-merge PR.

3. If the agent rejects the issue as a PRD, relay its message to the
   developer (suggesting `/prd-to-issues` on the PRD) and stop.

4. Otherwise print the agent's report: branch name, commits made,
   final test and lint status, and the PR URL.

5. Remind the developer to review and **squash-merge** the PR (per the
   repo's merge convention). Do not wait for or act on the merge — a
   separate `/execute` invocation handles the next issue.
