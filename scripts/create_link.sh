#!/bin/bash
# プロジェクトルートの取得
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

rm -rf ~/.config/fish
ln -sFiw  "$PROJECT_ROOT/fish" ~/.config/fish

rm -rf ~/.config/wezterm
ln -sFiw "$PROJECT_ROOT/wezterm" ~/.config/wezterm

rm -rf ~/.config/ghostty
ln -sFiw "$PROJECT_ROOT/ghostty" ~/.config/ghostty

rm -rf ~/.vim
ln -sFiw "$PROJECT_ROOT/vim" ~/.vim

rm -rf ~/.config/starship.toml
ln -sFiw "$PROJECT_ROOT/starship.toml" ~/.config/starship.toml

rm -rf ~/.config/git
ln -sFiw "$PROJECT_ROOT/git" ~/.config/git