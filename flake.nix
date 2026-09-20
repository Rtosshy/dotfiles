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
    nvimx.url = "github:myuron/nvimx";
    omniwm = {
      url = "github:mst-mkt/omniwm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      home-manager,
      nvimx,
      ...
    }:
    let
      # x86_64-darwinはnixpkgs 26.11でサポートが打ち切られ、import nixpkgsの
      # 時点でthrowするので載せられない
      # https://nixos.org/manual/nixpkgs/unstable/release-notes#x86_64-darwin-26.11
      systems = [
        "aarch64-darwin"
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

      # appの説明文。nix flake checkがapps.<system>.<name>にmeta.descriptionを
      # 要求するので、#helpの一覧とmetaの二重管理にならないようここを唯一の出典にする
      taskDescriptions = {
        build = "Build Home Manager activation package";
        check = "Evaluate Home Manager and run dev flake checks";
        darwin-switch = "Switch nix-darwin configuration";
        help = "Show available tasks";
        home-switch = "Switch Home Manager for tosshy@MacBook-V3";
        standalone-switch = "Switch standalone Home Manager for $USER (Linux)";
        update-claude = "Update sadjow/claude-code-nix lock input";
      };

      helpText =
        let
          names = builtins.attrNames taskDescriptions;
          width = 2 + nixpkgs.lib.foldl' nixpkgs.lib.max 0 (map builtins.stringLength names);
          pad = name: name + nixpkgs.lib.strings.replicate (width - builtins.stringLength name) " ";
        in
        nixpkgs.lib.concatMapStringsSep "\n" (
          name: "  nix run .#${pad name}${taskDescriptions.${name}}"
        ) names;

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
          # nameは"dotfiles-<task>"なのでprefixを剥がして説明文を引く
          meta.description = taskDescriptions.${nixpkgs.lib.removePrefix "dotfiles-" name};
        };
    in
    {
      # Standalone Home Manager builder for non-NixOS Linux environments
      # (Codespaces spawned from OSS project devcontainers, remote dev
      # boxes, ad-hoc Ubuntu/Debian/Fedora servers, ...).
      #
      # This is a function rather than a `homeConfigurations.<name>` entry
      # on purpose. The typical landing target is "someone else's OSS
      # project's Codespace", whose default user varies by devcontainer
      # (`vscode`, `node`, `codespace`, `developer`, ...). Enumerating
      # `<user>@standalone` outputs would still miss unfamiliar containers
      # and forces a flake.nix edit every time we land in one.
      #
      # Taking the identity as an argument moves that decision out of Nix
      # evaluation: the `standalone-switch` app below reads $USER / $HOME
      # in the shell and passes them in via `nix eval --apply`, so the
      # flake itself stays pure and `nix flake check` needs no --impure.
      lib.mkStandalone =
        {
          system,
          username,
          homeDirectory,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit
              inputs
              username
              homeDirectory
              nvimx
              ;
          };
          modules = [
            ./home/linux/standalone.nix
          ];
        };

      apps = forAllSystems (
        system: pkgs:
        let
          homeManagerPackage =
            home-manager.packages.${system}.home-manager or home-manager.packages.${system}.default;
          help = mkTask pkgs "dotfiles-help" ''
            cat <<'EOF'
            Available tasks:
            ${helpText}
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
        # Darwin向けのappsにのみdarwin-switchを追加する
        # Linux向けではnix-darwinのDarwin専用パッケージを評価しないでdarwin-switchのCIチェックで落ちない
        // nixpkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          darwin-switch = mkTask pkgs "dotfiles-darwin-switch" ''
            repo="''${DOTFILES_FLAKE:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
            ${nix-darwin.packages.${system}.darwin-rebuild}/bin/darwin-rebuild \
            switch --flake "$repo#MacBook-V3"
          '';
        }
        # Linux向けのappsにのみstandalone-switchを追加する
        # lib.mkStandaloneがhome/linux/standalone.nixしか組み立てないので
        // nixpkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          standalone-switch = mkTask pkgs "dotfiles-standalone-switch" ''
            # 素のCodespaceにcloneは無いのでデフォルトはリモート参照にする。
            # git rev-parse を既定にすると、居候先のOSSリポジトリを掴む事故になる。
            flake="''${DOTFILES_FLAKE:-github:Rtosshy/dotfiles}"

            username="''${USER:-$(id -un)}"
            if [[ -z "''${HOME:-}" ]]; then
              echo "standalone-switch: HOME is unset; cannot determine the home directory" >&2
              exit 1
            fi

            # $USER / $HOME はここ(シェル)で読んで、ただの文字列として純粋評価に渡す。
            # Nix側はbuiltins.getEnvを使わないので--impureが要らない。
            echo "standalone-switch: evaluating for $username ($HOME) on ${system}"
            drv="$(nix eval --raw "$flake#lib.mkStandalone" "$@" --apply \
              "f: (f { system = \"${system}\"; username = \"$username\"; homeDirectory = \"$HOME\"; }).activationPackage.drvPath")"

            out="$(nix build "$drv^*" --no-link --print-out-paths)"
            "$out/activate"
          '';
        }
      );

      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#MacBook-V3
      darwinConfigurations."MacBook-V3" = nix-darwin.lib.darwinSystem {
        modules = [
          ./systems/darwin/macbook-v3.nix
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

      homeConfigurations."tosshy@MacBook-V3" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit inputs nvimx; };
        modules = [
          ./home/darwin/tosshy.nix
        ];
      };

    };
}
