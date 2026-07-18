# Home

`home/` contains Home Manager entrypoints. These files compose reusable Home
Manager modules for a user profile and define user-local values such as
`home.username`, `home.homeDirectory`, and `home.stateVersion`.

OS-level configuration belongs under `systems/`. Reusable Home Manager modules
belong under `modules/`. Profile package lists and optional `programs.*`
choices also live here, because macOS, Linux, containers, and servers do not
necessarily want the same tools.

## Current Homes

### `darwin/tosshy.nix`

Home Manager configuration for `tosshy` on `MacBook-V3`.

Imports:

- selected modules from `modules/shared`: shell, editor, terminal, font, and AI tool config
- `modules/shared/nvim/platform/darwin-ime.nix`: Darwin IME integration for Neovim
- `modules/darwin/omniwm`: Darwin-only OmniWM configuration
- `nixvim.homeModules.nixvim`: nixvim module integration

This profile also defines Darwin-specific user settings, the macOS package set,
and profile-level programs such as Home Manager, direnv, mise, and zoxide.

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

- selected modules from `modules/shared`: shell, editor, and AI tool config
- `nixvim.homeModules.nixvim`: nixvim module integration

This profile defines a Linux-oriented package set and only enables the
profile-level programs that should be present in standalone environments.

This home is imported by the root flake as `homeConfigurations."standalone"`.

## Guidelines

- Keep nix-darwin and future NixOS settings out of this directory.
- Import only the shared modules each profile needs.
- Keep package lists and `programs.*` opt-ins in the profile that needs them.
- Keep profile-specific platform additions in the corresponding profile, such
  as `home/darwin/tosshy.nix`.
