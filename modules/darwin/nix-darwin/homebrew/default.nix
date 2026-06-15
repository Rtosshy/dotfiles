{ config, inputs, ... }:
{
  nix-homebrew = {
    enable = true;
    user = "tosshy";
    autoMigrate = true;

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "barutsrb/homebrew-tap" = inputs.homebrew-barutsrb-tap;
      "nikitabobko/homebrew-tap" = inputs.homebrew-nikitabobko-tap;
    };
    mutableTaps = false;
  };

  homebrew = {
    enable = true;
    taps = builtins.attrNames config.nix-homebrew.taps;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    casks = [
      "aerospace"
      "arc"
      "omniwm"
      "raycast"
      "slack"
      "zoom"
      "discord"
      "firefox"
      "claude"
      "chatgpt"
      "ghostty"
      "wezterm@nightly"
      "docker-desktop"
      "notion"
      "spotify"
      "tableplus"
      "cmux"
    ];
  };
}
