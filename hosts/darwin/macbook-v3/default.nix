{ inputs, home-manager, ... }:
{
  imports = [
    ../../../modules/darwin/nix-darwin/system
    ../../../modules/darwin/nix-darwin/homebrew
    home-manager.darwinModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.tosshy = {
      imports = [
        ../../../modules/shared
        ../../../modules/shared/gui
        ../../../modules/darwin/home-manager
      ];

      home = {
        username = "tosshy";
        homeDirectory = "/Users/tosshy";
        stateVersion = "25.11";
      };
    };
  };
}
