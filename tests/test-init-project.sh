#!/bin/bash

# Test suite for init-project skill (issue #54)
# Validates that the CLAUDE.md import uses ${CLAUDE_PLUGIN_ROOT} instead of
# a hardcoded absolute path.

SKILL_FILE="skills/init-project/SKILL.md"
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

# Criterion 1: line 54 uses ${CLAUDE_PLUGIN_ROOT}/CLAUDE.md
check_criterion "line 54 uses @\${CLAUDE_PLUGIN_ROOT}/CLAUDE.md" \
    "[ \"\$(sed -n '54p' '$SKILL_FILE')\" = '@\${CLAUDE_PLUGIN_ROOT}/CLAUDE.md' ]"

# Criterion 2: no hardcoded ~/.claude/plugins/cache path remains in the file
check_criterion "no hardcoded cache path in the file" \
    "! grep -q '~/.claude/plugins/cache' '$SKILL_FILE'"

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "All init-project tests passed."
    exit 0
else
    echo "$ERRORS test(s) failed."
    exit 1
fi
