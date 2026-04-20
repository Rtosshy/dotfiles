{ pkgs, ... }: {
  imports = [
    ./shell/fish.nix
    ./shell/starship.nix
    ./editor/nvim.nix
    ./apps/git.nix
    ./apps/ghostty.nix
    ./apps/wezterm.nix
  ];

  home.username = "tosshy";
  home.homeDirectory = "/Users/tosshy";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    ripgrep
    bat
    gh
    ghq
    peco
    eza
    lazygit
    claude-code
    codex
    stylua
    tree-sitter # nvim-treesitter がパーサーのビルドに使用する
    macism
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    plemoljp-nf
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.mise.enable = true;

  programs.zoxide = {
    enable = true;
    options = [ "--cmd" "cd" ];
  };
}
