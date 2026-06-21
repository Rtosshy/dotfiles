{
  inputs,
  home-manager,
  nixvim,
  ...
}:
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ../../../modules/darwin/nix-darwin/system
    ../../../modules/darwin/nix-darwin/homebrew
    home-manager.darwinModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.tosshy = {
      imports = [
        ../../../modules/shared
        ../../../modules/shared/gui
        ../../../modules/darwin/home-manager
        nixvim.homeModules.nixvim
      ];

      home = {
        username = "tosshy";
        homeDirectory = "/Users/tosshy";
        stateVersion = "25.11";
      };
    };
  };
}
