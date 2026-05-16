#!/bin/bash

# Test suite for planning-session skill
# Validates that the skill meets all acceptance criteria

SKILL_FILE="skills/planning-session/SKILL.md"
ERRORS=0

check_criterion() {
    local name="$1"
    local check="$2"

    if eval "$check"; then
        echo "PASS: $name"
        return 0
    else
        echo "FAIL: $name"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Criterion 1: asks questions one at a time, never batches multiple questions
check_criterion "asks questions strictly one at a time" \
    "grep -qi 'one.*question.*at a time\|question per turn\|one at a time' '$SKILL_FILE'"

# Criterion 2: codebase scan before each question; answers itself if codebase evidence suffices
check_criterion "scans codebase before each question and self-answers when evidence exists" \
    "grep -qi 'read\|glob\|grep' '$SKILL_FILE' && grep -qi 'codebase\|scan' '$SKILL_FILE' && grep -qi 'answer.*itself\|without asking\|codebase.*alone\|codebase.*evidence\|instead of asking' '$SKILL_FILE'"

# Criterion 3: each question is accompanied by the skill's recommended answer
check_criterion "each question is accompanied by a recommended answer" \
    "grep -qi 'recommended answer\|recommend.*answer\|suggested answer' '$SKILL_FILE'"

# Criterion 4: dependency-ordered decision tree — foundational first, dependent decisions after
check_criterion "follows dependency-ordered decision tree with foundational decisions first" \
    "grep -qi 'dependency-ordered\|decision tree\|depend' '$SKILL_FILE' && grep -qi 'problem\|user\|scope' '$SKILL_FILE' && grep -qi 'architect\|testing\|rollout' '$SKILL_FILE'"

# Criterion 5: skill has a clear completion signal — all branches resolved before PRD assembly
check_criterion "defines completion signal before PRD assembly" \
    "grep -qi 'all branches\|branches are resolved\|exit criteria\|wrap.up\|once.*resolved\|once all' '$SKILL_FILE'"

# Criterion 6: seven-section PRD assembled with all required sections embedded in the skill
check_criterion "assembles seven-section PRD with all required sections listed" \
    "grep -qi 'Problem Statement' '$SKILL_FILE' && grep -qi 'Solution' '$SKILL_FILE' && grep -qi 'User Stories' '$SKILL_FILE' && grep -qi 'Implementation Decisions' '$SKILL_FILE' && grep -qi 'Testing Decisions' '$SKILL_FILE' && grep -qi 'Out of Scope' '$SKILL_FILE' && grep -qi 'Further Notes' '$SKILL_FILE'"

# Criterion 7: PRD draft is written to ./prd.md in the working directory
check_criterion "writes the PRD draft to ./prd.md" \
    "grep -q '\./prd\.md\|prd\.md' '$SKILL_FILE'"

# Criterion 8: after writing ./prd.md, hands off to new-prd skill in file-mode with ./prd.md as argument
check_criterion "hands off to new-prd in file-mode passing ./prd.md as argument" \
    "grep -qi 'new-prd' '$SKILL_FILE' && grep -qi 'file.mode\|file mode' '$SKILL_FILE' && grep -qi 'prd\.md.*argument\|argument.*prd\.md\|pass.*prd\.md\|prd\.md.*as argument' '$SKILL_FILE'"

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "All tests passed."
    exit 0
else
    echo "$ERRORS test(s) failed."
    exit 1
fi
