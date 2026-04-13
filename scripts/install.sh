#!/bin/bash
set -euo pipefail

# ============================================================
# dotfiles installer with backup
# ============================================================

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# リンク先が実在するか確認
if [ ! -d "$PROJECT_ROOT/nvim" ]; then
  echo "ERROR: $PROJECT_ROOT はdotfilesリポジトリではなさそうです" >&2
  echo "dotfilesリポジトリ内で実行してください" >&2
  exit 1
fi

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# ------------------------------------------------------------
# リンク対象の定義: "リポジトリ内パス:リンク先パス"
# ------------------------------------------------------------
# NOTE: fish, starship, direnv, mise, zoxide は
# nix-darwin + home-manager で管理しているためここには含めない
LINKS=(
  "wezterm:$HOME/.config/wezterm"
  "ghostty:$HOME/.config/ghostty"
  "nvim:$HOME/.config/nvim"
  "git:$HOME/.config/git"
  "tmux:$HOME/.config/tmux"
  "vim:$HOME/.vim"
)

# ------------------------------------------------------------
# バックアップ & シンボリックリンク作成
# ------------------------------------------------------------
backup_and_link() {
  local src="$1"   # リポジトリ内の実体パス
  local dest="$2"  # リンクを張る先

  # すでに正しいシンボリックリンクなら何もしない（冪等性）
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "SKIP (already linked): $dest -> $src"
    return
  fi

  # 既存のファイル/ディレクトリがあればバックアップ
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mkdir -p "$BACKUP_DIR"
    # ディレクトリ構造を保持してバックアップ
    local backup_path="$BACKUP_DIR/${dest#$HOME/}"
    mkdir -p "$(dirname "$backup_path")"
    mv "$dest" "$backup_path"
    echo "BACKUP: $dest -> $backup_path"
  fi

  # 親ディレクトリがなければ作成
  mkdir -p "$(dirname "$dest")"

  ln -sf "$src" "$dest"
  echo "LINK:   $dest -> $src"
}

echo "=== dotfiles installer ==="
echo "Repository: $PROJECT_ROOT"
echo ""

for entry in "${LINKS[@]}"; do
  src="$PROJECT_ROOT/${entry%%:*}" # 末尾から:までを削除 fish:$HOME/.config/fish -> fish
  dest="${entry#*:}"               # 先頭から:までを削除 fish:$HOME/.config/fish -> $HOME/.config/fish

  if [ ! -e "$src" ]; then         # dotfilesリポジトリでまだ用意されていないがLINKSにある場合
    echo "WARN: $src が存在しません。スキップします" >&2
    continue
  fi

  backup_and_link "$src" "$dest"
done

echo ""
if [ -d "$BACKUP_DIR" ]; then
  echo "バックアップ先: $BACKUP_DIR"
  echo "問題があれば以下で復元できます:"
  echo "  cp -r $BACKUP_DIR/ $HOME/"
else
  echo "バックアップ対象はありませんでした（全てスキップ済み）"
fi
echo "=== done ==="
