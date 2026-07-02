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
    ../../modules/shared/cli/nvim
    ../../modules/shared/cli/fish
    ../../modules/shared/cli/git
    ../../modules/shared/cli/lazygit
    ../../modules/shared/cli/starship
    ../../modules/shared/cli/claude
    ../../modules/shared/cli/codex
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
      inputs.claude-code.packages.${pkgs.system}.default
      codex
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
