#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

command -v brew >/dev/null || {
  echo "Install Homebrew first"
  exit 1
}

brew install stow
brew bundle --file="$DOTFILES_DIR/Brewfile"

for dir in zsh bin git wezterm nvim mise; do
  if [ -d "$dir" ]; then
    echo "stow $dir"
    stow "$dir"
  fi
done

echo "dotfiles setup complete ✅"
