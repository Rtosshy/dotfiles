# Modules

`modules/` contains reusable configuration units. A module should describe a
piece of configuration that can be composed by one or more hosts.

Host-specific choices belong in `hosts/`. If a setting only answers "does this
machine use this piece?", keep that decision in the host file.

## Layout

### `shared/`

Cross-platform Home Manager modules.

- `shared/default.nix`: default shared entrypoint. It imports `shared/cli`.
- `shared/cli/default.nix`: CLI group module. It imports CLI tools and defines
  shared CLI packages.
- `shared/gui/default.nix`: GUI group module. It imports GUI-related modules.

Use `modules/shared` when a host should get the standard CLI environment.
Use `modules/shared/gui` only when a host should get GUI tools.

### `shared/cli/`

Reusable CLI and editor modules.

Examples:

- `fish/`: fish configuration
- `starship/`: prompt configuration
- `git/`: git configuration
- `lazygit/`: lazygit configuration
- `nvim/`: nixvim-based Neovim configuration

CLI packages that are part of the standard CLI environment are declared in
`shared/cli/default.nix`.

### `shared/gui/`

Reusable GUI-oriented Home Manager modules.

Examples:

- `ghostty/`: Ghostty configuration
- `wezterm/`: WezTerm configuration and Lua config files
- `fonts/`: GUI font packages

### `darwin/`

Darwin-specific modules.

- `darwin/nix-darwin/system/`: nix-darwin system settings
- `darwin/nix-darwin/homebrew/`: Homebrew casks and activation behavior
- `darwin/home-manager/`: Darwin-only Home Manager additions

Darwin-only user configuration, such as `macism`, macOS terminal keybinds, and
`darwin-rebuild` abbreviations, belongs in `darwin/home-manager`.

### `nixos/`

Reserved for future NixOS modules.

## Guidelines

- Use `module-name/default.nix` for module entrypoints.
- Prefer group modules for normal hosts: `modules/shared` and
  `modules/shared/gui`.
- Import individual modules from a host only for deliberate exceptions.
- If the same exception appears in multiple hosts, create a new group module.
- Keep platform-specific behavior in platform modules or guard it with platform
  checks.
- Keep app-specific configuration near the app module. For example, WezTerm Lua
  files live under `shared/gui/wezterm/config`.
