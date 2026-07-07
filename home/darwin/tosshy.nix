{
  inputs,
  pkgs,
  nixvim,
  ...
}:
{
  imports = [
    ../../modules/shared/home-manager/nix-profile-add-activation.nix
    ../../modules/shared/cli/nvim
    ../../modules/shared/cli/fish
    ../../modules/shared/cli/git
    ../../modules/shared/cli/codex
    ../../modules/shared/cli/direnv
    ../../modules/shared/cli/emacs
    ../../modules/shared/cli/claude
    ../../modules/shared/cli/herdr
    ../../modules/shared/cli/lazygit
    ../../modules/shared/cli/starship
    ../../modules/shared/cli/tmux
    ../../modules/shared/gui/fonts
    ../../modules/shared/gui/omniwm
    ../../modules/shared/gui/aerospace
    ../../modules/shared/gui/wezterm
    ../../modules/shared/gui/kitty
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
      poppler-utils
      tdf
      inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
      codex
      terraform
      terraform-ls
      tree-sitter # nvim-treesitter がパーサーのビルドに使用する
      tmux
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
