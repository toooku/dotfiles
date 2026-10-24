# dotfiles

macOS 用の dotfiles です。設定ファイルは GNU Stow でホームディレクトリにリンクし、アプリと CLI は `Brewfile` で管理しています。

## 含まれるもの

| パッケージ | リンク先 | 内容 |
| --- | --- | --- |
| `zsh` | `~/.zshrc` | zsh の設定(zinit, pure, mise, zoxide など) |
| `git` | `~/.gitconfig` | Git の設定 |
| `wezterm` | `~/.config/wezterm/` | WezTerm の設定 |
| `nvim` | `~/.config/nvim/` | Neovim の設定(lazy.nvim) |
| `mise` | `~/.config/mise/` | Node / Ruby などのバージョン管理 |
| `emacs` | `~/.emacs.d/init.el` | Emacs の設定 |
| `vscode` | `~/Library/Application Support/Code/User/settings.json` | VS Code の設定 |
| `claude` | `~/.claude/rules/` | Claude Code のルール |

ほかに次のファイルがあります。

- `Brewfile`: Homebrew の formula / cask、App Store アプリ(mas)、VS Code 拡張、uv tool
- `claude/settings.base.json`: Claude Code の `~/.claude/settings.json` のうち共通部分
- `scripts/claude-settings.sh`: `~/.claude/settings.json` を生成するスクリプト
- `scripts/macos-defaults.sh`: Finder や Dock などの macOS 設定(最後に再起動する)

## セットアップ

```bash
git clone https://github.com/toooku/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` は次の順に実行します。何度実行しても同じ結果になります。

1. Command Line Tools と Homebrew がなければインストールする
2. `brew bundle` で `Brewfile` の内容をインストールする
3. 各パッケージを `stow` でリンクする。リンク先に別のファイルがあれば `.bak` を付けて退避する
4. `scripts/claude-settings.sh` で `~/.claude/settings.json` を生成する

App Store のアプリ(`mas` の行)は、先に App Store にサインインしておく必要があります。

既に手で入れたアプリを cask の管理に移すときは、`--adopt` を付けてインストールします。

```bash
brew install --cask --adopt chatgpt
```

## Claude Code の設定

このリポジトリは公開しているため、`~/.claude/settings.json` はリンクにせず、次の2つを合成して生成します。

- `claude/settings.base.json`: モデル、テーマ、MCP サーバー、プラグインなどの共通設定
- `~/.claude/settings.private.json`: Git 管理外。業務固有の `autoMode` や、プロジェクト固有の許可ルールを置く

`autoMode` はユーザー設定(`~/.claude/settings.json`)からしか読まれないため、プロジェクト側の設定には移せません。そのため private 側に置いています。

Claude Code が「常に許可」などで `settings.json` に追記した内容は、次にスクリプトを実行したときに private 側へ移されます。共通設定に入れたいものは、`claude/settings.base.json` に手で移してください。

```bash
scripts/claude-settings.sh
```

`~/.claude/rules/` はリンクで管理しているので、編集はそのままリポジトリに反映されます。

## 管理方法

### パッケージを追加する

1. `<名前>/` ディレクトリを作り、ホームからの相対パスで設定ファイルを置く(例: `tmux/.tmux.conf`)
2. `bootstrap.sh` の `PACKAGES` に名前を追加する。アプリがディレクトリ内に別のファイルを書き込む場合は `NO_FOLDING` にも追加する

### Brewfile を更新する

`brew bundle dump` は依存で入ったものまで書き出すので、差分を見て必要な行だけ `Brewfile` に足します。

```bash
brew bundle dump --force --file=/tmp/Brewfile
diff Brewfile /tmp/Brewfile
```

足りないものの確認とインストールは次のとおりです。

```bash
brew bundle check --verbose
brew bundle install
```

## CI

GitHub Actions で次を確認しています。

- シェルスクリプトの構文チェックと ShellCheck
- Lua ファイルの luacheck
- `scripts/claude-settings.sh` の合成結果
- 一時ディレクトリへの `stow` の dry-run
