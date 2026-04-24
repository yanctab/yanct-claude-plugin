---
name: update-project
description: Audit an existing project against the current plugin workflow and apply any missing pieces. Run when a project was initialised before a plugin update or when workflow rules have changed.
disable-model-invocation: true
allowed-tools: Read, Write, Bash(git *), Bash(gh *), Bash(mkdir *), Bash(touch *), Bash(jq *), Bash(rsync *)
---

# Update Project

You are aligning an existing project with the current plugin workflow.
You will audit the project, report what is out of date, and apply
selected updates on a branch with a PR.

## Step 1 — Read project context

Read `.claude/CLAUDE.md` if it exists, or fall back to `CLAUDE.md` in the
project root. If `.claude/CLAUDE.md` is missing but `CLAUDE.md` exists, that
is a fixable state — do not stop, proceed to the audit. Only stop if both
are absent, as the project has not been initialised at all.

Detect project type:
- `Cargo.toml` present → rust-cli
- `.claude-plugin/plugin.json` present → claude-plugin
- Otherwise → generic

## Step 2 — Audit current state

Check each item below. Mark each as ✓ (up to date) or ✗ (missing/outdated).

### Universal checks

**`.claude/CLAUDE.md` — file exists**
Check that `.claude/CLAUDE.md` exists. If missing, mark ✗ — the fix will
recreate it from the plugin template. Skip the content check below if absent.

**`.claude/settings.json` — file exists**
Check that `.claude/settings.json` exists. If missing, mark ✗ — the fix will
create it with the correct permissions and hook configuration. Skip the
permissions checks below if absent.

**`.claude/CLAUDE.md` — version control rules**
Check that it contains both:
- "Never push directly to main or master"
- "All PRs must be merged with a squash commit"

**`.claude/settings.json` — universal permissions**
Check that `permissions.allow` contains at minimum:
`"Write"`, `"Bash(make *)"`, `"Bash(git *)"`, `"Bash(mkdir *)"`,
`"Bash(touch *)"`, `"Bash(cp *)"`

**`Makefile` — fmt and fmt-check targets**
Check that the Makefile contains `fmt:` and `fmt-check:` targets.

**GitHub — squash-only merge policy**
Run: `gh api repos/{owner}/{repo} --jq '{squash: .allow_squash_merge, merge: .allow_merge_commit, rebase: .allow_rebase_merge}'`
Expected: squash=true, merge=false, rebase=false.

**GitHub — branch protection on main**
Run: `gh api repos/{owner}/{repo}/branches/main/protection 2>&1`
If the command returns a 404, branch protection is not enabled.

### Rust-cli checks (only if Cargo.toml exists)

**`.claude/settings.json` — rust-specific permissions**
Check that `permissions.allow` also contains:
`"Bash(cargo init *)"`, `"Bash(cargo add *)"`, `"Bash(rustup *)"`,
`"Bash(chmod *)"`, `"Bash(sudo apt-get *)"`

**`.claude/settings.json` — post-edit lint hook**
Check that `hooks.PostToolUse` exists with the post-edit-lint.sh command.

**`.claude/settings.json` — hook path valid**
If `PostToolUse` is configured, extract the `command` value and verify the
file exists at that path. If the plugin has been updated and the version
path has changed, the old path will be broken. Mark ✗ if the file is missing.

**`Makefile` — lint delegates to fmt-check**
Check that the `lint:` target calls `$(MAKE) fmt-check` (not `cargo fmt --check` directly).

**`.github/workflows/ci.yml`**
Check that the file exists and runs `make lint` and `make test`.

### Claude-plugin checks (only if .claude-plugin/plugin.json exists)

**`.claude-plugin/plugin.json` — valid JSON**
Run: `jq . .claude-plugin/plugin.json > /dev/null 2>&1`
Mark ✗ if the command fails.

**`.claude-plugin/marketplace.json` — exists and valid JSON**
Check the file exists, then run: `jq . .claude-plugin/marketplace.json > /dev/null 2>&1`
Mark ✗ if missing or invalid.

**`.claude-plugin/marketplace.json` — source format**
Check that `plugins[0].source.source` equals `"url"` (not `"."`).
A value of `"."` is invalid and will break `/plugin marketplace add`.

