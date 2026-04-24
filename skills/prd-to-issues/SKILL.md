---
name: prd-to-issues
description: Break a PRD issue into implementation issues as vertical tracer-bullet slices. Requires a PRD GitHub issue number or URL as input.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Agent, Bash
---

# PRD to Issues

Break a PRD that was filed by `/new-prd` into independently-grabbable
GitHub issues, each a vertical tracer-bullet slice through every
integration layer. Requires a PRD issue number or URL as input.

## Process

1. Require a GitHub issue number or URL as argument. If none was
   supplied, stop and ask the developer for one. Do not synthesise a
   PRD inline.

2. Invoke the `issue-slicer` agent with the PRD issue reference. It
   fetches the issue, explores the codebase, and returns a proposed
   slice breakdown (numbered list; each slice shows title, HITL/AFK,
   blocked-by, user stories covered, layers touched).

3. Present the breakdown and ask:
   - Does the granularity feel right? (too coarse / too fine)
   - Are the dependency relationships correct?
   - Should any slices be merged or split further?
   - Are the correct slices marked HITL vs AFK?

4. If the developer asks for revisions, re-invoke the agent with the
   prior breakdown and the revision notes; it returns an updated
   breakdown. Iterate until the developer explicitly approves.

5. On approval, invoke the agent one more time to file the issues in
   dependency order. Print the resulting issue URLs, one per line.
