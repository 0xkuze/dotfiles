---
name: ship
description: Commit, push and open or update a draft pull request with a clear English description, labels and the user as assignee. Use when the user says "commitea y pushea", "commit and push", "abre el PR", "ship it" or asks to leave PRs documented and assigned. Works across several repos in one call.
---

# Ship

For each repo touched in this task. Use `git -C <repo>`, never `cd`.

1. `git -C <repo> status --short` and `diff --stat`. Skip repos without changes. Include only this task's changes; never stage someone else's work, secrets, `.env*`, build output, recordings, screenshots or large binaries — stop and ask if any appear. Screenshots never go on the PR branch (see step 7).
2. Branch: stay on the current branch if it belongs to this task. If on the default branch, `git fetch origin`, detect the real default branch (`gh repo view --json defaultBranchRef`) and create `type/short-description` from the updated remote ref. Never push directly to the default branch unless the user explicitly said so.
3. Checks for the affected areas only (lint, type check, related tests). Fix what you caused; report the rest.
4. Review: run the `reviewer` agent (Codex: a fresh agent following the `review-agent` skill) on the diff against the task's requirements. Fix confirmed blockers that are within scope; list the rest as pending.
5. Commits: one per logical change, Conventional Commits in English, with its tests. Reorganize only unpushed commits. Never force push without asking.
6. `git push -u origin HEAD`.
7. PR: if `gh pr view --json url` finds one, update it with `gh pr edit`. Otherwise `gh pr create --draft --assignee @me` with:
   - English Conventional Commits title.
   - Short English body: **What** changed, **Why**, **Checked** (commands and results), **Deploy notes** only if relevant (migrations, env vars, deploy order).
   - Labels from `gh label list` only; follow the repo's PR template if it has one.
   - Screenshots (required for frontend PRs): follow [pr-screenshots.md](pr-screenshots.md). They live on the repo's `pr-evidence` branch, never in the PR branch.
   Never mark ready, merge or deploy unless the user authorized it for this task.
8. Link every PR with `link_pull_request` when the t3-code MCP is available.
9. Reply in the user's language, one line per repo: branch, commits, PR link — plus anything pending.
