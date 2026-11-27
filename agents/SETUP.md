# AI coding agent setup (Claude Code + Codex + T3 Code)

This file is written for an AI agent. Give it to your agent and ask it to replicate the setup on your Mac. Everything below is what one developer uses every day: global instructions, skills, subagents, plugins, MCP servers, quality-gate tools, and T3 Code as the main interface.

## For the agent doing the install

- Target: macOS on Apple Silicon, zsh. Work step by step and check each step before the next.
- Ask the human once, at the start: their first name, their GitHub username, which agents they use (Claude Code, Codex, or both), and whether they work on two Macs. Skip the parts they don't need.
- Every file copied from this repo uses the original owner's paths. After copying, replace `/Users/cristian` with the human's `$HOME` in those files.
- Never write secrets into files. API keys go to the macOS Keychain or to environment variables the human sets.
- Don't overwrite an existing `~/.claude/CLAUDE.md`, `settings.json` or `~/.codex/config.toml` without showing the human the diff first. Merge keys instead of replacing files.
- When done, run the checklist at the end and report what passed and what you skipped.

Source repo for the files referenced here: <https://github.com/0xkuze/dotfiles> (folder `agents/`, plus the shared instructions template in `home/.chezmoitemplates/agents-manual.md`).

```sh
git clone https://github.com/0xkuze/dotfiles.git ~/Documents/dotfiles
```

## 1. Base tools

```sh
# Homebrew: https://brew.sh
brew install git gh mise uv ripgrep jq
brew install --cask ghostty           # terminal (optional)

# Language runtimes through mise
mise use -g node@latest bun@latest pnpm@latest go@latest
# Python >= 3.11 must be what `python3` resolves to (the quality-gate tools need it)
mise use -g python@latest

gh auth login
```

Git settings the workflow relies on (`~/.gitconfig`):

```sh
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global push.default current
git config --global push.autoSetupRemote true
git config --global merge.conflictStyle zdiff3
```

Shell: agents expect plain `ls`, `cat` and `tree`. If the human aliases them (eza, bat), wrap the aliases so they are skipped inside agent shells:

```sh
if [[ -z $CLAUDECODE ]]; then
  alias ls='eza --group-directories-first'
  alias cat='bat --paging=never'
fi
```

The full shell setup (zshrc, starship, Ghostty, Brewfile) is in the same repo and is optional: `./bootstrap.sh` from the repo root installs it with chezmoi.

## 2. The agents

| Tool | Install | Notes |
|---|---|---|
| Claude Code | `curl -fsSL https://claude.ai/install.sh \| bash`, then `claude auth login` | Main agent. Model: Opus at effort `xhigh`; subagents run on Sonnet. |
| Codex CLI | `npm i -g @openai/codex` (or the ChatGPT desktop app, which bundles it), then `codex login` | Second agent, same instructions and skills. |
| T3 Code | `brew install --cask t3-code@nightly` (stable: `t3-code`) — <https://t3.codes>, <https://github.com/pingdotgg/t3code> | The interface used to run both agents. See section 9. |

## 3. Global instructions (one file for every agent)

The owner keeps one global instructions file and points every agent at it.

1. Copy `home/.chezmoitemplates/agents-manual.md` from the repo to `~/.claude/CLAUDE.md`.
2. Replace the template line `My name is {{ .name | splitList " " | first }}.` with `My name is <first name>.`.
3. Link it for Codex: `ln -sf ~/.claude/CLAUDE.md ~/.codex/AGENTS.md`.
4. Read the file with the human and adapt three things:
   - The language line (the owner writes in Spanish; code and PRs stay in English).
   - The "MacBook Pro / Mac mini" lines: with one Mac, change them to "runs on my Mac" and drop the "both Macs" parts.
   - The T3 Code lines: keep them only if the human uses T3 Code.

What the instructions enforce, in short: ask only for important decisions (with the question tool, recommendation first); smallest readable change; no defensive code "just in case"; the `ub-mode` skill and its quality gates are part of "done" for any code change; verify real behavior (browser for frontend, local backend for endpoints); commit and open draft PRs with the `ship` skill; merging, releasing and deploying need explicit authorization; short handover in three parts (changed, checked, pending).

