{ pkgs, ... }:
{
  imports = [
    ../home-manager
    ./shell/fish.nix
    ./apps/ghostty.nix
  ];

  home = {
    username = "tosshy";
    homeDirectory = "/Users/tosshy";
    stateVersion = "25.11";

    packages = with pkgs; [
      macism
    ];
  };
}
