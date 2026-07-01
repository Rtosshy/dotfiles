# Systems

`systems/` contains OS-level flake entrypoints. These files compose reusable
system modules and define machine-local system values. User profile
configuration belongs under `home/`.

Reusable configuration belongs under `modules/`. System files should focus on
composition and avoid defining application settings directly.

## Current Systems

### `darwin/macbook-v3`

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

### `nixos/`

Reserved for future NixOS system configurations.

## Guidelines

- Put reusable app, shell, editor, GUI, and platform modules in `modules/`.
- Use `systems/` for OS-level composition such as nix-darwin or future NixOS.
- Use `home/` for Home Manager user-level composition.
- Import `modules/darwin/nix-darwin/*` only from Darwin system files.
- Import Home Manager modules from `home/` or Home Manager-only compositions.
