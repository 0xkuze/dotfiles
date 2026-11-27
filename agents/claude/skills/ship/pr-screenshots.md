# PR screenshots

## When and what

- Required when the PR changes what users see. Changed UI: comparable before and after captures (same screen, state and window size). New UI: the new feature and its relevant visual states. Refactors, moves and changes with no visible effect need none.
- Use test data; never show credentials or private data. Embed the images in the PR description with clear labels; a text description never replaces them.
- If you cannot capture them, fix the access or environment first. If only the user can unblock it, say the concrete reason and ask.
- Merge: a PR with a visible UI change needs the user's explicit UI/UX approval after they saw the screenshots, unless the user said "full send" for the task. If the design changes after approval, get approval again.

## How

Screenshots are PR evidence, not project files. They never go into the PR branch, so they can never be merged into the default branch.

Store them on the repo's `pr-evidence` branch: an orphan branch with no project code that is never merged. If the repo or the user names another place, use that.

1. Capture only the relevant area, downscale (`sips -Z 1200`), and check that no credentials or private data are visible.
2. Add them in a temporary worktree, so the task's checkout is untouched:
   ```sh
   tmp=$(mktemp -d)
   if git -C <repo> fetch origin pr-evidence; then
     git -C <repo> worktree add -B pr-evidence "$tmp" origin/pr-evidence
   else
     git -C <repo> worktree add --orphan -b pr-evidence "$tmp"
   fi
   mkdir -p "$tmp/<pr-number>"   # or the branch name if the PR does not exist yet
   cp <files> "$tmp/<pr-number>/"
   git -C "$tmp" add . && git -C "$tmp" commit -m "docs: add screenshots for <repo>#<pr-number>"
   git -C "$tmp" push origin pr-evidence
   sha=$(git -C "$tmp" rev-parse HEAD)
   git -C <repo> worktree remove "$tmp"
   ```
   If the push is rejected (branch rules, permissions), stop and ask; never fall back to committing them on the PR branch.
3. Embed them in the PR description pinned to that commit, so later evidence commits cannot change them:
   `![Before: <state>](https://github.com/<owner>/<repo>/blob/<sha>/<pr-number>/<file>.png?raw=true)`
4. Before pushing the PR branch and again before any merge, confirm that the PR adds no evidence files:
   `git -C <repo> diff --name-only --diff-filter=A origin/<default>...HEAD | grep -iE '\.(png|jpe?g|gif|webp|mp4|mov)$'`
   Only app assets the change really needs (icons, images it uses) may appear. Anything else is evidence: move it to `pr-evidence` and remove it from the branch before merging.
