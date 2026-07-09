{ pkgs, lib, ... }:
{
  imports = [
    ../../shared/cli/nvim/platform/darwin-ime.nix
  ];

  home.packages = with pkgs; [
    macism
  ];

  xdg.configFile."ghostty/config".text = lib.mkAfter ''

    keybind = global:cmd+ctrl+shift+j=toggle_visibility
    macos-option-as-alt = left
  '';
}
