#!/bin/bash

# Test suite for .claude/settings.local.json and .claude/settings.json (issue #56)

SETTINGS_LOCAL=".claude/settings.local.json"
SETTINGS_JSON=".claude/settings.json"
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

# Criterion 1: settings.local.json allows Skill(ywflow:commit), not yanct-claude-plugin
check_criterion 'settings.local.json allows Skill(ywflow:commit)' \
    "jq -e '.permissions.allow | contains([\"Skill(ywflow:commit)\"])' '$SETTINGS_LOCAL' > /dev/null"

# Criterion 2: three stale Bash(...) entries are removed — no entry starts with "Bash(find" or "Bash(mkdir -p /mnt/" or "Bash(cd /home/mans/.claude/plugins"
check_criterion 'settings.local.json has no stale eval-run Bash entries' \
    "! jq -r '.permissions.allow[]' '$SETTINGS_LOCAL' | grep -qE '^Bash\(find ~/.claude|^Bash\(find /mnt/|^Bash\(mkdir -p /mnt/|^Bash\(cd /home/mans/\.claude/plugins'"

# Criterion 3: settings.json hook command uses ${CLAUDE_PLUGIN_ROOT}, not a hardcoded absolute path
check_criterion 'settings.json hook command uses ${CLAUDE_PLUGIN_ROOT}/hooks/post-edit-lint.sh' \
    "[ \"\$(jq -r '.hooks.PostToolUse[0].hooks[0].command' '$SETTINGS_JSON')\" = '\${CLAUDE_PLUGIN_ROOT}/hooks/post-edit-lint.sh' ]"

# Criterion 4: no other entries added or removed — settings.local.json has exactly 11 allow entries
check_criterion 'settings.local.json has exactly 11 allow entries (10 Bash + 1 Skill)' \
    "[ \"\$(jq '.permissions.allow | length' '$SETTINGS_LOCAL')\" = '11' ]"

# Criterion 4: settings.json permissions allow array unchanged — exactly 9 entries
check_criterion 'settings.json has exactly 9 allow entries (unchanged)' \
    "[ \"\$(jq '.permissions.allow | length' '$SETTINGS_JSON')\" = '9' ]"

# Criterion 4: settings.json hook structure unchanged — exactly 1 PostToolUse rule
check_criterion 'settings.json has exactly 1 PostToolUse rule (unchanged)' \
    "[ \"\$(jq '.hooks.PostToolUse | length' '$SETTINGS_JSON')\" = '1' ]"

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "All settings tests passed."
    exit 0
else
    echo "$ERRORS test(s) failed."
    exit 1
fi
