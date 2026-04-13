{ pkgs, ... }: {
  home.username = "tosshy";
  home.homeDirectory = "/Users/tosshy";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    ripgrep
    bat
    neovim
    gh
    ghq
    peco
    eza
    zoxide
    mise
    lazygit
    claude-code
    wezterm
    starship
  ];

  programs.fish = {
    enable = true;
  };
}