With chezmoi instead: `chezmoi init --apply --source ~/Documents/dotfiles` renders the name and writes the file for Claude, Codex, pi and opencode, but it also applies the rest of the dotfiles (zshrc, gitconfig, Ghostty, mise).

## 4. Skills

Skills live in `~/.claude/skills/<name>/SKILL.md`. Codex reads the same folders through symlinks (step 4.6).

### 4.1 Own and modified skills (copy from this repo)

```sh
cp -R ~/Documents/dotfiles/agents/claude/skills/* ~/.claude/skills/
grep -rl '/Users/cristian' ~/.claude/skills | xargs sed -i '' "s#/Users/cristian#$HOME#g"
chmod +x ~/.claude/skills/babysit-pr/scripts/pr-wait
```

| Skill | Origin | What it does |
|---|---|---|
| `ub-mode` | Modified from <https://github.com/unclebob/ub-mode> | How to write any code change: smallest change, minimal tests, then the dryer/crapper/mutator gates on changed functions (needs section 6). |
| `ship` (+ `pr-screenshots.md`) | Own | Commit, push, open or update a draft PR with description, labels and assignee; screenshots for frontend PRs on a `pr-evidence` branch. |
| `cleanup` | Own | Remove leftovers after merged PRs: worktrees, merged branches, preview database branches and deployments. |
| `db-diagnose` | Own | Read-only Postgres diagnosis (slow queries, EXPLAIN ANALYZE, indexes, bloat). |
| `dev-up` | Own | Start a project's services locally in the background and check each responds. |
| `orchestrate` | Own | Split a large request into phases run by `implementer` agents in worktrees, review, integrate into one draft PR. |
| `release` | Own | Version bump, build, publish and verify a release. |
| `babysit-pr` (+ `scripts/pr-wait`) | Modified from <https://github.com/t3dotgg/tstack> | Watch a PR through CI and review; uses T3's `watch_pull_request` or the `pr-wait` script. |
| `file-pr`, `full-send`, `full-stop`, `sol-loop` | Modified from <https://github.com/t3dotgg/tstack> | Trigger words. "full send": prove, file, babysit and merge unattended. "full stop": same but stop before merge. "sol loop": review loop with OpenAI's model. |

### 4.2 Unmodified third-party skills

```sh
# tstack: only these three are used unmodified (the rest come from 4.1; "council" is not used)
git clone https://github.com/t3dotgg/tstack /tmp/tstack
cp -R /tmp/tstack/skills/{leaving-pr-comments,modernize,takeover} ~/.claude/skills/

# untangle-codebase — https://github.com/caldoai/skills
npx skills add caldoai/skills --skill untangle-codebase -g -a claude-code

# Vue / Nuxt / Vitest — https://github.com/onmax/nuxt-skills
for skill in nuxt vue vitest; do
  npx skills add onmax/nuxt-skills --skill "$skill" -g -a claude-code
done
```

Cloudflare skills — <https://github.com/cloudflare/skills>. Install all of them except `artifacts` and `flagship`: agents-sdk, basin, cf-cli, cloudflare, cloudflare-app-bootstrap, cloudflare-email-service, cloudflare-one, cloudflare-one-migrations, durable-objects, frameworks-on-cloudflare, gateway-workers, k2, nextjs-on-cloudflare, sandbox-migrate-to-next, sandbox-next, sandbox-stable, turnstile-spin, web-perf, workers-best-practices, workers-development, workers-profiling, wrangler. Either `npx skills add cloudflare/skills -g -a claude-code` and delete the two, or the plugin (`/plugin marketplace add cloudflare/skills` in Claude Code, `codex plugin marketplace add cloudflare/skills` in Codex). Skip them if the human doesn't use Cloudflare.

Reverse engineering (optional) — <https://github.com/morluto/rea>: `npx rea-agents setup` registers the `rea` MCP server and installs the `reverse-engineer-anything` skill.

### 4.3 Built in, nothing to install

- Claude Code built-ins: `code-review`, `simplify`, `security-review`, `init`, `loop`, `schedule`, and others.
- Skills synced from the claude.ai account (docx, pdf, pptx, xlsx, skill-creator, deep-research, …) appear on their own after login.

