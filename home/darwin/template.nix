# Template for a new Darwin Home Manager profile.
#
# This file is a skeleton, not a live profile: nothing in flake.nix imports it,
# so it is never evaluated. Copy it instead of editing it in place.
#
#   cp home/darwin/template.nix home/darwin/<user>.nix
#
# Then register the profile in flake.nix:
#
#   homeConfigurations."<user>@MacBook-V4" = home-manager.lib.homeManagerConfiguration {
#     pkgs = import nixpkgs {
#       system = "aarch64-darwin";
#       config.allowUnfree = true;
#     };
#     extraSpecialArgs = { inherit inputs nvimx; };
#     modules = [ ./home/darwin/<user>.nix ];
#   };
#
#   nix run home-manager/master -- switch --flake .#<user>@MacBook-V4
#   home-manager switch --flake .#<user>@MacBook-V4      # afterwards
#
# Home Manager is activated separately from nix-darwin, so this profile and the
# host under systems/darwin/ are switched with two different commands.
#
# The import list below is a working minimum. home/darwin/tosshy.nix is the
# reference for the full set; add from modules/shared as needed rather than
# importing everything by default.
#
# See README.md for the full new-machine checklist.

{
  inputs,
  pkgs,
  nvimx,
  ...
}:
{
  imports = [
    ../../modules/shared/home-manager/nix-profile-add-activation.nix
    ../../modules/shared/vim
    ../../modules/shared/fish
    ../../modules/shared/git
    ../../modules/shared/direnv
    ../../modules/shared/starship
    ../../modules/shared/lazygit
    ../../modules/shared/claude
    ../../modules/shared/codex
    ../../modules/shared/nvimx
    ../../modules/shared/herdr
    ../../modules/shared/wezterm
    ../../modules/shared/kitty
    ../../modules/darwin/omniwm
    nvimx.homeModules.nvimx
  ];

  home = {
    username = "CHANGE-ME";
    homeDirectory = "/Users/CHANGE-ME";
    # Pin to the Home Manager release in use at first activation, then leave it
    # alone. Bumping it opts into breaking changes and is a deliberate act.
    stateVersion = "25.11";
    packages = with pkgs; [
      macism
      ripgrep
      fd
      bat
      gh
      ghq
      eza
      tealdeer
      jq
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
