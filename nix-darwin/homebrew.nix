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
      "wezterm"
      "docker-desktop"
    ];
  };
}
