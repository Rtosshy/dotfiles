{ lib, ... }:
{
  xdg.configFile."ghostty/config".text = lib.mkAfter ''

    keybind = global:cmd+ctrl+shift+j=toggle_visibility
    macos-option-as-alt = left
  '';
}
