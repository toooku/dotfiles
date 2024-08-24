#!/bin/bash

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

# Dock に標準で入っている全てのアプリを消す、Finder とごみ箱は消えない
defaults write com.apple.dock persistent-apps -array

# 新しいウィンドウでデフォルトでホームフォルダを開く
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# ステータスバーを表示
defaults write com.apple.finder ShowStatusBar -bool true

# パスバーを表示
defaults write com.apple.finder ShowPathbar -bool true

# タブバーを表示
defaults write com.apple.finder ShowTabView -bool true

# ライブラリディレクトリを表示、デフォルトは非表示
chflags nohidden ~/Library

# 不可視ファイルを表示
defaults write com.apple.finder AppleShowAllFiles YES

# インデックスを再構築する前に新しい設定を読み込む
killall mds > /dev/null 2>&1
# メインディスクのインデックスを有効にする
sudo mdutil -i on / > /dev/null
# インデックスを最初から再構築
sudo mdutil -E / > /dev/null


# スリープまたはスクリーンセーバから復帰した際、パスワードをすぐに要求する
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# [システム環境]，[デスクトップとスクリーンセーバ] のchb[半透明メニューバー]
# -> "オフ" (半透明にしない)
defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false

# (無; ウィンドウが開閉時のアニメーション)
# -> false (アニメーションさせない)
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# (無; icloud 対応アプリでのファイル保存時のデフォルトを icloud にする)
# -> false (icloud をデフォルト保存先としない)
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# アニメーションを減らす
defaults write com.apple.universalaccess reduceMotion -bool true

# 透明度を減らす
defaults write com.apple.universalaccess reduceTransparency -bool true

# カラーフィルター（青黄色フィルタ）を有効にする
defaults write com.apple.universalaccess "CIColorFilterEnabled" -bool true
defaults write com.apple.universalaccess "CIColorFilterMode" -int 3

# トラックパッドの軌跡速度を最速にする
defaults write -g com.apple.trackpad.scaling -float 3.0

# マウスの軌跡速度を最速にする
defaults write -g com.apple.mouse.scaling -float 3.0



sudo reboot