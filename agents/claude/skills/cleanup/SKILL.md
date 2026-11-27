---
name: cleanup
description: Clean up leftovers after PRs are merged — stale git worktrees, merged local/remote branches, and preview resources (database branches, preview deployments) tied to closed PRs. Use when the user says "limpia", "elimina residuos", "limpia worktrees/branches", "no quede ningún residuo".
---

# Cleanup

Always do a **dry run first**: list everything that would be removed, grouped by repo/service, then ask for confirmation before deleting anything.

1. **Git** (each repo involved, via `git -C`):
   - `git fetch --prune`.
   - Worktrees: `git worktree list`; candidates are worktrees whose branch is merged or gone and that have no uncommitted changes. Never remove one with local changes or use `--force`.
   - Local branches merged into the default branch or whose upstream is `[gone]`. Remote branches only for merged PRs (`gh pr list --state merged`).
   - Never touch the default branch, `develop`, or the current branch.
2. **Preview resources** the project actually uses (check `AGENTS.md`, CI workflows, wrangler/vercel/neon config): e.g. Neon `preview/*` branches, Cloudflare/Vercel preview deployments, tied to closed or merged PRs. Never delete production or staging resources or the default database branch.
3. After confirmation, delete, re-list to verify, and reply in the user's language with what was removed and what was kept (and why).
