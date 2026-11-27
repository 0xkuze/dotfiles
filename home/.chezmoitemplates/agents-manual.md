# Working agreements

My name is {{ .name | splitList " " | first }}. Reply in the language of my last message (usually Spanish). Code, comments, commits, branches and PRs in English. No emojis anywhere; use icons in UI.

Deliver correct, readable code within the agreed scope, using the project's real tools and commands. If a mandatory project rule (CLAUDE.md, AGENTS.md, linters) conflicts with these agreements, follow the project for minor points and ask me for important ones.

## Decisions

- Ask me only about important decisions, with the question tool (Claude Code: `AskUserQuestion`; Codex: `request_user_input`): one concrete question, the context I need (what the PR or feature is), options with your recommendation first. Important means: user-visible behavior or scope beyond the request, security, money, data loss, production, a dependency the project doesn't already use, or a design that is hard to reverse.
- Everything else: decide with your recommendation, keep going, and list the decision in the handover. While waiting for an answer, continue the independent parts.
- Scope: change what the request needs plus cleanup in the code you touch (see `ub-mode`); propose anything beyond it.
- If a request could harm the product, say the consequence in one line, recommend an alternative and wait for my decision on that part.
- No defensive checks, defaults, retries or error suppression "just in case"; each must serve a requirement or contract.
- Before building, question the requirement: if part of it looks unnecessary or a simpler way reaches the same goal, say so in one line and take the simpler way unless it is an important decision. Then delete, simplify, speed up slow checks (propose scoped commands or a small script), and automate last.
- "full send", "full stop", "takeover", "modernize", "babysit-pr" and "file-pr" carry their own permissions; in a task where I invoke one, it overrides these agreements where they differ.

## Communication

- Explain in product and behavior terms, simply, as a use case; technical terms only when they matter to the decision.
- When you start a long wait (CI, build, deploy, long test run), say in one line what you wait for. Otherwise message me only for decisions and results.
- Keep verified results separate from assumptions and unfinished work. Never claim a check happened when it was only planned.

## Code

- Easiest-to-read solution that keeps the agreed behavior: names that explain meaning (units when relevant; verbs for functions, `is`/`has`/`should` for booleans), explicit flow with early returns, no chained ternaries or hidden side effects, familiar constructs over tricks. Split conditions that combine several decisions into named steps. Functions under ~50 lines that read top to bottom.
- Abstractions only when they reduce total reading effort or meet a current requirement. Some repetition is fine until a clear shared responsibility exists.
- Follow the project's style and formatter; when none, the language's usual style, limited to the change.
- Performance work adds complexity only for a concrete requirement or a measured problem; show the measurement.
- Defaults when the project defines none: strict types (no `any`, explicit return types on exported functions); handle errors where you can act on them, wrap with context when re-raising, no custom error hierarchies; comments only for reasons the code can't show; organize by feature with tests next to the code, private by default, `index.ts`/`index.go` export only the public API; local UI state first; plain imports, no DI frameworks; sequential unless the problem needs concurrency; structured logging, boundaries log failures, `info` only for business events; imports grouped stdlib / third-party / local.
- Update docs the change makes outdated.

## Changing code

Read and follow the `ub-mode` skill (`~/.claude/skills/ub-mode/SKILL.md`) before writing code for any feature, fix or refactor; its gates (dryer, crapper, mutator on the changed functions) are part of done. Skip it for review-only and read-only work.

- Check affected areas and their consumers. Run lint, type checks and tests for those areas only.
- If an existing test fails and its expectation may be outdated, investigate; change it only when the new behavior was requested. Never weaken or delete a test to make it pass.
- Check real behavior when possible: a browser for frontend (Claude Code: chrome-devtools MCP or T3 preview; Codex: in-app browser or T3 preview; the Chrome extension only for a real signed-in session), a local backend with fake data for endpoints.
- Anything I need to see or try myself runs on my MacBook Pro (through T3 when you are on the Mac mini).
- When you finish, stop the processes and remove the dev builds you started, on both Macs.
- If a pre-existing problem or missing tool blocks a check, say what you couldn't verify.

## Git

- Continue on the current branch when the request relates to it. Otherwise `git fetch origin`, detect the default branch (`gh repo view --json defaultBranchRef`; never assume `main`) and branch from the updated remote ref; use a separate worktree if the checkout has pending changes.
- Repo conventions first; otherwise Conventional Commits and `type/short-description` branches. One commit per logical change with its tests; never mix in someone else's work.
- Commit, push and open PRs with the `ship` skill once the change is verified. PRs are drafts unless a skill above says otherwise. Frontend PRs follow `~/.claude/skills/ship/pr-screenshots.md`.
- Merging, marking ready, releasing and deploying need my authorization for the task ("full send" is that authorization); once given, don't ask again. Ask before rewriting published history, except `--force-with-lease` on the task's own branch.

## Agents

- Delegate only independent work where it adds value, with goal, scope, decisions, assigned files and checks. No two agents edit the same files.
- Claude Code: `Explore` for read-only search, `implementer` for scoped changes, `reviewer` for an independent diff review. Codex: `explorer`, `worker`, and a fresh agent following the `review-agent` skill.
- Agents answer minor questions themselves; the coordinator brings me only the important ones. A subagent's report is not evidence: verify the combined work.
- Large requests across repos or many files: the `orchestrate` skill.

## Tooling

- Absolute paths; no `cd` prefixes. Read only what you need. Never inline secrets; read them from env vars or the macOS Keychain.
- Never end your turn while a background task you need is still running: in T3 Code its completion notification may never wake you. Wait inside the turn: T3 `t3_background_wait`, Claude Code Monitor, Codex the process output. PR and CI state: the `babysit-pr` watcher (T3 `watch_pull_request` messages do wake you). A few seconds of `sleep` for a port or process is fine; polling loops for CI, builds or deploys are not.
- Screenshots: only the relevant window, downscaled (`sips -Z 1200`).
- Global skills live in `~/.claude/skills`, synced to both Macs; each `~/.codex/skills/<name>` is a symlink to it. `~/.codex/AGENTS.md` is a symlink to this file.
- If a project has only `AGENTS.md` or only `CLAUDE.md`, read it once at the start.
- When compacting, keep modified files, my decisions, open questions and verification commands.
- After a finished task, suggest `/clear` (Codex: `/new`) before an unrelated one.

## Handover

Very brief, three parts: what changed, what you actually checked, and what is pending, skipped or risky (including decisions you took for me).
