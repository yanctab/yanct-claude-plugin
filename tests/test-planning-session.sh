#!/bin/bash

# Test suite for planning-session skill
# Validates that the skill meets all acceptance criteria

set -e

SKILL_FILE="skills/planning-session/SKILL.md"
ERRORS=0

# Helper function to check criteria
check_criterion() {
    local name="$1"
    local check="$2"

    if eval "$check"; then
        echo "✓ $name"
        return 0
    else
        echo "✗ $name"
        ((ERRORS++))
        return 1
    fi
}

# Test 1: Has required YAML frontmatter with correct format
check_criterion "Has YAML frontmatter with name, description, disable-model-invocation, and allowed-tools" \
    "grep -q '^---$' '$SKILL_FILE' && grep -q 'name: planning-session' '$SKILL_FILE' && grep -q 'disable-model-invocation: true' '$SKILL_FILE' && grep -q 'allowed-tools:' '$SKILL_FILE'"

# Test 2: Contains instructions for one-question-at-a-time interaction
check_criterion "Mentions asking questions one at a time" \
    "grep -qi 'one.*question\|question per turn\|per turn' '$SKILL_FILE'"

# Test 3: Contains codebase scanning instructions (Read/Glob/Grep)
check_criterion "Mentions codebase scanning with Read/Glob/Grep before each question" \
    "grep -qi 'read\|glob\|grep\|scan.*codebase\|explore.*codebase' '$SKILL_FILE'"

# Test 4: Mentions skipping questions if answered from codebase
check_criterion "Explains skipping questions if already answerable from codebase" \
    "grep -qi 'skip\|without asking\|answer.*itself\|codebase.*alone' '$SKILL_FILE'"

# Test 5: Mentions providing recommended answer with each question
check_criterion "Describes providing recommended answer alongside each question" \
    "grep -qi 'recommend\|suggest.*answer' '$SKILL_FILE'"

# Test 6: Mentions dependency-ordered decision tree
check_criterion "References dependency-ordered decision tree" \
    "grep -qi 'depend\|tree\|order' '$SKILL_FILE'"

# Test 7: Mentions exit criteria explicitly
check_criterion "References explicit exit criteria" \
    "grep -qi 'exit\|wrap.up\|done\|complete' '$SKILL_FILE'"

# Test 8: Mentions assembling seven-section PRD without calling prd-researcher
check_criterion "Describes assembling seven-section PRD embedded (not via prd-researcher)" \
    "grep -qi 'seven.*section\|problem statement\|solution\|user stories' '$SKILL_FILE' && grep -qv 'prd-researcher' '$SKILL_FILE' || grep -qi 'NOT.*prd-researcher\|without.*prd-researcher\|embedded.*section' '$SKILL_FILE'"

# Test 9: Mentions writing to ./prd.md
check_criterion "Mentions writing PRD to ./prd.md" \
    "grep -qi 'prd.md\|./prd.md' '$SKILL_FILE'"

# Test 10: Mentions handing off to new-prd skill in file-mode
check_criterion "Describes handing off to new-prd skill in file-mode with prd.md argument" \
    "grep -qi 'new-prd\|hand.off' '$SKILL_FILE'"

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "$ERRORS test(s) failed"
    exit 1
fi
