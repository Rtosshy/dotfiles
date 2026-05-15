# Build or switch this host with:
# darwin-rebuild build --flake .#MacBook-V3
# darwin-rebuild switch --flake .#MacBook-V3

{ pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system = {
    stateVersion = 6;
    primaryUser = "tosshy";

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    defaults = {
      dock.orientation = "left";
      screencapture.location = "$HOME/Documents/screenshots";
      NSGlobalDomain.AppleShowAllFiles = true;
      CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys."64" = {
        enabled = false;
        value = {
          parameters = [
            32
            49
            1048576
          ];
          type = "standard";
        };
      };
    };
  };

  environment.shells = [ pkgs.fish ];
  programs.fish.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;

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
