{
  inputs,
  lib,
  pkgs,
  nixvim,
  ...
}:
{
  imports = [
    ../../modules/shared/home-manager/nix-profile-add-activation.nix
    ../../modules/shared/vim
    ../../modules/shared/nvim
    ../../modules/shared/nvim/platform/darwin-ime.nix
    ../../modules/shared/fish
    ../../modules/shared/bash
    ../../modules/shared/nushell
    ../../modules/shared/git
    ../../modules/shared/rust
    ../../modules/shared/codex
    ../../modules/shared/direnv
    ../../modules/shared/emacs
    ../../modules/shared/claude
    ../../modules/shared/herdr
    ../../modules/shared/lazygit
    ../../modules/shared/starship
    ../../modules/shared/tmux
    ../../modules/shared/btop
    ../../modules/shared/spotify-player
    ../../modules/shared/fonts
    ../../modules/shared/wezterm
    ../../modules/shared/kitty
    ../../modules/darwin/omniwm
    nixvim.homeModules.nixvim
  ];

  home = {
    username = "tosshy";
    homeDirectory = "/Users/tosshy";
    stateVersion = "25.11";
    packages = with pkgs; [
      alt-tab-macos
      macism
      ripgrep
      fastfetch
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
      poppler-utils
      inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
      tdf
      terraform
      terraform-ls
      tree-sitter # nvim-treesitter がパーサーのビルドに使用する
      tmux
    ];
  };

  xdg.configFile."ghostty/config".text = lib.mkAfter ''

    keybind = global:cmd+ctrl+shift+j=toggle_visibility
    macos-option-as-alt = left
  '';

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
