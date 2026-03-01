---
name: update-project
description: Audit an existing project against the current plugin workflow and apply any missing pieces. Run when a project was initialised before a plugin update or when workflow rules have changed.
disable-model-invocation: true
allowed-tools: Read, Write, Bash(git *), Bash(gh *), Bash(mkdir *)
---

# Update Project

You are aligning an existing project with the current plugin workflow.
You will audit the project, report what is out of date, and apply
selected updates on a branch with a PR.

## Step 1 — Read project context

Read `.claude/CLAUDE.md` if it exists, or `CLAUDE.md` in the root.
If neither exists, tell the developer to run `/init-project` first and stop.

Detect project type:
- `Cargo.toml` present → rust-cli
- Otherwise → generic

## Step 2 — Audit current state

Check each item below. Mark each as ✓ (up to date) or ✗ (missing/outdated).

### Universal checks

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

**`Makefile` — lint delegates to fmt-check**
Check that the `lint:` target calls `$(MAKE) fmt-check` (not `cargo fmt --check` directly).

**`.github/workflows/ci.yml`**
Check that the file exists and runs `make lint` and `make test`.

## Step 3 — Present audit report

Display a clear table of results:

```
Audit results:
  ✓ .claude/CLAUDE.md — version control rules present
  ✗ .claude/settings.json — missing fmt-check and git permissions
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

Apply each selected file-level change:

### Fix: .claude/CLAUDE.md version control rules
Append to `.claude/CLAUDE.md` (after the existing imports):
```markdown
## Version Control Rules

- Never push directly to main or master — always use a feature branch and PR
- All PRs must be merged with a squash commit — never merge commit or rebase merge
```

### Fix: .claude/settings.json — universal permissions
If the file does not exist, create it. If it exists, merge in the missing keys.
Ensure `permissions.allow` contains all universal entries.

### Fix: .claude/settings.json — rust-specific permissions and hook
Merge in the rust-specific permissions and the PostToolUse hook.
The final file should match the template from rust-cli-finalize.

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

After all file changes, commit:
```
git add .
git commit -m "chore: align project with current plugin workflow"
```

Push and open a PR:
```
git push -u origin chore/update-project-workflow
gh pr create \
  --title "chore: align project with current plugin workflow" \
  --body "Applies missing workflow updates: <list items fixed>"
```

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
