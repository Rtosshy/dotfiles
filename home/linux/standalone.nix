{
  inputs,
  pkgs,
  username,
  homeDirectory,
  nixvim,
  ...
}:
{
  imports = [
    ../../modules/shared/home-manager/nix-profile-add-activation.nix
    ../../modules/shared/vim
    ../../modules/shared/nvim
    ../../modules/shared/fish
    ../../modules/shared/git
    ../../modules/shared/direnv
    ../../modules/shared/lazygit
    ../../modules/shared/starship
    ../../modules/shared/claude
    ../../modules/shared/codex
    ../../modules/shared/herdr
    nixvim.homeModules.nixvim
  ];

  home = {
    inherit username homeDirectory;
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
      byobu
      inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
      tree-sitter # nvim-treesitter がパーサーのビルドに使用する
    ];
  };

  programs = {
    home-manager.enable = true;

    zoxide = {
      enable = true;
      options = [
        "--cmd"
        "cd"
      ];
    };
  };
}
