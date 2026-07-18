{ pkgs, lib, ... }:
{
  imports = [
    ../../shared/nvim/platform/darwin-ime.nix
    ./omniwm
  ];

  home.packages = with pkgs; [
    macism
  ];

  xdg.configFile."ghostty/config".text = lib.mkAfter ''

    keybind = global:cmd+ctrl+shift+j=toggle_visibility
    macos-option-as-alt = left
  '';
}
