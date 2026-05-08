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
      nixpkgs,
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

      # Standalone Home Manager output for non-NixOS Linux environments
      # (Codespaces spawned from OSS project devcontainers, remote dev
      # boxes, ad-hoc Ubuntu/Debian/Fedora servers, ...).
      #
      # `username` and `homeDirectory` are read from `$USER` and `$HOME`
      # at evaluation time instead of being hardcoded. The reason is that
      # the typical landing target is "someone else's OSS project's
      # Codespace", whose default user varies by devcontainer
      # (`vscode`, `node`, `codespace`, `developer`, ...). Hardcoding even
      # an enumerated set of `<user>@standalone` outputs would still miss
      # unfamiliar containers and forces a flake.nix edit every time we
      # land in one, which defeats the point of a one-shot activation.
      #
      # Trade-off: this output is impure and every Nix command touching
      # it must pass `--impure`. CI uses `nix flake check --impure`. Pure
      # `nix flake check` fails with the throw below pointing at the fix.
      #
      # Activate with:
      # $ nix run home-manager/master -- switch \
      #     --flake github:Rtosshy/dotfiles#standalone --impure
      homeConfigurations."standalone" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs =
          let
            username = builtins.getEnv "USER";
            homeDirectory = builtins.getEnv "HOME";
          in
          if username == "" || homeDirectory == "" then
            throw ''
              homeConfigurations."standalone" reads $USER and $HOME from
              the activation environment, so it must be evaluated with
              --impure. Re-run with: --impure
            ''
          else
            {
              inherit inputs username homeDirectory;
            };
        modules = [ ./hosts/linux/standalone ];
      };
    };
}
