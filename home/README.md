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

### `linux/standalone.nix`

Standalone Home Manager configuration for non-NixOS Linux environments
(Codespaces, remote dev servers, generic Ubuntu/Debian/Fedora boxes, etc.).
CLI-only; no GUI modules are imported.

`username` and `homeDirectory` are passed in by the flake so the same
configuration can be reused across environments where the default user differs
(e.g. `vscode` on Codespaces, `ubuntu` on EC2).

Imports:

- `modules/shared`: shared CLI modules and CLI packages
- `nixvim.homeModules.nixvim`: nixvim module integration

This home is imported by the root flake as `homeConfigurations."standalone"`.

## Guidelines

- Keep nix-darwin and future NixOS settings out of this directory.
- Use `modules/shared` for cross-platform CLI defaults.
- Use `modules/shared/gui` only for GUI-capable user profiles.
- Put platform-specific user additions in platform modules such as
  `modules/darwin/home-manager`.
