---
name: orchestrate
description: Coordinate a large independent request (a feature across several repos or many files) by splitting it into scoped phases, running implementer agents in worktrees from one pinned base revision, reviewing and integrating into a single delivery branch and one draft PR. Use when a request is too big for one focused session or benefits from parallel work.
---

# Orchestrate

You are the coordinator. Delegate only when it adds value; a small or tightly coupled change is faster done directly.

## 1. Plan (before any code)
- Ask the user only the important behavior or scope doubts, with the question tool; decide the rest with your recommendation. Independent investigation can run meanwhile (`Explore` agents; Codex: `explorer`).
- Split into phases that an agent can finish in ~100–150 turns (e.g. schema → endpoints → UI). Each phase has its own files/areas; no two agents edit the same files. Order phases with dependencies sequentially.
- Show the user the concrete plan (phases, repos, what each delivers, checks) and wait for approval.

## 2. Set up
Per repo: `git fetch origin`, detect the default branch (`gh repo view --json defaultBranchRef`), pin its current revision (`git rev-parse origin/<default>`) and record it. Create the delivery branch and every phase worktree from that same SHA, even if the remote advances. Never start from another request's branch.

## 3. Delegate
Launch `implementer` agents (background; Codex: `worker`) with a brief containing:
- Goal and the agreed behavior / decisions.
- Repo, worktree path and branch; assigned files/areas and what is out of scope.
- Checks to run (exact commands for affected areas).
- Handback format: Changed / Checked / Pending.
Answer agents' minor questions yourself; collect only the important ones and ask the user in one question-tool call.

## 4. Integrate and verify
- Read each handback; a report is not evidence. Merge phase branches into the delivery branch, resolving conflicts yourself only when both behaviors are preserved — otherwise ask.
- Run the affected checks on the combined result, plus real behavior when possible (local backend with fake data, browser for UI).
- Run the `reviewer` agent (Codex: a fresh agent following the `review-agent` skill) on the full diff against the plan. Fix in-scope blockers.

## 5. Deliver
- Push the delivery branch and open ONE draft PR per repo (use the `ship` skill steps). Do not merge or deploy.
- Remove auxiliary worktrees once integrated and verified (`git worktree remove`, never `--force`); keep their branches.
- Handover: what changed, what you actually checked, what is pending — then suggest `/clear` (Codex: `/new`).
