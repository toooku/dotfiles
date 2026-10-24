#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

# stow でホームにリンクするパッケージ
PACKAGES=(zsh git wezterm nvim mise emacs vscode claude)
# ディレクトリごとリンクされると、アプリが書き込むファイルまでリポジトリに入るパッケージ
NO_FOLDING=(vscode claude)

if [ "$(uname)" != "Darwin" ]; then
  echo "macOS 専用です"
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Command Line Tools をインストールします。完了後にもう一度実行してください"
  xcode-select --install
  exit 1
fi

if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew bundle --file="$DOTFILES_DIR/Brewfile"

# stow の邪魔になる既存ファイル(リポジトリ以外を指すリンクや通常ファイル)を退避する
backup_conflicts() {
  local pkg="$1" rel target src
  while IFS= read -r rel; do
    rel="${rel#./}"
    target="$HOME/$rel"
    src="$DOTFILES_DIR/$pkg/$rel"
    if [ -e "$target" ] || [ -L "$target" ]; then
      if [ "$(realpath "$target" 2>/dev/null)" != "$(realpath "$src")" ]; then
        echo "退避: $target -> $target.bak"
        mv "$target" "$target.bak"
      fi
    fi
  done < <(cd "$pkg" && find . \( -type f -o -type l \) ! -name .stow-local-ignore ! -name settings.base.json)
}

for pkg in "${PACKAGES[@]}"; do
  [ -d "$pkg" ] || continue
  backup_conflicts "$pkg"
  opt=""
  for p in "${NO_FOLDING[@]}"; do
    if [ "$p" = "$pkg" ]; then opt="--no-folding"; fi
  done
  echo "stow $opt $pkg"
  # shellcheck disable=SC2086 # opt は空のときに引数を渡さないためクォートしない
  stow -d "$DOTFILES_DIR" -t "$HOME" $opt "$pkg"
done

"$DOTFILES_DIR/scripts/claude-settings.sh"

echo "dotfiles のセットアップが完了しました"
