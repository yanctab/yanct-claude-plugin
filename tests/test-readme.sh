#!/bin/bash

# Test suite for README.md updates (issue #58)
# Validates plugin rename from yanct-claude-plugin to ywflow-claude-plugin

README="README.md"
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

# Criterion 1: first line reads "# ywflow-claude-plugin"
check_criterion 'README.md first line reads "# ywflow-claude-plugin"' \
    "[ \"\$(sed -n '1p' '$README')\" = '# ywflow-claude-plugin' ]"

# Criterion 2: marketplace install command uses yanctab/ywflow-claude-plugin
check_criterion 'marketplace add command uses yanctab/ywflow-claude-plugin' \
    "grep -q '/plugin marketplace add yanctab/ywflow-claude-plugin' '$README'"

# Criterion 3: plugin install command reads /plugin install ywflow@ywflow
check_criterion 'plugin install command reads /plugin install ywflow@ywflow' \
    "grep -q '/plugin install ywflow@ywflow' '$README'"

# Criterion 4: slash command names unchanged — spot-check key commands
check_criterion '/init-project slash command name unchanged' \
    "grep -q '/init-project' '$README'"

check_criterion '/new-prd slash command name unchanged' \
    "grep -q '/new-prd' '$README'"

check_criterion '/prd-to-issues slash command name unchanged' \
    "grep -q '/prd-to-issues' '$README'"

check_criterion '/execute slash command name unchanged' \
    "grep -q '/execute' '$README'"

# Criterion 5: old plugin names no longer appear in the install block
check_criterion 'old yanct-claude-plugin name not present in install commands' \
    "! grep -q '/plugin marketplace add yanctab/yanct-claude-plugin' '$README'"

check_criterion 'old yanct-claude-plugin@yanct-claude-plugin not present' \
    "! grep -q '/plugin install yanct-claude-plugin@yanct-claude-plugin' '$README'"

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "All README tests passed."
    exit 0
else
    echo "$ERRORS test(s) failed."
    exit 1
fi
