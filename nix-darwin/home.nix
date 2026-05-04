{ pkgs, ... }:
{
  imports = [
    ./shell/fish.nix
    ./shell/starship.nix
    ./editor/nvim.nix
    ./apps/git.nix
    ./apps/lazygit.nix
    ./apps/ghostty.nix
    ./apps/wezterm.nix
  ];

  home = {
    username = "tosshy";
    homeDirectory = "/Users/tosshy";
    stateVersion = "25.11";

    packages = with pkgs; [
      ripgrep
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
      tree-sitter # nvim-treesitter がパーサーのビルドに使用する
      macism
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      plemoljp-nf
    ];
  };

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
