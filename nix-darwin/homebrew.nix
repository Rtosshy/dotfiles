{ ... }: {
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
      "discord"
      "claude"
      "chatgpt"
      "ghostty"
      "wezterm@nightly"
      "docker-desktop"
      "notion"
      "spotify"
    ];
  };
}
