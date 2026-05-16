#!/bin/bash

# Test suite for ywflow.yaml plugin reference (issue #59)
# Validates that the plugin field is updated to ywflow and
# the ${plugin} interpolation sites are preserved.

YWFLOW_YAML="ywflow.yaml"
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

# Criterion 1: line 6 reads "plugin: ywflow"
check_criterion 'ywflow.yaml line 6 reads "plugin: ywflow"' \
    "[ \"\$(sed -n '6p' '$YWFLOW_YAML')\" = '  plugin: ywflow' ]"

# Criterion 2: the four \${plugin} interpolation sites on lines 31, 47, 64, 80 are untouched
check_criterion 'ywflow.yaml line 31 contains ${plugin} interpolation' \
    "grep -q '\${plugin}' <(sed -n '31p' '$YWFLOW_YAML')"

check_criterion 'ywflow.yaml line 47 contains ${plugin} interpolation' \
    "grep -q '\${plugin}' <(sed -n '47p' '$YWFLOW_YAML')"

check_criterion 'ywflow.yaml line 64 contains ${plugin} interpolation' \
    "grep -q '\${plugin}' <(sed -n '64p' '$YWFLOW_YAML')"

check_criterion 'ywflow.yaml line 80 contains ${plugin} interpolation' \
    "grep -q '\${plugin}' <(sed -n '80p' '$YWFLOW_YAML')"

# Criterion 3: no stale yanct-claude-plugin reference remains in the plugin field
check_criterion 'ywflow.yaml has no "plugin: yanct-claude-plugin" line' \
    "! grep -q '^  plugin: yanct-claude-plugin$' '$YWFLOW_YAML'"

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "All ywflow.yaml tests passed."
    exit 0
else
    echo "$ERRORS test(s) failed."
    exit 1
fi
