{
  pkgs,
  username,
  homeDirectory,
  nixvim,
  ...
}:
{
  imports = [
    ../../modules/shared
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
      claude-code
      codex
      tree-sitter # nvim-treesitter がパーサーのビルドに使用する
    ];
  };

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    zoxide = {
      enable = true;
      options = [
        "--cmd"
        "cd"
      ];
    };
  };
}
