{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    packageConfigurable = pkgs.vim;
    extraConfig = builtins.readFile ./vimrc;
  };
}
