# dotfiles

dotfilesリポジトリです。GNU Stowを使用してシンボリックリンクで管理しています。

## 📋 概要

このリポジトリには以下の設定が含まれています：

- **zsh**: zshの設定ファイル（`.zshrc`）
- **git**: Gitの設定ファイル（`.gitconfig`）
- **wezterm**: WezTermの設定ファイル
- **nvim**: Neovimの設定ファイル
- **mise**: mise（asdfの代替）の設定
- **bin**: 各種ユーティリティスクリプト

## 🚀 セットアップ

### 前提条件

- macOS（Homebrewが必要）
- Git

### インストール手順

1. リポジトリをクローン：

```bash
git clone https://github.com/toooku/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. セットアップスクリプトを実行：

```bash
./bootstrap.sh
```

このスクリプトは以下を実行します：
- Homebrewのパッケージをインストール（`Brewfile`から）
- GNU Stowをインストール
- 各設定ディレクトリをStowでシンボリックリンク化

### 手動セットアップ

自動セットアップを使わない場合は、以下の手順で手動セットアップできます：

```bash
# Homebrewのパッケージをインストール
brew bundle

# 各設定をStowでリンク
stow zsh
stow git
stow wezterm
stow nvim
stow mise
stow bin
```

## 📁 ディレクトリ構造

```
dotfiles/
├── bootstrap.sh          # セットアップスクリプト
├── Brewfile              # Homebrewのパッケージリスト
├── zsh/                  # zsh設定
│   └── .zshrc
├── git/                  # Git設定
│   └── .gitconfig
├── wezterm/              # WezTerm設定
│   └── .config/wezterm/
├── nvim/                 # Neovim設定
│   └── .config/nvim/
├── mise/                 # mise設定
├── bin/                  # ユーティリティスクリプト
│   ├── brew.sh
│   ├── defaults.sh
│   └── ...
└── .github/              # CI/CD設定
    └── workflows/
```

## 🛠️ 管理方法

### 新しい設定を追加する場合

1. 新しいディレクトリを作成（例：`vim/`）
2. 設定ファイルを配置（例：`vim/.vimrc`）
3. Stowでリンク：

```bash
stow vim
```

4. `bootstrap.sh`のループにディレクトリ名を追加

### 設定を削除する場合

```bash
stow -D vim
```

### 設定を更新する場合

設定ファイルを編集後、Stowで再リンク：

```bash
stow -R vim
```

## 🔧 主要なツール

このリポジトリで管理している主要なツール：

- **Neovim**: エディタ
- **WezTerm**: ターミナルエミュレータ
- **mise**: ランタイムバージョン管理
- **zsh**: シェル
- **Homebrew**: パッケージマネージャー

## 🧪 CI/CD

GitHub Actionsで以下のチェックを実行しています：

- ShellCheck（シェルスクリプトのリント）
- Lua check（WezTerm/Nvim設定のリント）
- Stow dry-run（シンボリックリンクの検証）

## 📝 メンテナンス

### Homebrewパッケージの更新

```bash
# 現在のパッケージをBrewfileに記録
brew bundle dump --force

# パッケージを更新
brew update && brew upgrade
```

### 設定のバックアップ

既存の設定ファイルは`_backup/`ディレクトリに保存されます。
