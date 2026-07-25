{
  pkgs,
  nvimx,
  ...
}:

let
  lockDir = ./nvim/nvimx-lock;

  languageServers = with pkgs; [
    lua-language-server
    pyright
    gopls
    kotlin-language-server
    terraform-ls
    rust-analyzer
    nixd
  ];

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
    inherit lockDir;
    extraPackages = languageServers;
    env = import ./env.nix {
      inherit
        pkgs
        nvimx
        lockDir
        ;
      extraPackages = languageServers;
    };

    lock = {
      projectDir = "~/ghq/github.com/Rtosshy/dotfiles";
      configDirRelative = "modules/shared/nvimx/nvim";
      lockDirRelative = "modules/shared/nvimx/nvim/nvimx-lock";
    };
  };
}