**Plugin directories — commands/ skills/ agents/ hooks/**
Check that all four directories exist.

**`.claude/settings.json` — claude-plugin permissions**
Check that `permissions.allow` contains:
`"Bash(jq *)"` and `"Bash(rsync *)"`.

**`.claude/settings.json` — post-edit lint hook**
Check that `hooks.PostToolUse` exists with the post-edit-lint.sh command.

**`.claude/settings.json` — hook path valid**
If `PostToolUse` is configured, extract the `command` value and verify the
file exists at that path. Mark ✗ if the file is missing (stale plugin path).

**`Makefile` — make install uses rsync to local plugin cache**
Check that the `install:` target contains `rsync` and references
`$(HOME)/.claude/plugins/cache`.

**`Makefile` — make lint validates JSON with jq**
Check that the `lint:` target calls `jq`.

**`.claude/CLAUDE.md` — skill-creator dependency declared**
Check that `.claude/CLAUDE.md` mentions `skill-creator`.

**`.github/workflows/ci.yml` — installs jq**
Check that ci.yml installs jq (e.g. `apt-get install -y jq`).

## Step 3 — Present audit report

Display a clear table of results:

```
Audit results:
  ✓ .claude/CLAUDE.md — file exists
  ✓ .claude/CLAUDE.md — version control rules present
  ✗ .claude/settings.json — file missing
  ✗ Makefile — fmt and fmt-check targets missing
  ✓ GitHub — squash-only merge enabled
  ✗ GitHub — branch protection not configured
  ...
```

For each ✗ item, briefly explain what will be changed.

Ask the developer: "Which items would you like me to fix? (all / list numbers / none)"

Wait for the developer's response before proceeding.

## Step 4 — Apply updates on a branch

If the developer selects any file-level changes, create a branch:
```
git checkout -b chore/update-project-workflow
```

**IMPORTANT — scope guard**: Only modify files that are explicitly addressed
in a fix step below. Do not delete, move, rename, or modify any other file
in the repository.

Apply each selected file-level change:

### Fix: .claude/CLAUDE.md missing
If `.claude/CLAUDE.md` does not exist, create the `.claude/` directory if
needed, then create the file. Substitute `${CLAUDE_PLUGIN_ROOT}` with the
actual value of that environment variable (the installed plugin path):
```markdown
# Claude Code Context

@../CLAUDE.md

@${CLAUDE_PLUGIN_ROOT}/CLAUDE.md

## Version Control Rules

- Never push directly to main or master — always use a feature branch and PR
- All PRs must be merged with a squash commit — never merge commit or rebase merge
```

### Fix: .claude/settings.json missing
If `.claude/settings.json` does not exist, create it. For rust-cli projects,
use the full template from rust-cli-finalize (universal + rust permissions +
PostToolUse hook). For generic projects, use the universal permissions
template from init-project plus the PostToolUse hook section.
In both cases set the hook command to the current plugin path:
```
${CLAUDE_PLUGIN_ROOT}/hooks/post-edit-lint.sh
```
substituting the actual value of `$CLAUDE_PLUGIN_ROOT` before writing.

### Fix: .claude/settings.json hook path stale
If the hook is configured but the command path does not resolve to an existing
file, read the current settings.json, replace only the `command` value in the
PostToolUse hook with `${CLAUDE_PLUGIN_ROOT}/hooks/post-edit-lint.sh`
(substituting the actual `$CLAUDE_PLUGIN_ROOT`), then write the file back.

### Fix: .claude/CLAUDE.md version control rules
Append to `.claude/CLAUDE.md` (after the existing imports):
```markdown
## Version Control Rules

- Never push directly to main or master — always use a feature branch and PR
- All PRs must be merged with a squash commit — never merge commit or rebase merge
```

### Fix: .claude/settings.json — universal permissions
The file exists (created above if it was missing). Merge in any missing
`permissions.allow` entries so it contains at minimum all universal entries.

### Fix: .claude/settings.json — rust-specific permissions and hook
The file exists (created above if it was missing). Merge in any missing
rust-specific permissions and the PostToolUse hook section. The final file
should match the template from rust-cli-finalize.

### Fix: Makefile — add fmt and fmt-check targets
Add after the `build:` target:
```makefile
fmt:
	<formatter command for this project type>

fmt-check:
	<check command for this project type>
```
For rust-cli: `cargo fmt` and `cargo fmt --check`.
Update `lint:` to call `$(MAKE) fmt-check` instead of running the
formatter check directly.

### Fix: .claude-plugin/marketplace.json — source format
Read the file, change `plugins[0].source` from `{ "source": "." }` to:
```json
{
  "source": "url",
  "url": "https://github.com/<owner>/<repo>.git"
}
```
Ask the developer for the GitHub URL if it is not already present in
`plugin.json` or `marketplace.json`.

### Fix: plugin directories missing
Create any missing directories:
```
mkdir -p commands skills agents hooks
touch commands/.gitkeep skills/.gitkeep agents/.gitkeep hooks/.gitkeep
```
Only create `.gitkeep` for directories that were just created and are empty.

### Fix: .claude/settings.json — claude-plugin permissions and hooks
The file exists (created above if missing). Merge in any missing entries so
`permissions.allow` contains all universal entries plus `"Bash(jq *)"` and
`"Bash(rsync *)"`. Add the PostToolUse hook section if missing, with
post-edit-lint.sh. Substitute the actual value of `$CLAUDE_PLUGIN_ROOT`
in the hook path before writing.

### Fix: Makefile — make install target
Replace or add the `install:` target with the rsync-based local install:
```makefile
CACHE_DIR   := $(HOME)/.claude/plugins/cache/$(PLUGIN_NAME)/$(PLUGIN_NAME)/$(VERSION)

## install - copy working directory into the local Claude plugin cache
install:
	@echo "Installing $(PLUGIN_NAME)@$(VERSION) to local Claude plugin cache..."
	@mkdir -p "$(CACHE_DIR)"
	@rsync -a --delete --exclude='.git/' --exclude='.claude/' . "$(CACHE_DIR)/"
	@echo "Installed to: $(CACHE_DIR)"
	@echo "Reload Claude Code to pick up changes."
```
Also ensure the Makefile defines `PLUGIN_NAME` and `VERSION` via `jq` from
`.claude-plugin/plugin.json` if not already present.

### Fix: Makefile — make lint validates JSON
Replace or update the `lint:` target to validate both JSON manifests:
```makefile
lint:
	@echo "Validating .claude-plugin/plugin.json..."
	@jq . .claude-plugin/plugin.json > /dev/null
	@echo "Validating .claude-plugin/marketplace.json..."
	@jq . .claude-plugin/marketplace.json > /dev/null
	@echo "JSON validation passed."
```

### Fix: .claude/CLAUDE.md — skill-creator dependency
Append to `.claude/CLAUDE.md`:
```markdown
## Dev Dependencies

The skill-creator plugin from Anthropic is required to create and iterate on
skills in this project. Install it once in Claude Code:

```
/plugin marketplace add claude-plugins-official/skill-creator
/plugin install skill-creator@skill-creator
```

Use `/skill-creator` to create new skills, improve existing ones, or run evals.
```

### Fix: .github/workflows/ci.yml — installs jq
Read the file and add `sudo apt-get install -y jq rsync` as a step before
`make lint` and `make test` if not already present.

After all file changes, stage only the files you actually modified in this
step — never use `git add .` or `git add -A`. Build the command from the
list of files changed above, for example:
```
git add .claude/CLAUDE.md .claude/settings.json Makefile
git commit -m "chore: align project with current plugin workflow"
```
Omit any file from the `git add` that was not modified.

Push and open a PR:
```
git commit -m "chore: align project with current plugin workflow"
```

> Use the pr-creator agent with title "chore: align project with current plugin workflow" and body "Applies missing workflow updates: <list items fixed>"

Show the PR URL to the developer.

## Step 5 — Apply GitHub settings (directly, no PR needed)

If the developer selected GitHub settings fixes, apply them now:

### Fix: squash-only merge policy
```
gh api repos/{owner}/{repo} \
  --method PATCH \
  --field allow_squash_merge=true \
  --field allow_merge_commit=false \
  --field allow_rebase_merge=false
```

### Fix: branch protection on main
```
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews=null \
  --field restrictions=null
```

## Step 6 — Report

Summarise:
- Items that were already up to date
- Items fixed via PR (with PR URL)
- Items fixed directly (GitHub settings)
- Any items skipped at the developer's request
