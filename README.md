# dotfiles

Personal macOS setup. One command on a fresh Mac brings the whole environment up:
Homebrew, modern CLI stack, terminal, shell, and dotfiles.

Managed with [chezmoi](https://chezmoi.io) (declarative, no symlinks).
Packages managed with [Homebrew](https://brew.sh) via a `Brewfile`.

---

## Quick start (fresh Mac)

```sh
git clone https://github.com/<you>/dotfiles.git ~/Documents/dotfiles
cd ~/Documents/dotfiles
./bootstrap.sh
```

`bootstrap.sh` is idempotent — re-run it anytime to sync new packages or dotfiles.

It will:

1. Install Xcode Command Line Tools (if missing)
2. Install Homebrew (if missing)
3. Install every package in `Brewfile` (CLI tools + GUI apps)
4. Run `chezmoi init --apply`, prompting once for your name + git email
5. Render templates and write dotfiles to `$HOME`
6. Run `mise install` to install language runtimes declared in
   `home/dot_config/mise/config.toml`

---

## Layout

```
.
├── README.md
├── bootstrap.sh             # entry point — fresh-Mac installer
├── Brewfile                 # everything brew installs
├── .chezmoiroot             # tells chezmoi the source root is `home/`
└── home/                    # chezmoi source — everything here ends up in $HOME
    ├── .chezmoi.toml.tmpl   # prompts on init (name, email)
    ├── .chezmoiignore       # patterns to skip when applying
    ├── dot_zshrc            # → ~/.zshrc
    ├── dot_zprofile         # → ~/.zprofile
    ├── dot_gitconfig.tmpl   # → ~/.gitconfig (templated)
    └── dot_config/          # → ~/.config/
        ├── starship.toml
        ├── ghostty/config
        ├── mise/config.toml # languages managed by mise
        └── git/ignore       # global gitignore
```

### Naming conventions (chezmoi)

| Source name              | Becomes              | Why                          |
|--------------------------|----------------------|------------------------------|
| `dot_zshrc`              | `~/.zshrc`           | `dot_` prefix → leading `.`  |
| `dot_gitconfig.tmpl`     | `~/.gitconfig`       | `.tmpl` → Go template        |
| `dot_config/starship.toml` | `~/.config/starship.toml` | nested directories work as-is |

Full reference: <https://www.chezmoi.io/reference/source-state-attributes/>

---

## What gets installed

### CLI (Homebrew formulae)
chezmoi, starship, eza, bat, fd, ripgrep, fzf, zoxide, atuin, jq, gh, lazygit,
neovim, tmux, mise.

### Apps (Homebrew casks)
- **Terminal & editors**: Ghostty, Zed, DataGrip
- **Browsers**: Google Chrome
- **Communication**: Discord
- **Productivity**: Raycast, AltTab, Shottr, Linear, Spotify
- **Dev infra**: OrbStack, Leapp, Cloudflare WARP
- **AI**: Claude desktop, Codex desktop, Wispr Flow, VibeProxy

### Languages (mise)
node @ latest · python @ latest · go @ latest · rust @ latest · java 17 + 11

The version `latest` resolves to whatever is current when `mise install` runs.
Re-pin or add tools by editing `home/dot_config/mise/config.toml`.

---

## Common tasks

### Add a Homebrew package
1. Append a line to `Brewfile` (`brew "tool-name"` or `cask "app-name"`).
2. Run `brew bundle --file=./Brewfile`.

### Add or change a language runtime
1. Edit `home/dot_config/mise/config.toml`.
2. `chezmoi apply` (or re-run `./bootstrap.sh`).
3. `mise install`.

### Use a specific Java version in a project
```sh
cd my-project
mise use java@11      # writes a local mise.toml in this project
```

### Update everything later
```sh
brew update && brew upgrade && brew bundle --file=./Brewfile
mise upgrade
chezmoi apply
```

### Add or change a dotfile
1. `chezmoi edit ~/.zshrc` — opens the source file in `$EDITOR`.
2. `chezmoi diff`        — preview what would change.
3. `chezmoi apply`       — write the change to `$HOME`.

### Add a brand-new dotfile to track
```sh
chezmoi add ~/.somefile          # imports into the source dir
# then commit the new file in this repo
```

### Per-machine overrides (untracked)
- `~/.zshrc.local` — sourced from `dot_zshrc` if it exists. Drop machine-specific
  exports, aliases, or work secrets there. Never committed.

### Re-prompt for name/email
```sh
chezmoi init --source ~/Documents/dotfiles
```

---

## How it stays simple

- **One installer** (`bootstrap.sh`) — five steps, plain bash, < 60 lines.
- **One package list** (`Brewfile`) — add a line, run `brew bundle`.
- **One dotfile manager** (`chezmoi`) — files in `home/` are the source of truth.
- **No magic** — every file is plain text, every alias is explicit, every tool
  integration is guarded by `command -v` so missing tools never break the shell.

---

## Extending

Want to add a new tool category (e.g. macOS defaults, VS Code settings, ssh
config)? Create the file in `home/` using the chezmoi naming convention and
commit it. No code changes needed elsewhere.

Want machine variants (work vs personal)? Add fields to
`home/.chezmoi.toml.tmpl` (e.g. `promptStringOnce . "profile" "work or personal"`)
and gate templates with `{{ if eq .profile "work" }}…{{ end }}`.
