{ pkgs, ... }:

let
  treesitterGrammars = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
    bash
    c
    cpp
    fish
    go
    lua
    nix
    rust
    terraform
    yaml
  ];

  nvimConfig = pkgs.runCommandLocal "nvimx-config" { } ''
    mkdir -p "$out"
    cp -R ${./nvim}/. "$out/"

    mkdir -p "$out/assets"
    ln -s ${../../../assets/frames} "$out/assets/frames"

    mkdir -p "$out/parser"
    ${pkgs.lib.concatMapStringsSep "\n" (
      grammar: ''ln -s ${grammar}/parser/*.so "$out/parser/"''
    ) treesitterGrammars}
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
