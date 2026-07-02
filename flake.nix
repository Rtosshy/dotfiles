{
  description = "System configuration for the dotfiles repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-barutsrb-tap = {
      url = "github:barutsrb/homebrew-tap";
      flake = false;
    };
    homebrew-nikitabobko-tap = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      home-manager,
      nixvim,
      ...
    }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f system (
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }
          )
        );

      mkTask =
        pkgs: name: text:
        let
          package = pkgs.writeShellApplication {
            inherit name text;
            runtimeInputs = [
              pkgs.git
              pkgs.nix
            ];
          };
        in
        {
          type = "app";
          program = "${package}/bin/${name}";
        };

      standaloneSystem =
        let
          envSystem = builtins.getEnv "NIX_SYSTEM";
        in
        if envSystem != "" then
          envSystem
        else
          builtins.currentSystem or (throw ''
            homeConfigurations."standalone" reads the current system from
            the activation environment, so it must be evaluated with
            --impure. Re-run with: --impure
          '');
    in
    {
      apps = forAllSystems (
        system: pkgs:
        let
          homeManagerPackage =
            home-manager.packages.${system}.home-manager or home-manager.packages.${system}.default;
          darwinRebuildPackage =
            nix-darwin.packages.${system}.darwin-rebuild or nix-darwin.packages.${system}.default;
          help = mkTask pkgs "dotfiles-help" ''
            cat <<'EOF'
            Available tasks:
              nix run .#build          Build Home Manager activation package
              nix run .#check          Evaluate Home Manager and run dev flake checks
              nix run .#home-switch    Switch Home Manager for tosshy@MacBook-V3
              nix run .#darwin-switch  Switch nix-darwin configuration
              nix run .#update-claude  Update sadjow/claude-code-nix lock input
            EOF
          '';
        in
        {
          build = mkTask pkgs "dotfiles-build" ''
            repo="''${DOTFILES_FLAKE:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
            nix build "$repo#homeConfigurations.\"tosshy@MacBook-V3\".activationPackage"
          '';

          check = mkTask pkgs "dotfiles-check" ''
            repo="''${DOTFILES_FLAKE:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
            nix eval "$repo#homeConfigurations.\"tosshy@MacBook-V3\".activationPackage.drvPath" >/dev/null
            nix flake check "$repo/dev"
          '';

          darwin-switch = mkTask pkgs "dotfiles-darwin-switch" ''
            repo="''${DOTFILES_FLAKE:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
            ${darwinRebuildPackage}/bin/darwin-rebuild switch --flake "$repo#MacBook-V3"
          '';

          default = help;
          inherit help;

          home-switch = mkTask pkgs "dotfiles-home-switch" ''
            repo="''${DOTFILES_FLAKE:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
            ${homeManagerPackage}/bin/home-manager switch --flake "$repo#tosshy@MacBook-V3"
          '';

          update-claude = mkTask pkgs "dotfiles-update-claude" ''
            repo="''${DOTFILES_FLAKE:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
            nix flake update claude-code --flake "$repo"
          '';
        }
      );

      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#MacBook-V3
      darwinConfigurations."MacBook-V3" = nix-darwin.lib.darwinSystem {
        modules = [
          ./systems/darwin/macbook-v3
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
        specialArgs = { inherit inputs home-manager nixvim; };
      };

      homeConfigurations."tosshy@MacBook-V3" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit inputs nixvim; };
        modules = [
          ./home/darwin/tosshy.nix
        ];
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
          system = standaloneSystem;
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
              inherit
                inputs
                username
                homeDirectory
                nixvim
                ;
            };
        modules = [
          ./home/linux/standalone.nix
        ];
      };
    };
}
