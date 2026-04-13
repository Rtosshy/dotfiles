{ pkgs, ... }: {
  imports = [
    ./fish.nix
    ./starship.nix
    ./nvim.nix
    ./git.nix
    ./ghostty.nix
    ./wezterm.nix
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
