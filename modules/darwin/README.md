# Darwin Modules

`modules/darwin/` contains reusable modules that should only be used by Darwin
hosts. It includes two different Nix layers:

- nix-darwin system modules
- Darwin-only application modules for Home Manager

Keep those layers separate. nix-darwin modules are imported by Darwin system files
under `systems/darwin/`. Application modules are imported by Darwin home files
under `home/darwin/`. User-specific Darwin settings stay in those home files.

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

### `omniwm/`

Home Manager module and settings for the Darwin-only OmniWM application.

It materializes OmniWM's writable `settings.toml` during Home Manager
activation and is imported from `home/darwin/tosshy.nix`.

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
      ├─ modules/shared/*
      ├─ modules/shared/nvim/platform/darwin-ime.nix
      └─ modules/darwin/omniwm
```

## Guidelines

- Do not import `nix-darwin/system/` or `nix-darwin/homebrew/` from Home
  Manager entrypoints.
- Import Darwin application modules only from Home Manager entrypoints under
  `home/darwin/`.
- Put reusable settings that require macOS, nix-darwin, or Homebrew under this
  directory. Keep user- and machine-specific choices in `home/` and `systems/`.
- Put cross-platform Home Manager modules under `modules/shared/` and import the
  needed modules explicitly from each profile.
