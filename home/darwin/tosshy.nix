{ pkgs, nixvim, ... }:
{
  imports = [
    ../../modules/shared
    ../../modules/shared/gui
    ../../modules/darwin/home-manager
    nixvim.homeModules.nixvim
  ];

  home = {
    username = "tosshy";
    homeDirectory = "/Users/tosshy";
    stateVersion = "25.11";
    packages = with pkgs; [
      ripgrep
      fd
      bat
      gh
      ghq
      peco
      eza
      tealdeer
      lazygit
      jq
      curl
      imagemagick
      pandoc
      claude-code
      codex
      terraform
      terraform-ls
      tree-sitter # nvim-treesitter がパーサーのビルドに使用する
    ];
  };

  programs = {
    home-manager.enable = true;

    mise.enable = true;

    zoxide = {
      enable = true;
      options = [
        "--cmd"
        "cd"
      ];
    };
  };
}
