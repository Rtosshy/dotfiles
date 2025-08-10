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

function fish_prompt
    if [ $status -eq 0 ]
        set status_face (set_color green)"(*´ω｀*) < "
    else
        set status_face (set_color red)"｡+ﾟ(∩´﹏'∩)ﾟ+｡ < "
    end
    printf '%s %s' (set_color yellow)(prompt_pwd) $status_face
end

# aliases
alias xcode="open -a /Applications/Xcode-16.0.0.app"
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

# Initialize PATH with minimal system defaults to avoid duplicates
set -gx PATH /usr/bin /bin /usr/sbin /sbin /usr/local/bin /opt/homebrew/bin /opt/homebrew/sbin

# Go
set -x GOPATH $HOME/go
set -gx PATH $PATH $GOPATH/bin

# Flutter
set -gx PATH $PATH $HOME/development/flutter/bin

# Dart (pub-cache)
set -gx PATH $PATH $HOME/.pub-cache/bin

# Volta
set -x VOLTA_HOME $HOME/.volta
set -gx PATH $PATH $VOLTA_HOME/bin
set -x VOLTA_FEATURE_PNPM 1

# LM Studio
set -gx PATH $PATH $HOME/.lmstudio/bin

# direnv (place last to respect project-specific PATH changes)
if command -q direnv
    eval (direnv hook fish)
end
# Added by Windsurf
fish_add_path /Users/toshiyukimannen/.codeium/windsurf/bin

# WezTerm Theme
set -gx WEZTERM_THEME tokyo_night

# Tmux Theme
set -gx TMUX_THEME nord

# Starship
starship init fish | source
