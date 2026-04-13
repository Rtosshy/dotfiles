{ ... }: {
  programs.git = {
    enable = true;
    settings.user = {
      name = "Rtosshy";
      email = "tosshy820@gmail.com";
    };
    ignores = [
      "**/.claude/settings.local.json"
      ".DS_Store"
    ];
  };
}