### 4.4 Codex: share the same skills

```sh
mkdir -p ~/.codex/skills
for dir in ~/.claude/skills/*/; do
  name=$(basename "$dir")
  ln -sfn "$HOME/.claude/skills/$name" "$HOME/.codex/skills/$name"
done
```

## 5. Subagents (Claude Code)

```sh
mkdir -p ~/.claude/agents
cp ~/Documents/dotfiles/agents/claude/agents/*.md ~/.claude/agents/
```

| Agent | Model / effort | Use |
|---|---|---|
| `Explore` | Sonnet, medium | Read-only search; returns conclusions with `path:line`, no file dumps. |
| `general-purpose` | Sonnet, medium | Delegated research or multi-step tasks; leaves user decisions as open questions. |
| `implementer` | Sonnet, high | One scoped change in an assigned repo/worktree, follows `ub-mode`, commits locally, never pushes. |
| `reviewer` | Opus, high | Independent read-only review of a diff against its requirements; findings with failure scenarios. |

Codex has no agent files; the instructions name the Codex equivalents (`explorer`, `worker`, a fresh review agent).

## 6. Quality-gate tools (used by `ub-mode`)

Forks of Uncle Bob's tools with fixes for JS/TS, Vue, Bun, Vitest, Jest, pnpm and Go projects (upstream gave silent false results there). Clone them exactly here, because `ub-mode` calls these paths:

```sh
mkdir -p ~/Documents/tools
git clone https://github.com/0xkuze/crapper ~/Documents/tools/crapper   # CRAP score: complexity x missing coverage
git clone https://github.com/0xkuze/dryer   ~/Documents/tools/dryer     # duplicated code finder
git clone https://github.com/0xkuze/mutator ~/Documents/tools/mutator   # mutation testing
```

Each tool creates its own `.venv` on first run (needs `python3` >= 3.11). Check: `~/Documents/tools/dryer/dryer --help`, and the same for `crapper` and `mutator`. Upstream: <https://github.com/unclebob/crapper>, <https://github.com/unclebob/dryer>, <https://github.com/unclebob/mutator>.

## 7. Plugins

Ponytail ("lazy senior developer": smallest complete change) — <https://github.com/DietrichGebert/ponytail>, in both agents:

```sh
# Claude Code
claude plugin marketplace add DietrichGebert/ponytail
claude plugin install ponytail@ponytail

# Codex
codex plugin marketplace add DietrichGebert/ponytail
codex plugin add ponytail@ponytail
```

Plugin options used in Claude Code: `ledger: false`, `sendNames: false` (see settings below).

## 8. Configuration files

### 8.1 Claude Code — `~/.claude/settings.json`

Merge these keys; skip any key the installed version rejects.

```json
{
  "env": {
    "CLAUDE_CODE_SUBAGENT_MODEL": "claude-sonnet-5-5",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50"
  },
  "attribution": { "commit": "", "pr": "", "sessionUrl": false },
  "permissions": {
    "ask": ["Bash(git push --force *)", "Bash(git push -f *)"],
    "defaultMode": "auto",
    "additionalDirectories": ["~/Documents/<main projects folder>"]
  },
  "worktree": { "baseRef": "fresh" },
  "enabledPlugins": { "ponytail@ponytail": true },
  "extraKnownMarketplaces": {
    "ponytail": { "source": { "source": "github", "repo": "DietrichGebert/ponytail" } }
  },
  "pluginConfigs": {
    "ponytail@ponytail": { "options": { "ledger": false, "sendNames": false } }
  },
  "modelSettings": { "claude-opus-5-5": { "effortLevel": "xhigh" } },
  "outputStyle": "Concise",
  "promptSuggestionEnabled": false,
  "enableArtifact": false,
  "workflowKeywordTriggerEnabled": false,
  "autoCompactEnabled": true,
  "autoContinueAtUsageLimit": true,
  "fileCheckpointingEnabled": true,
  "feedbackDrafts": "notify",
  "theme": "auto"
}
```

`~/.claude/settings.local.json` (per machine): `{"spinnerTipsEnabled": false, "prefersReducedMotion": true}`.

