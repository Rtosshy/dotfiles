{ username, homeDirectory, ... }:
{
  imports = [
    ../../../modules/shared
  ];

  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
  };
}
