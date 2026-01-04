function peco_select_history_order
    if test (count $argv) = 0
        set peco_flags --layout=top-down
    else
        set peco_flags --layout=bottom-up --query "$argv"
    end

    history | peco $peco_flags | read foo

    if [ $foo ]
        commandline $foo
    else
        commandline ''
    end
end

function history
    builtin history --show-time='%Y/%m/%d %H:%M:%S ' | sort
end

function peco_ghq
    set -l query (commandline)

    if test -n $query
        set peco_flags --query "$query"
    end

    ghq list --full-path | peco $peco_flags | read recent
    if [ $recent ]
        cd $recent
        commandline -r ''
        commandline -f repaint
    end
end

function fish_user_key_bindings
    bind \cr peco_select_history_order
    bind \co peco_ghq
end

# Apple Silicon brew を abrew として使う
function abrew
    if test -x /opt/homebrew/bin/brew
        /opt/homebrew/bin/brew $argv
    else
        echo "abrew: /opt/homebrew/bin/brew が見つかりません"
        return 1
    end
end

# Rosetta (Intel) brew を ibrew として使う
function ibrew
    if test -x /usr/local/bin/brew
        # Rosetta で実行するため arch -x86_64 を付ける
        arch -x86_64 /usr/local/bin/brew $argv
    else
        echo "ibrew: /usr/local/bin/brew が見つかりません"
        return 1
    end
end

# 便利補助: どちらが使えるか確認するためのエイリアス
alias which-abrew='command -v /opt/homebrew/bin/brew; and /opt/homebrew/bin/brew --prefix'
alias which-ibrew='command -v /usr/local/bin/brew; and arch -x86_64 /usr/local/bin/brew --prefix'

# aliases
alias v="nvim"
alias c="clear"
alias ll="ls -lFh"
alias la="ls -laFh"
alias ls="ls -Fh"

set -g fish_greeting ""

# Fish のシンタックスハイライトの色を設定
set -g fish_color_command green --bold
set -g fish_color_param white
set -g fish_color_option cyan
set -g fish_color_quote yellow
set -g fish_color_error red --bold
set -g fish_color_autosuggestion brblack
set -g fish_color_valid_path --underline
set -g fish_color_operator magenta
set -g fish_color_escape cyan
set -g fish_color_comment brblack

# 1) 最小のシステムPATHを最初に初期化（1回だけ）
set -gx PATH /usr/bin /bin /usr/sbin /sbin /opt/homebrew/bin /opt/homebrew/sbin /usr/local/bin

# 2) Voltaを最優先に追加（node/npm/yarnの優先度をVoltaに）
set -x VOLTA_HOME $HOME/.volta
fish_add_path -g $VOLTA_HOME/bin
set -x VOLTA_FEATURE_PNPM 1
set -x GOENV_ROOT $HOME/.goenv

# 3) 他ツールを順次追加（fish_add_pathで重複防止＆順序維持）
fish_add_path -g $HOME/go/bin # Go (GOPATH/bin)
fish_add_path -g $HOME/.lmstudio/bin # LM Studio
fish_add_path -g $HOME/.codeium/windsurf/bin # Windsurf
fish_add_path -g $HOME/.pixi/bin # pixi

# 4) direnvは最後（プロジェクトごとのPATH変更を尊重）
if command -q direnv
    eval (direnv hook fish)
end

# 5) プロンプト等の初期化（順序は任意）
starship init fish | source

# 6) テーマ環境変数（必要なら）
set -gx TMUX_THEME solarized

status --is-interactive; and source (goenv init -| psub)
