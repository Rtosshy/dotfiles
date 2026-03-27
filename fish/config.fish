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

set -g fish_greeting ""

# Set fish syntax highlight
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

# 3) 他ツールを順次追加（fish_add_pathで重複防止＆順序維持）
fish_add_path -g $HOME/go/bin # Go (GOPATH/bin)
fish_add_path -g $HOME/.pixi/bin # pixi

set -gx CLAUDE_CONFIG_DIR $HOME/.claude

if command -q direnv
    eval (direnv hook fish)
end

starship init fish | source
zoxide init fish --cmd cd | source

set -gx TMUX_THEME nord

