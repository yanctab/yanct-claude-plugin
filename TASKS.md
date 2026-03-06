# TASKS

## Implementation

- [ ] **Automate plugin version increment and git tag on release** [core] M
  - Acceptance: `make release` interactively prompts for major/minor/patch, writes the new semver into `.claude-plugin/plugin.json` via `jq`, commits the bump with message `chore(release): bump version to v<new>`, creates an annotated tag `v<new>`, and pushes both the commit and the tag; running `make release` with no uncommitted changes on a clean branch succeeds end-to-end with the correct version reflected in `plugin.json` and `git tag`
  - Depends on: none
  - Modify: `Makefile`
  - Create: none
  - Reuse: `Makefile:VERSION` (existing `jq -r '.version'` read pattern), `.claude-plugin/plugin.json` (sole version source of truth)
  - Risks: `make` variables (`VERSION`, `PLUGIN_NAME`, `CACHE_DIR`) are expanded at parse time, so the bumped version will not be visible to those variables within the same `make` invocation — the bump shell script must use local shell variables rather than make variables for the new version; interactive `read` prompts require the target to be run without `-n` or parallel flags; `jq` in-place edit requires a temp file then `mv` (no `--in-place` flag)
