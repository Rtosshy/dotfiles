{ pkgs, lib, ... }:
{
  imports = [
    ../../shared/cli/nvim/platform/darwin-ime.nix
  ];

  home.packages = with pkgs; [
    macism
  ];

  programs.fish.shellAbbrs = {
    drs = {
      expansion = "darwin-rebuild switch --flake ~/ghq/github.com/Rtosshy/dotfiles";
      position = "anywhere";
    };
    nfu = {
      expansion = "nix flake update --flake ~/ghq/github.com/Rtosshy/dotfiles";
      position = "anywhere";
    };
  };

  xdg.configFile."ghostty/config".text = lib.mkAfter ''

    keybind = global:cmd+ctrl+shift+j=toggle_visibility
    macos-option-as-alt = left
  '';
}
