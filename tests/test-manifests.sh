#!/bin/bash

# Test suite for plugin manifest fields (issue #53)
# Validates plugin.json and marketplace.json after rename to ywflow 2.0.0

PLUGIN_JSON=".claude-plugin/plugin.json"
MARKETPLACE_JSON=".claude-plugin/marketplace.json"
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

# Criterion 1: plugin.json has name "ywflow", version "2.0.0", repository pointing to ywflow-claude-plugin
check_criterion 'plugin.json name is "ywflow"' \
    "[ \"\$(jq -r '.name' '$PLUGIN_JSON')\" = 'ywflow' ]"

check_criterion 'plugin.json version is "2.0.0"' \
    "[ \"\$(jq -r '.version' '$PLUGIN_JSON')\" = '2.0.0' ]"

check_criterion 'plugin.json repository is "https://github.com/yanctab/ywflow-claude-plugin"' \
    "[ \"\$(jq -r '.repository' '$PLUGIN_JSON')\" = 'https://github.com/yanctab/ywflow-claude-plugin' ]"

# Criterion 2: marketplace.json top-level name is "ywflow"
check_criterion 'marketplace.json top-level name is "ywflow"' \
    "[ \"\$(jq -r '.name' '$MARKETPLACE_JSON')\" = 'ywflow' ]"

# Criterion 3: marketplace.json plugins[0].name is "ywflow"
check_criterion 'marketplace.json plugins[0].name is "ywflow"' \
    "[ \"\$(jq -r '.plugins[0].name' '$MARKETPLACE_JSON')\" = 'ywflow' ]"

# Criterion 4: marketplace.json plugins[0].source.url is "https://github.com/yanctab/ywflow-claude-plugin.git"
check_criterion 'marketplace.json plugins[0].source.url is "https://github.com/yanctab/ywflow-claude-plugin.git"' \
    "[ \"\$(jq -r '.plugins[0].source.url' '$MARKETPLACE_JSON')\" = 'https://github.com/yanctab/ywflow-claude-plugin.git' ]"

# Criterion 5: marketplace.json plugins[0].homepage is "https://github.com/yanctab/ywflow-claude-plugin"
check_criterion 'marketplace.json plugins[0].homepage is "https://github.com/yanctab/ywflow-claude-plugin"' \
    "[ \"\$(jq -r '.plugins[0].homepage' '$MARKETPLACE_JSON')\" = 'https://github.com/yanctab/ywflow-claude-plugin' ]"

# Criterion 6: no other fields changed — verify unchanged fields still match expected values
check_criterion 'plugin.json description unchanged' \
    "[ \"\$(jq -r '.description' '$PLUGIN_JSON')\" = 'Repeatable, deterministic development workflow for new projects via a Makefile contract' ]"

check_criterion 'plugin.json license unchanged' \
    "[ \"\$(jq -r '.license' '$PLUGIN_JSON')\" = 'MIT' ]"

check_criterion 'plugin.json author.name unchanged' \
    "[ \"\$(jq -r '.author.name' '$PLUGIN_JSON')\" = 'yanctab' ]"

check_criterion 'marketplace.json description unchanged' \
    "[ \"\$(jq -r '.description' '$MARKETPLACE_JSON')\" = 'Repeatable, deterministic development workflow for new projects via a Makefile contract' ]"

check_criterion 'marketplace.json owner.name unchanged' \
    "[ \"\$(jq -r '.owner.name' '$MARKETPLACE_JSON')\" = 'yanctab' ]"

check_criterion 'marketplace.json plugins[0].category unchanged' \
    "[ \"\$(jq -r '.plugins[0].category' '$MARKETPLACE_JSON')\" = 'development' ]"

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "All manifest tests passed."
    exit 0
else
    echo "$ERRORS test(s) failed."
    exit 1
fi
