# Hosts

`hosts/` contains machine-specific composition. A host file should decide which
reusable modules apply to that machine and define machine-local values such as
`home.username`, `home.homeDirectory`, and `home.stateVersion`.

Reusable configuration belongs under `modules/`. Host files should focus on
composition and avoid defining application settings directly.

## Current Hosts

### `darwin/macbook-v3`

Darwin system and Home Manager configuration for `MacBook-V3`.

Imports:

- `modules/darwin/nix-darwin/system`: nix-darwin system settings
- `modules/darwin/nix-darwin/homebrew`: Homebrew settings
- `home-manager.darwinModules.home-manager`: Home Manager integration
- `modules/shared`: shared CLI modules and CLI packages
- `modules/shared/gui`: shared GUI modules, terminal configs, and fonts
- `modules/darwin/home-manager`: Darwin-only Home Manager additions

This host is imported by the root flake as `darwinConfigurations."MacBook-V3"`.

```sh
darwin-rebuild build --flake .#MacBook-V3
darwin-rebuild switch --flake .#MacBook-V3
```

### `linux/standalone`

Standalone Home Manager configuration for non-NixOS Linux environments
(Codespaces, remote dev servers, generic Ubuntu/Debian/Fedora boxes, etc.).
CLI-only; no GUI modules are imported.

`username` and `homeDirectory` are passed in by the flake so the same host
can be reused across environments where the default user differs (e.g.
`vscode` on Codespaces, `ubuntu` on EC2).

Imports:

- `modules/shared`: shared CLI modules and CLI packages

This host is intended to be exposed as a Home Manager flake output in Phase 4.

### `nixos/`

Reserved for future NixOS host configurations.

## Guidelines

- Put reusable app, shell, editor, GUI, and platform modules in `modules/`.
- Use `hosts/` to compose module groups for a machine.
- Import `modules/shared` for CLI defaults.
- Import `modules/shared/gui` only for GUI-capable hosts (currently Darwin only).
- Import platform-specific modules, such as `modules/darwin/home-manager`, only
  from matching platform hosts.
