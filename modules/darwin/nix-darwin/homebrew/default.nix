{ config, inputs, ... }:
{
  nix-homebrew = {
    enable = true;
    user = "tosshy";
    autoMigrate = true;

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false;
  };

  homebrew = {
    enable = true;
    taps = builtins.attrNames config.nix-homebrew.taps;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    casks = [
      "zen"
      "thebrowsercompany-dia"
      "raycast"
      "slack"
      "zoom"
      "discord"
      "spotify"
      "google-chrome"
      "claude"
      "chatgpt"
      "wezterm@nightly"
      "docker-desktop"
      "notion"
      "tableplus"
      "kitty"
    ];
  };
}
