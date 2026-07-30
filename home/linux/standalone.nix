{
  inputs,
  pkgs,
  username,
  homeDirectory,
  nvimx,
  ...
}:
{
  imports = [
    ../../modules/shared/home-manager/nix-profile-add-activation.nix
    ../../modules/shared/vim
    ../../modules/shared/nvimx
    ../../modules/shared/fish
    ../../modules/shared/git
    ../../modules/shared/rust
    ../../modules/shared/direnv
    ../../modules/shared/lazygit
    ../../modules/shared/starship
    ../../modules/shared/claude
    ../../modules/shared/codex
    ../../modules/shared/herdr
    nvimx.homeModules.nvimx
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
      codex
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
