# Systems

`systems/` contains OS-level flake entrypoints. These files compose reusable
system modules and define machine-local system values. User profile
configuration belongs under `home/`.

Reusable configuration belongs under `modules/`. System files should focus on
composition and avoid defining application settings directly.

## Current Systems

### `darwin/macbook-v3.nix`

nix-darwin system configuration for `MacBook-V3`.

Imports:

- `inputs.nix-homebrew.darwinModules.nix-homebrew`: Homebrew installation manager
- `modules/darwin/nix-darwin/system`: nix-darwin system settings
- `modules/darwin/nix-darwin/homebrew`: nix-homebrew configuration and Homebrew settings

This system is imported by the root flake as
`darwinConfigurations."MacBook-V3"`.

```sh
darwin-rebuild build --flake .#MacBook-V3
darwin-rebuild switch --flake .#MacBook-V3
```

Home Manager for this machine is intentionally separate and exposed as
`homeConfigurations."tosshy@MacBook-V3"`.

### `darwin/template.nix`

Skeleton for a new Darwin host, used when moving to a new machine. It is not
referenced by `flake.nix`, so `nix flake check` never evaluates it — treat it
as documentation that happens to be valid Nix, and re-verify it by hand after
changing the shared Darwin modules:

```sh
nix eval --impure --expr '
  let inputs = (builtins.getFlake "path:'"$PWD"'").inputs; in
  (inputs.nix-darwin.lib.darwinSystem {
    modules = [ ./systems/darwin/template.nix ];
    specialArgs = { inherit inputs; home-manager = inputs.home-manager; };
  }).config.system.build.toplevel.drvPath'
```

Copy the file rather than editing it in place:

```sh
cp systems/darwin/template.nix systems/darwin/macbook-v4.nix
```

The template header lists the values that are still shared rather than
host-local (`system.primaryUser`, `users.users.<user>`, `nixpkgs.hostPlatform`,
`nix-homebrew.user`). A second host with a different user or CPU has to move
those out of `modules/darwin/nix-darwin/*` into its own system file first.

### `nixos/`

Reserved for future NixOS system configurations.

## Guidelines

- Put reusable app, shell, editor, GUI, and platform modules in `modules/`.
- Use `systems/` for OS-level composition such as nix-darwin or future NixOS.
- Use `home/` for Home Manager user-level composition.
- Import `modules/darwin/nix-darwin/*` only from Darwin system files.
- Import Home Manager modules from `home/` or Home Manager-only compositions.
