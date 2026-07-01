{ nixvim, ... }:
{
  imports = [
    ../../modules/shared
    ../../modules/shared/gui
    ../../modules/darwin/home-manager
    nixvim.homeModules.nixvim
  ];

  home = {
    username = "tosshy";
    homeDirectory = "/Users/tosshy";
    stateVersion = "25.11";
  };
}
