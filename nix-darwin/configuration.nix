# if you want to use ~/.config/nix-darwin
# sudo darwin-rebuild switch --flake ~/.config/nix-darwin
# if you want to use /etc/nix-darwin
# sudo darwin-rebuild switch

{ pkgs, lib, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system = {
    stateVersion = 6;
    primaryUser = "tosshy";

    defaults = {
      dock.orientation = "left";
      screencapture.location = "$HOME/Documents/screenshots";
      NSGlobalDomain.AppleShowAllFiles = true;
      CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys."64" = {
        enabled = false;
        value = {
          parameters = [ 32 49 1048576 ];
          type = "standard";
        };
      };
    };
  };

  environment.shells = [ pkgs.fish ];
  programs.fish.enable = true;

  users.knownUsers = [ "tosshy" ];
  users.users.tosshy = {
    name = "tosshy";
    home = "/Users/tosshy";
    shell = pkgs.fish;
    uid = 501;
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "aarch64-darwin";
  };
}

