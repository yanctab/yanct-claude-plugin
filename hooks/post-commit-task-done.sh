#!/usr/bin/env bash
# post-commit-task-done.sh
# After a git commit, marks the current task done in TASKS.md.
# Reads .claude/current-task for the task title.
#
# Hook event: PostToolUse
# Matcher: Bash

set -uo pipefail

# Read event JSON from stdin and check if this was a git commit command
input=$(cat)
command_str=$(echo "$input" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    print('')" 2>/dev/null || echo "")

if ! echo "$command_str" | grep -qE "git commit"; then
    exit 0
fi

# Only act when a task is in progress
[[ -f ".claude/current-task" ]] || exit 0
[[ -f "TASKS.md" ]] || exit 0

TASK=$(head -1 .claude/current-task)

python3 - "$TASK" <<'PYEOF'
import sys
task = sys.argv[1].strip()
if not task:
    sys.exit(0)
with open('TASKS.md', 'r') as f:
    content = f.read()
updated = content.replace('- [ ] **' + task + '**', '- [x] **' + task + '**', 1)
with open('TASKS.md', 'w') as f:
    f.write(updated)
PYEOF

rm -f .claude/current-task
exit 0
