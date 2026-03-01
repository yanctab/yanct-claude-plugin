#!/usr/bin/env bash
# post-edit-lint.sh
# Runs make lint after Claude edits a source file.
# Silent on success. Outputs errors on failure so Claude sees them.
#
# Hook event: PostToolUse
# Matcher: Edit|Write|MultiEdit
#
# To install: add to .claude/settings.json hooks section or via /hooks

set -euo pipefail

# Only run if a Makefile exists with a lint target
if [[ ! -f "Makefile" ]]; then
    exit 0
fi

if ! grep -q "^lint:" Makefile 2>/dev/null; then
    exit 0
fi

# Run lint, capture output
output=$(make lint 2>&1)
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
    # Silent on success — nothing added to context
    exit 0
else
    # Output errors so Claude sees them and can fix
    echo "Lint failed after file edit:"
    echo "$output"
    exit 1
fi
