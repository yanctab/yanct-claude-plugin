---
name: planning-session
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me" or start a "planning-session".
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Agent, Bash
---

# Planning Session

Ask questions one at a time — never batch multiple questions in a single turn.

Before each question, scan the codebase using Read, Glob, and Grep to gather
relevant context. If a question can be answered from codebase evidence alone,
answer it yourself and move on without asking the user.

Each question must be accompanied by a recommended answer. State your
recommended answer clearly so the user can accept it or correct it.

## Dependency-Ordered Decision Tree

Follow this dependency-ordered decision tree — foundational decisions
(problem, user, scope) always come first, because architecture, testing,
and rollout decisions depend on them.

### Phase 1 — Foundational (problem, user, scope)

Ask about the core problem, who the user is, and what is in scope
before any other questions. These answers are prerequisites for all
later phases.

### Phase 2 — Architecture

Ask how the feature will be implemented and what dependencies or
integrations are involved. These decisions depend on scope and user
from Phase 1.

### Phase 3 — Testing

Ask how the feature will be tested and what critical scenarios must
be covered. These decisions depend on the architecture from Phase 2.

### Phase 4 — Rollout

Ask how the feature will be rolled out and documented. These decisions
depend on all earlier phases.

## Exit Criteria

The exit criteria are: all decision-tree branches resolved with no open
questions remaining. When every phase (foundational, architecture, testing,
rollout) is complete and the user has confirmed their answers, declare
that you are entering wrap-up before assembling the PRD.

## PRD Assembly

Do NOT call the `prd-researcher` agent. Assemble the PRD yourself using
the seven sections below, populated from the decisions collected during
the session.

Use this exact section structure:

```
# <Feature Title>

## Problem Statement

<Summarize the core problem, who has it, why it matters>

## Solution

<Describe the proposed solution and how it addresses the problem>

## User Stories

- As a [role], I want [capability], so that [benefit]
- <Additional user stories as needed>

## Implementation Decisions

<Describe the architecture, design pattern, and key technical choices>

## Testing Decisions

<Outline the test strategy, critical scenarios, and test framework>

## Out of Scope

<List what is explicitly out of scope>

## Further Notes

<Any additional context, links, or notes>
```
