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

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "All tests passed."
    exit 0
else
    echo "$ERRORS test(s) failed."
    exit 1
fi
