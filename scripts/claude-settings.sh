#!/usr/bin/env bash
# ~/.claude/settings.json を次の2つから合成する。
#   - claude/settings.base.json   : リポジトリで管理する共通設定
#   - ~/.claude/settings.private.json : Git 管理外の追加分(業務固有の autoMode や許可ルールなど)
#
# autoMode はユーザー設定にしか書けないため、社内情報は private 側に置く。
# Claude Code が「常に許可」などで settings.json に追記した許可ルールは、
# 再生成の前に private 側へ移すので消えない。
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BASE="$DOTFILES_DIR/claude/settings.base.json"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
TARGET="$CLAUDE_DIR/settings.json"
PRIVATE="$CLAUDE_DIR/settings.private.json"

command -v jq >/dev/null || {
  echo "jq が必要です" >&2
  exit 1
}

mkdir -p "$CLAUDE_DIR"

if [ -L "$TARGET" ]; then
  echo "$TARGET がシンボリックリンクです。通常ファイルに置き換えてから再実行してください" >&2
  exit 1
fi

[ -f "$PRIVATE" ] || echo '{}' >"$PRIVATE"

# 今の settings.json にあって、共通設定と private のどちらにもない差分を private に移す。
#   - 共通設定と値が違うトップレベルのキーは、今の値を private に入れる
#   - permissions.allow / deny / ask は、共通設定にない項目を private に足す
if [ -f "$TARGET" ]; then
  cp "$TARGET" "$TARGET.bak"
  tmp="$(mktemp)"
  jq -s '
    .[0] as $base | .[1] as $priv | .[2] as $cur
    | ($cur | del(.permissions) | to_entries
        | map(select(.value != $base[.key])) | from_entries) as $diff
    | ["allow", "deny", "ask"] as $kinds
    | (reduce $kinds[] as $k ({};
        (($cur.permissions[$k] // []) - ($base.permissions[$k] // [])) as $extra
        | if ($extra | length) > 0 then .[$k] = $extra else . end)) as $perm
    | ($priv * $diff)
    | reduce $kinds[] as $k (.;
        if $perm[$k] then
          .permissions[$k] = (((.permissions[$k] // []) + $perm[$k]) | unique)
        else . end)
  ' "$BASE" "$PRIVATE" "$TARGET" >"$tmp"
  mv "$tmp" "$PRIVATE"
fi

# 共通設定に private を重ねる。許可ルールの配列は上書きせず連結する。
tmp="$(mktemp)"
jq -s '
  .[0] as $base | .[1] as $priv
  | ($base * $priv)
  | reduce ("allow", "deny", "ask") as $k (.;
      if ($base.permissions[$k] or $priv.permissions[$k]) then
        .permissions[$k] = ((($base.permissions[$k] // []) + ($priv.permissions[$k] // [])) | unique)
      else . end)
' "$BASE" "$PRIVATE" >"$tmp"
mv "$tmp" "$TARGET"
chmod 600 "$PRIVATE"

echo "$TARGET を生成しました(private: $PRIVATE)"