Why: no AI attribution in commits/PRs; auto permission mode but force pushes always ask; fresh worktrees from the remote; subagents on a cheaper model; compaction at 50% of context.

### 8.2 MCP servers (Claude Code, user scope)

```sh
# Chrome DevTools: lets the agent check frontend changes in a real browser.
# The owner points it at Helium (https://helium.computer); any Chromium works, or drop --executablePath.
claude mcp add --scope user chrome-devtools -- npx -y chrome-devtools-mcp@latest \
  --executablePath /Applications/Helium.app/Contents/MacOS/Helium --isolated

# Neon Postgres (only if the human uses Neon). The key lives in the Keychain, never in a file.
cp ~/Documents/dotfiles/agents/claude/neon-headers.sh ~/.claude/neon-headers.sh && chmod 700 ~/.claude/neon-headers.sh
security add-generic-password -a "$USER" -s NEON_API_KEY -w   # prompts for the key
claude mcp add-json --scope user Neon "{\"type\":\"http\",\"url\":\"https://mcp.neon.tech/mcp\",\"headersHelper\":\"$HOME/.claude/neon-headers.sh\"}"
```

Account connectors (Slack, Linear, Google, …) are enabled on claude.ai and need no local setup. The owner also has MCP servers for their own products; those don't apply.

### 8.3 Codex — `~/.codex/config.toml`

Merge these keys (model names change often: use the newest top model available):

```toml
model = "<newest top model>"
model_reasoning_effort = "xhigh"
model_verbosity = "low"
personality = "pragmatic"
approval_policy = "never"
sandbox_mode = "danger-full-access"
web_search = "live"

[agents]
default_subagent_model = "<cheaper model>"
default_subagent_reasoning_effort = "medium"
max_concurrent_threads_per_session = 2

[features]
memories = false

[memories]
generate_memories = false
use_memories = false

[mcp_servers.linear]
url = "https://mcp.linear.app/mcp"
bearer_token_env_var = "LINEAR_API_KEY"   # only if the human uses Linear
```

`approval_policy = "never"` with `danger-full-access` means Codex runs commands without asking. Confirm the human wants that; the safer choice is `approval_policy = "on-request"` with `sandbox_mode = "workspace-write"`.

## 9. T3 Code: how it is used

T3 Code is a desktop app that runs Claude Code and Codex threads side by side, each thread in its own git worktree, with a built-in browser preview, diff view, terminal and PR tracking.

Way of working:

- One thread per task, in a **new worktree** (default thread mode). Branches are prefixed with the GitHub username and follow Conventional Commits; PRs merge with squash.
- Default model: Claude (Opus, high effort). Codex is used as a second opinion and for review loops (`sol-loop`).
- Frontend changes are checked in **T3's browser preview** before shipping.
- Long waits (builds, test runs) use T3's `t3_background_wait` inside the turn. PRs are watched with `watch_pull_request` (T3 wakes the agent when CI or reviews change); the `babysit-pr` skill uses it. `ship` links each PR to its thread with `link_pull_request`.
- Trigger words typed in a thread: "full send" (finish and merge unattended), "full stop" (finish, stop before merge), "takeover", "modernize", "babysit-pr", "sol loop".
- Skills appear in the slash menu.
- Worktrees are cleaned 3 days after inactivity, and immediately on merge or thread delete.

Settings — `~/.t3/userdata/settings.json` (merge; T3 writes the rest itself):

```json
{
  "defaultModelSelection": { "instanceId": "claudeAgent", "model": "claude-opus-5-5" },
  "defaultThreadEnvMode": "worktree",
  "fastWorktreeCheckout": true,
  "defaultAutoPull": true,
  "branchNamePrefix": "<github username>",
  "sourceControlWritingStyle": { "mode": "conventional_commits" },
  "pullRequestMergeMethod": "squash",
  "storageCleanup": {
    "worktreeAfterDays": 3,
    "worktreeSettledAfterDays": 0,
    "worktreeOnMerge": true,
    "worktreeOnDelete": true,
    "browserArtifactsAfterDays": 15,
    "logsAfterDays": 8
  },
  "idleCompaction": "onReturn",
  "promptSuggestionsEnabled": true,
  "backgroundActivityProfile": "battery-saver",
  "automaticGitFetchInterval": 0,
  "defaultTheme": "arthur",
  "providerInstances": {
    "claudeAgent": { "driver": "claudeAgent", "enabled": true }
  }
}
```

