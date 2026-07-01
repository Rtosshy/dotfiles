# Darwin Modules

`modules/darwin/` contains modules that should only be used by Darwin hosts.
It includes two different Nix layers:

- nix-darwin system modules
- Darwin-only Home Manager modules

Keep those layers separate. nix-darwin modules are imported by Darwin system files
under `systems/darwin/`. Home Manager modules are imported by Darwin home files
under `home/darwin/`.

## Layout

### `nix-darwin/system/`

nix-darwin system settings.

Examples:

- Nix experimental features
- macOS defaults
- system shell setup
- Darwin-only system packages, such as `openfortivpn`
- Darwin user account metadata
- `nixpkgs.hostPlatform`

This module is imported from a Darwin system file.

### `nix-darwin/homebrew/`

nix-darwin Homebrew settings plus `nix-homebrew` installation management.

Examples:

- Homebrew prefix and tap management through `nix-homebrew`
- Homebrew activation behavior
- Homebrew cask packages

This module is imported from a Darwin system file.

Use nixpkgs for CLI tools when available. Reserve `homebrew.casks` for GUI apps
or software that is only practical through Homebrew Cask. `nix-homebrew`
manages Homebrew itself and pinned taps; package lists still live under
nix-darwin's `homebrew.*` options.

### `home-manager/`

Darwin-only Home Manager additions.

Examples:

- `macism`
- `darwin-rebuild` and `nix flake update` fish abbreviations
- macOS-specific Ghostty settings
- Darwin IME integration for Neovim

This module is imported from a Darwin Home Manager entrypoint under
`home/darwin/`.

## Import Flow

```text
flake.nix
└─ darwinConfigurations."MacBook-V3"
   └─ systems/darwin/macbook-v3
      ├─ inputs.nix-homebrew.darwinModules.nix-homebrew
      ├─ modules/darwin/nix-darwin/system
      ├─ modules/darwin/nix-darwin/homebrew

flake.nix
└─ homeConfigurations."tosshy@MacBook-V3"
   └─ home/darwin/tosshy.nix
      ├─ modules/shared/cli/*
      ├─ modules/shared/gui/*
      └─ modules/darwin/home-manager
```

## Guidelines

- Do not import `nix-darwin/system/` or `nix-darwin/homebrew/` from Home
  Manager entrypoints.
- Do not import `home-manager/` directly as a nix-darwin system module; import it
  from a Home Manager entrypoint under `home/`.
- Put settings that require macOS, nix-darwin, Homebrew, or `/Users/...` under
  this directory.
- Put cross-platform Home Manager modules under `modules/shared/` and import the
  needed modules explicitly from each profile.
