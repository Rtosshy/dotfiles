# Darwin Modules

`modules/darwin/` contains modules that should only be used by Darwin hosts.
It includes two different Nix layers:

- nix-darwin system modules
- Darwin-only Home Manager modules

Keep those layers separate. nix-darwin modules are imported by Darwin host files
under `hosts/darwin/`. Home Manager modules are nested under the host's
`home-manager.users.<name>` configuration.

## Layout

### `nix-darwin/system/`

nix-darwin system settings.

Examples:

- Nix experimental features
- macOS defaults
- system shell setup
- Darwin user account metadata
- `nixpkgs.hostPlatform`

This module is imported from a Darwin host file.

### `nix-darwin/homebrew/`

nix-darwin Homebrew settings.

Examples:

- Homebrew activation behavior
- cask packages

This module is imported from a Darwin host file.

### `home-manager/`

Darwin-only Home Manager additions.

Examples:

- `macism`
- `darwin-rebuild` and `nix flake update` fish abbreviations
- macOS-specific Ghostty settings
- Darwin IME integration for Neovim

This module is imported from a Darwin host file under
`home-manager.users.<name>.imports`.

## Import Flow

```text
flake.nix
└─ darwinConfigurations."MacBook-V3"
   └─ hosts/darwin/macbook-v3
      ├─ modules/darwin/nix-darwin/system
      ├─ modules/darwin/nix-darwin/homebrew
      └─ home-manager.users.tosshy
         └─ modules/darwin/home-manager
```

## Guidelines

- Do not import `nix-darwin/system/` or `nix-darwin/homebrew/` from Home
  Manager host files.
- Do not import `home-manager/` directly as a nix-darwin system module; import it
  inside `home-manager.users.<name>.imports`.
- Put settings that require macOS, nix-darwin, Homebrew, or `/Users/...` under
  this directory.
- Prefer `modules/shared/` for configuration that works across Darwin and Linux.
