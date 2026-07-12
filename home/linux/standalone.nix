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
    ../../modules/shared/cli/vim
    ../../modules/shared/cli/nvim
    ../../modules/shared/cli/fish
    ../../modules/shared/cli/git
    ../../modules/shared/cli/direnv
    ../../modules/shared/cli/lazygit
    ../../modules/shared/cli/starship
    ../../modules/shared/cli/claude
    ../../modules/shared/cli/codex
    ../../modules/shared/cli/herdr
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
