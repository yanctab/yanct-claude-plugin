#!/bin/bash

# Test suite for .claude/CLAUDE.md import reference (issue #57)
# Validates that the hardcoded cache path has been replaced with ${CLAUDE_PLUGIN_ROOT}

CLAUDE_MD=".claude/CLAUDE.md"
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

# Criterion 1: line 4 reads exactly @${CLAUDE_PLUGIN_ROOT}/CLAUDE.md
check_criterion 'line 4 reads @${CLAUDE_PLUGIN_ROOT}/CLAUDE.md' \
    "[ \"\$(sed -n '4p' '$CLAUDE_MD')\" = '@\${CLAUDE_PLUGIN_ROOT}/CLAUDE.md' ]"

# Criterion 2: old hardcoded path no longer appears anywhere in the file
check_criterion 'no hardcoded cache path in the file' \
    "! grep -q '~/.claude/plugins/cache/' '$CLAUDE_MD'"

# Criterion 3: no other lines modified — verify other known content is intact
check_criterion 'line 1 is "# Claude Code Context" (unchanged)' \
    "[ \"\$(sed -n '1p' '$CLAUDE_MD')\" = '# Claude Code Context' ]"

check_criterion 'line 3 is "@../CLAUDE.md" (unchanged)' \
    "[ \"\$(sed -n '3p' '$CLAUDE_MD')\" = '@../CLAUDE.md' ]"

check_criterion '"## Version Control Rules" section still present (unchanged)' \
    "grep -q '## Version Control Rules' '$CLAUDE_MD'"

check_criterion '"## Dev Dependencies" section still present (unchanged)' \
    "grep -q '## Dev Dependencies' '$CLAUDE_MD'"

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "All .claude/CLAUDE.md tests passed."
    exit 0
else
    echo "$ERRORS test(s) failed."
    exit 1
fi
