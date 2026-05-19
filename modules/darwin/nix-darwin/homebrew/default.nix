_: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    casks = [
      "arc"
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
    ];
  };
}
