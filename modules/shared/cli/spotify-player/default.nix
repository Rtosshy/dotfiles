_: {
  programs.spotify-player.enable = true;

  xdg.configFile."spotify-player/app.toml".source = ./app.toml;
  xdg.configFile."spotify-player/theme.toml".source = ./theme.toml;
}
