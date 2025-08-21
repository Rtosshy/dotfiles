#!/usr/bin/env fish

set nvim_dir "$HOME/.config/nvim"
set lazyvim_dir "$HOME/.config/lazyvim"

if test -d $lazyvim_dir
    echo "lazyvim exists."
    exit 0
else
    if test -d $nvim_dir
        mv $nvim_dir $lazyvim_dir
        echo "Renamed nvim to lazyvim."
    else
        echo "nvim does not exist. Nothing to rename."
    end
end

set script_path (status --current-filename)
set parent_dir (dirname $script_path)

mkdir -p $HOME/.config/nvim

cp -r $parent_dir $HOME/.config/nvim
echo "Copied $parent_dir to $HOME/.config/nvim."
