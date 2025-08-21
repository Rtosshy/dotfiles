#!/opt/homebrew/bin/fish

set nvim_dir "$HOME/.config/nvim"
set lazyvim_dir "$HOME/.config/lazyvim"

if test -d $lazyvim_dir
    if test -d $nvim_dir
        rm -rf $nvim_dir
    end
    mv $lazyvim_dir $nvim_dir
    echo "Restored nvim from lazyvim."
else
    echo "lazyvim does not exist."
end
