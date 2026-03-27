# load source
abbr -a sc "source $HOME/.config/fish/config.fish"

# check nvim is installed or not
if command -q nvim
    echo "nvim is found"
    abbr -a v   "nvim"
    abbr -a vi  "nvim"
    abbr -a vim "nvim"
else
    echo "nvim is not found"
    abbr -a v   "vim"
    abbr -a vi  "vim"
    abbr -a vim "vim"
end

builtin command -s eza
echo "exit code: $status"
# check eza is installed or not
if command -q eza
    echo "eza is found"
    abbr -a ls "eza --icons"
    abbr -a ll "eza --icons -lhg --time-style long-iso"
    abbr -a la "eza --icons -lhag --time-style long-iso"
    abbr -a lt "eza --icons --tree"
else
    echo "eza is not found"
    abbr -a ls "ls -Fh"
    abbr -a ll "ls -lFh"
    abbr -a la "ls -laFh"
    abbr -a lt "ls -lFhR"
end

# check ripgrep is installed or not
if command -q rg
    echo "ripgrep is found"
    abbr -a grep "rg"
else
    echo "ripgrep is not found"
end

# check bat is installed or not
if command -q bat
    echo "bat is found"
    abbr -a cat "bat"
else
    echo "bat is not found"
end

