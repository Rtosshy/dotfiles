# load source
abbr -a sc "source $HOME/.config/fish/config.fish"

# check nvim is installed or not
if command -q nvim
    abbr -a v   "nvim"
    abbr -a vi  "nvim"
    abbr -a vim "nvim"
else
    abbr -a v   "vim"
    abbr -a vi  "vim"
    abbr -a vim "vim"
end

# check eza is installed or not
if command -q eza
    abbr -a ls "eza --icons"
    abbr -a ll "eza --icons -lhg --time-style long-iso"
    abbr -a la "eza --icons -lhag --time-style long-iso"
    abbr -a lt "eza --icons --tree"
else
    abbr -a ls "ls -Fh"
    abbr -a ll "ls -lFh"
    abbr -a la "ls -laFh"
    abbr -a lt "ls -lFhR"
end


