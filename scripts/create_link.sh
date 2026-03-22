#!/bin/bash
# プロジェクトルートの取得
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

unlink ~/.config/fish
ln -sFiw "$PROJECT_ROOT/fish" ~/.config/fish

unlink ~/.config/wezterm
ln -sFiw "$PROJECT_ROOT/wezterm" ~/.config/wezterm

unlink ~/.config/ghostty
ln -sFiw "$PROJECT_ROOT/ghostty" ~/.config/ghostty

unlink ~/.vim
ln -sFiw "$PROJECT_ROOT/vim" ~/.vim

unlink ~/.config/starship.toml
ln -sFiw "$PROJECT_ROOT/starship.toml" ~/.config/starship.toml

unlink ~/.config/git
ln -sFiw "$PROJECT_ROOT/git" ~/.config/git

unlink ~/.config/tmux
ln -sFiw "$PROJECT_ROOT/tmux" ~/.config/tmux

unlink ~/.config/nvim
ln -sFiw "$PROJECT_ROOT/nvim" ~/.config/nvim
