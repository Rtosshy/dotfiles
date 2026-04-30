{
  description = "Development tools for this dotfiles repository";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.deadnix
            pkgs.lefthook
            pkgs.nil
            pkgs.nixfmt
            pkgs.statix
            pkgs.stylua
            pkgs.treefmt
          ];

          shellHook = ''
            if git rev-parse --git-dir >/dev/null 2>&1; then
              lefthook install >/dev/null
            fi
          '';
        };
      });

      formatter = forAllSystems (pkgs: pkgs.treefmt);
    };
}
