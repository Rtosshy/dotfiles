{ pkgs, ... }:
{
  imports = [
    ../shell/fish.nix
    ../shell/starship.nix
    ../nvim
    ../apps/git.nix
    ../apps/lazygit.nix
    ../apps/ghostty.nix
    ../apps/wezterm.nix
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
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    plemoljp-nf
  ];

  programs = {
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
