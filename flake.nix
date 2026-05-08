{
  description = "System configuration for the dotfiles repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      nix-darwin,
      home-manager,
      ...
    }:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#MacBook-V3
      darwinConfigurations."MacBook-V3" = nix-darwin.lib.darwinSystem {
        modules = [
          ./hosts/darwin/macbook-v3
          {
            nixpkgs.overlays = [
              (_final: prev: {
                direnv = prev.direnv.overrideAttrs (_: {
                  doCheck = false;
                });
              })
            ];
          }
        ];
        specialArgs = { inherit inputs home-manager; };
      };
    };
}
