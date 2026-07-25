{ pkgs, ... }:

let
  nvimConfig = pkgs.runCommandLocal "nvimx-config" { } ''
    mkdir -p "$out"
    cp -R ${./nvim}/. "$out/"

    mkdir -p "$out/assets"
    ln -s ${../../../assets/frames} "$out/assets/frames"
  '';
in
{
  programs.nvimx = {
    enable = true;
    configDir = nvimConfig;
    lockDir = ./nvim/nvimx-lock;

    lock = {
      projectDir = "~/ghq/github.com/Rtosshy/dotfiles";
      configDirRelative = "modules/shared/nvimx/nvim";
      lockDirRelative = "modules/shared/nvimx/nvim/nvimx-lock";
    };
  };
}
