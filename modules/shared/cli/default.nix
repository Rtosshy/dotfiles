{ pkgs, ... }:
{
  imports = [
    ./fish
    ./starship
    ./git
    ./lazygit
    ./nvim
    ./claude
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
    kubectl
    kubernetes-helm
    minikube
    imagemagick
    pandoc
    claude-code
    codex
    github-copilot-cli
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
