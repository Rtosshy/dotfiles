# Home

`home/` contains Home Manager entrypoints. These files compose reusable Home
Manager modules for a user profile and define user-local values such as
`home.username`, `home.homeDirectory`, and `home.stateVersion`.

OS-level configuration belongs under `systems/`. Reusable Home Manager modules
belong under `modules/`.

## Current Homes

### `darwin/tosshy.nix`

Home Manager configuration for `tosshy` on `MacBook-V3`.

Imports:

- `modules/shared`: shared CLI modules and CLI packages
- `modules/shared/gui`: shared GUI modules, terminal configs, and fonts
- `modules/darwin/home-manager`: Darwin-only Home Manager additions
- `nixvim.homeModules.nixvim`: nixvim module integration

This home is imported by the root flake as
`homeConfigurations."tosshy@MacBook-V3"`.

```sh
home-manager switch --flake .#tosshy@MacBook-V3
```

### `standalone`

The standalone Linux Home Manager configuration is currently composed from
`systems/linux/standalone` because it models an ad-hoc environment more than a
named personal machine. It is exposed as `homeConfigurations."standalone"`.

## Guidelines

- Keep nix-darwin and future NixOS settings out of this directory.
- Use `modules/shared` for cross-platform CLI defaults.
- Use `modules/shared/gui` only for GUI-capable user profiles.
- Put platform-specific user additions in platform modules such as
  `modules/darwin/home-manager`.