Appearance and behavior — `~/.t3/userdata/client-settings.json` (merge):

```json
{
  "notificationMode": "notifications-and-sound",
  "chatWidth": "wide",
  "diffLayout": "split",
  "diffIgnoreWhitespace": true,
  "diffFilesCollapsed": true,
  "fontSizeInterface": 16,
  "fontSizePrompt": 16,
  "fontSizeCode": 16,
  "fontSizeTerminal": 16,
  "fontFamilyCode": "Paper Mono",
  "fontFamilyTerminal": "Paper Mono",
  "panelAnimationDurationMs": 0,
  "appearanceContrast": 120,
  "sendShortcut": "enter",
  "followUpBehavior": "steer",
  "showSkillsInSlashMenu": true,
  "toolCallVisibility": "showAll",
  "proactivePanelsEnabled": false,
  "sidebarProjectGroupingMode": "repository",
  "sidebarThreadSortOrder": "updated_at",
  "speechRemoveFillerWords": true,
  "confirmThreadArchive": false,
  "confirmThreadDelete": true
}
```

Theme: copy `agents/t3/themes/arthur.json` from the repo to `~/.t3/userdata/themes/`. If the "Paper Mono" font isn't installed, use any monospace font.

Optional: a second Claude account in T3 — add a provider instance `{"driver": "claudeAgent", "displayName": "Claude 2", "enabled": true, "config": {"homePath": "~/.claude"}}` and log it in with `CLAUDE_CONFIG_DIR=~/.claude claude auth login` (no trailing slash). It shares skills and settings but keeps its own login.

## 10. Optional: two Macs (laptop + always-on Mac mini)

The owner runs heavy agent work on a Mac mini and uses the laptop as a client. Only set this up if the human asks.

- Same macOS account name on both Macs, so absolute paths match.
- [Tailscale](https://tailscale.com) for the network; `ssh mini` as an SSH host alias. T3 on the laptop adds the mini as an SSH environment.
- [Syncthing](https://syncthing.net) (`brew install syncthing && brew services start syncthing`) syncs `~/Documents`, `~/.claude`, `~/.codex`, `~/.t3` and `~/.config`. Each folder needs a `.stignore` that excludes per-machine state: login tokens (`.credentials.json`, `.claude.json*`, `auth.json`), caches, SQLite databases, `history.jsonl`, sessions, telemetry, `node_modules` and build output. In `~/.t3` sync only `userdata/settings.json`, `client-settings.json`, `desktop-settings.json`, `keybindings.json` and `themes`; syncing T3's identity makes both Macs claim the same environment.
- Rules: never use the same checkout on both Macs at once (separate worktrees are fine); `git config --global gc.packRefs false` on both; don't sync `.git/FETCH_HEAD` or `refs/remotes`.
- Restart Syncthing daily (a LaunchAgent with `brew services restart syncthing`): on macOS its file watcher grows without limit under worktree churn.
- Register each project in T3 on both Macs with the same path.

## 11. Checklist

Run and report each result:

- [ ] `claude --version`, `codex --version`, `t3 --version`
- [ ] `~/.claude/CLAUDE.md` exists, has the human's name; `~/.codex/AGENTS.md` points to it
- [ ] `ls ~/.claude/skills` lists the skills from section 4; `ls -l ~/.codex/skills` shows the symlinks
- [ ] `grep -r '/Users/cristian' ~/.claude/skills ~/.claude/agents` prints nothing
- [ ] `ls ~/.claude/agents` lists Explore, general-purpose, implementer, reviewer
- [ ] `~/Documents/tools/{dryer/dryer,crapper/crapper,mutator/mutator} --help` all print help
- [ ] `claude mcp list` shows the servers from 8.2 as connected
- [ ] `claude plugin list` shows ponytail enabled; `codex plugin list` too
- [ ] T3 Code opens, shows Claude (and Codex) as providers, and a new thread starts in a worktree
