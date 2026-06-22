{ pkgs, ... }:
{
  imports = [
    ./fish
    ./starship
    ./git
    ./lazygit
    ./nvim
    ./emacs
    ./claude
    ./codex
  ];

  home.packages = with pkgs; [
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
    github-copilot-cli
    terraform
    terraform-ls
    tree-sitter # nvim-treesitter がパーサーのビルドに使用する
  ];

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

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
