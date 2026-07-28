{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hunk
  ];

  xdg.configFile."hunk/config.toml".source = ./config.toml;
}
