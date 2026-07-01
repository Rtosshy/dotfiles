{
  username,
  homeDirectory,
  nixvim,
  ...
}:
{
  imports = [
    ../../modules/shared
    nixvim.homeModules.nixvim
  ];

  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
  };
}
