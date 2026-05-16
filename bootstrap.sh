#!/usr/bin/env bash
# bootstrap.sh — one-shot installer for a fresh Mac.
# Idempotent: safe to re-run after editing the Brewfile or dotfiles.
#
#   ./bootstrap.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()  { printf '\033[1;34m▶ %s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m✓ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m! %s\033[0m\n' "$*"; }

# 1. Sanity check ───────────────────────────────────────────────────
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This installer targets macOS only." >&2
  exit 1
fi

# 2. Xcode Command Line Tools ───────────────────────────────────────
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (a GUI prompt will appear)…"
  xcode-select --install || true
  warn "Re-run this script once the Xcode tools install completes."
  exit 0
fi
ok "Xcode Command Line Tools present."

# 3. Homebrew ───────────────────────────────────────────────────────
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew…"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add brew to this shell session (Apple Silicon first, then Intel)
if   [[ -x /opt/homebrew/bin/brew ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew    ]]; then eval "$(/usr/local/bin/brew shellenv)"
fi
ok "Homebrew ready ($(brew --version | head -1))."

# 4. Packages ───────────────────────────────────────────────────────
log "Installing packages from Brewfile…"
brew bundle --file="${REPO_ROOT}/Brewfile"
ok "Packages installed / up to date."

# 5. Dotfiles via chezmoi ───────────────────────────────────────────
log "Applying dotfiles with chezmoi…"
chezmoi init --source "${REPO_ROOT}" --apply
ok "Dotfiles applied to \$HOME."

# 6. Language runtimes via mise ─────────────────────────────────────
# Reads ~/.config/mise/config.toml (just written by chezmoi above).
log "Installing language runtimes via mise…"
mise install
ok "Languages installed (node, python, go, rust, java 17 + 11)."

# 7. Hints ──────────────────────────────────────────────────────────
if [[ "${SHELL:-}" != *"zsh"* ]]; then
  warn "Login shell isn't zsh. Run: chsh -s /bin/zsh"
fi

ok "Done. Open a new terminal window to load the fresh shell."
