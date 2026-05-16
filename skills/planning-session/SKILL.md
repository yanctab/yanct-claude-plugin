---
name: planning-session
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me" or start a "planning-session".
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Agent, Bash
---

Interview the user relentlessly about every aspect of the plan until reaching a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead of asking.

Once all branches are resolved, write `./prd.md` containing the final solution. The file must include all seven required sections — missing any one will cause `/new-prd` to reject it:

```
# <Feature Title>

## Problem Statement
## Solution
## User Stories
## Implementation Decisions
## Testing Decisions
## Out of Scope
## Further Notes
```

Then invoke the `new-prd` skill in file-mode by passing `./prd.md` as the argument.
