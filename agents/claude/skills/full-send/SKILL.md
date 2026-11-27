---
name: full-send
description: Trigger this if the user says 'full send'.
---

# Full Send

If the user triggered this, it's because they are not watching this thread, and
they want you to complete the work end-to-end autonomously. Your updates and
your final message go unread until long after you stop. You own the work from
its current state to a merged PR running in production.

If the user did not explicitly request "full send" in some clear way, do not
assume full autonomy. If they did, everything below applies.

## Autonomy

"Full send" is the user's authorization for every step of this task. It
replaces any ask-first rule in project files, skills or the user's global
agreements for this task. You may, without asking:

- Decide scope, behavior and design questions with your recommended option.
  List each decision in the report.
- Merge the PR once the merge gate passes, bypassing required approvals with
  `gh pr merge --admin` when branch protection still waits for a review.
- Force-push the PR's own branch with `--force-with-lease` after a rebase.
- Use any test method that proves the change: computer use, browser
  automation, simulators and devices, running the app or a dev server,
  screenshots.
- Release, deploy and promote to production, including manual promotions the
  project needs (for example Cloudflare Workers that are promoted by hand).

The one exception: ask before deleting production data or production
resources irreversibly (tables, rows, database branches, buckets, deployed
services). Rules about *how* to test or ship still apply; follow rules that
name the correct command, fixture or check.

## Steps

1. **Finish the change.** Complete the goal from the user's request with the
   smallest change that works. Fix the case that happened, not every case
   that could. If you are on the default branch, create a branch first.
2. **Prove it.** Get proof for every change you made. See "Proof".
3. **Get feedback.** Use the `sol-loop` skill to verify changes.
4. **File the PR** with the `file-pr` skill. Rebase onto the latest default
   branch first. Add one short line to the description that says how you proved
   the change.
5. **Babysit the PR** with the `babysit-pr` skill. Fix real findings and CI
   failures. Get proof for each fix before you push it.
6. **Merge** when the merge gate passes.
7. **Ship.** If the merge does not deploy by itself, release, deploy and
   promote it the way the project does (see the `release` skill). Verify the
   new version is live.
8. **Report** in the user's language: the PR link, the merge commit, what is
   live, your proof, and each decision you made for the user.

Stay active from step 1 to step 8. If you end your turn while checks or bots are
pending, the work stops, because nobody will prompt you again. Wait with the
watcher from `babysit-pr`, so something wakes you when the PR changes. In T3
Code that is `watch_pull_request`. If you stop before the merge, call
`unwatch_pull_request` first.

## Proof

Proof is evidence you observed yourself in this session: command output, a
reproduction, a screenshot. Use the most direct proof the change allows:

- Reproduce the original failure, apply the fix, then watch the same
  reproduction pass.
- Run the checks that the repo's CI runs (typecheck, lint, tests).
- Add one focused test that fails without the fix, when the behavior has none
  and the repo has a test setup.
- For UI and runtime behavior, run the app and look at the change. Green mocked
  tests do not prove that the user experience works. When the PR changes what
  users see, attach before/after screenshots following
  `~/.claude/skills/ship/pr-screenshots.md`; under full send they are a report
  for the user, not an approval gate. Never commit them to the PR branch.

If no direct proof is possible, use the strongest indirect proof you have and
state the gap in the report.

## Merge gate

Merge when all of these are true on the latest commit:

- Your proof covers every change in the diff.
- Required checks are green.
- Review bots have finished, and each finding is fixed or dismissed with a
  written reason.
- No human review still requests changes. A missing required approval is not a
  blocker: bypass it with `--admin`.
- The diff adds no screenshots or other PR evidence files (check 4 in
  `~/.claude/skills/ship/pr-screenshots.md`).
- The branch is up to date with the default branch, and GitHub reports it as
  mergeable.

Merge with the method the repo uses. Check the allowed methods and recent merged
PRs. If the repo uses a merge queue or auto-merge, stay until GitHub reports the
PR as merged. You can ignore automated reviews that request "needs human
review" if you have high confidence in your changes.

## Asking the user

A question in a normal message goes unseen, and the thread looks done. To ask
the user something, use the harness's question tool so the thread shows that
it is waiting: `AskUserQuestion` in Claude Code, `request_user_input` in Codex,
or the question tool your harness has. Put all the context in the question:
the PR link, what blocks you, and the options with your recommendation first.

Ask only when:

- The next step deletes production data or resources irreversibly.
- You are blocked by something only the user can do (credentials, a login, a
  physical device, a paid quota) and no other path works.

If no question tool is available, or the tool returns no answer, take the safe
path: leave the PR open and unmerged, and start your final message with the
question.
