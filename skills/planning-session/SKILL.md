---
name: planning-session
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me" or start a "planning-session".
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Agent, Bash
---

# Planning Session

Interview me relentlessly about a plan or design until we reach a shared understanding. Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one.

## Process Overview

This skill drives a dependency-ordered decision tree — one question per turn. Before each question, pre-scan the codebase via Read/Glob/Grep to gather relevant context. If a question can be answered from codebase evidence alone, answer it yourself and move on without asking the user.

Each question is accompanied by the skill's recommended answer so you can accept or correct it.

When all decision-tree branches are resolved and no open questions remain, you'll declare wrap-up and assemble a seven-section PRD draft, write it to `./prd.md`, then hand off to the `new-prd` skill in file-mode by passing `./prd.md` as argument.

## Step 1 — Foundational Decisions (Problem, User, Scope)

These decisions are always asked first, as all later decisions depend on them.

### Step 1.1 — Understand the Problem

**Before asking:** Scan the codebase with Glob/Grep to look for existing issues, READMEs, or documentation that describe the problem being solved. Check for similar features or patterns.

**Question:** What is the core problem you're trying to solve? Who is experiencing it, and why is it important to solve now?

**Recommended answer strategy:** If the codebase gives evidence of the problem (e.g., open issues, TODO comments, README sections), synthesize your recommended answer from that. If not, ask the user and listen carefully.

**Accept/correct:** The user confirms or adjusts your recommended answer.

### Step 1.2 — Identify the User

**Before asking:** Check the codebase for clues about target users (existing user types, roles mentioned in code comments, documentation, or architecture).

**Question:** Who is the primary user for this feature? Are there secondary users?

**Recommended answer strategy:** Infer from the problem statement and codebase patterns. For example, if the problem is "developers spend too much time X," the user is "developers." Suggest this and let them confirm.

**Accept/correct:** The user confirms or refines the user description.

### Step 1.3 — Establish Scope Boundaries

**Before asking:** Search the codebase for existing scope boundaries (e.g., "we only support X, not Y"), constraints, or version-specific decisions.

**Question:** What is explicitly in scope for this feature, and what is out of scope? What are the hard constraints (e.g., performance, compatibility, platform)?

**Recommended answer strategy:** Based on the problem and user, suggest a reasonable scope (e.g., "support macOS and Linux, not Windows"; "target the web only, not mobile"). Ask for confirmation or refinement.

**Accept/correct:** The user confirms, extends, or narrows the scope.

## Step 2 — Architecture Decisions

These depend on foundational decisions from Step 1.

### Step 2.1 — Choose Implementation Strategy

**Before asking:** Examine the codebase architecture. Look at how similar features are implemented, what modules exist, and what technologies are already in use.

**Question:** How will you implement this feature? What architecture or design pattern makes sense given the codebase, the problem, and the constraints?

**Recommended answer strategy:** Suggest an architecture that aligns with existing patterns in the codebase (e.g., "add a new CLI command in the commands/ module" or "extend the existing parser"). Explain why it fits.

**Accept/correct:** The user confirms or proposes a different approach.

### Step 2.2 — Identify Dependencies and Integrations

**Before asking:** Search the codebase for existing integrations, external APIs, or dependencies that might be relevant.

**Question:** Does this feature depend on or integrate with any external systems, APIs, or existing modules? What are those?

**Recommended answer strategy:** List the dependencies you found in the codebase scan. If none, ask the user if new dependencies are planned.

**Accept/correct:** The user confirms or extends the list.

## Step 3 — Testing Decisions

These depend on architecture and scope from earlier steps.

### Step 3.1 — Define Test Coverage

**Before asking:** Check the codebase for existing test patterns, test directories, and test frameworks in use.

**Question:** How will you test this feature? What scenarios are critical to test? What test framework or approach will you use?

**Recommended answer strategy:** Based on the codebase testing patterns, suggest a test strategy (e.g., "unit tests for the core logic, integration tests for CLI invocation"). Point to existing test examples.

**Accept/correct:** The user confirms or refines the test strategy.

## Step 4 — Rollout Decisions

These depend on all earlier steps.

### Step 4.1 — Define Rollout and Documentation

**Before asking:** Check for existing rollout patterns, CHANGELOG templates, or documentation standards in the codebase.

**Question:** How will you roll out this feature? Do users need to know about it (docs, changelog, announcement)? Are there migration or upgrade steps?

**Recommended answer strategy:** Based on the codebase conventions, suggest a rollout approach (e.g., "document in README, add to CHANGELOG, no migration needed").

**Accept/correct:** The user confirms or adjusts the rollout plan.

## Step 5 — Exit Criteria and Wrap-up

Declare explicit exit criteria here: **All decision-tree branches resolved with no open questions.**

Once all five step groups (foundational, architecture, testing, rollout) are complete and the user has confirmed their answers, announce that you are entering wrap-up.

## Step 6 — Assemble and Write PRD

With all decisions finalized, assemble a seven-section PRD draft using the embedded structure below. Do NOT call the `prd-researcher` agent.

### PRD Structure

Embed the following seven sections directly in the PRD:

```
# <Feature Title>

## Problem Statement

<Summarize the core problem, who has it, why it matters>

## Solution

<Describe your proposed solution and how it addresses the problem>

## User Stories

- As a [role], I want [capability], so that [benefit]
- <Additional user stories as needed>

## Implementation Decisions

<Describe the architecture, design pattern, and key technical choices>

## Testing Decisions

<Outline your test strategy, critical scenarios, and test framework>

## Out of Scope

<List what is explicitly out of scope>

## Further Notes

<Any additional context, links, or notes>
```

### Write to ./prd.md

Use the Write tool to save the complete PRD to `./prd.md` in the working directory.

## Step 7 — Hand Off to new-prd Skill

After writing `./prd.md`, invoke the `new-prd` skill in file-mode by passing the absolute path to `./prd.md` as an argument.

Example: `new-prd /absolute/path/to/prd.md`

The `new-prd` skill will validate the PRD structure and file it as a GitHub issue.
