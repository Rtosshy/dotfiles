# Modules

`modules/` contains reusable configuration units. A module should describe a
piece of configuration that can be composed by one or more system or home
entrypoints.

Machine-specific system choices belong in `systems/`. User profile choices
belong in `home/`. If a setting only answers "does this machine or user use
this piece?", keep that decision in the entrypoint file.

## Layout

### `shared/`

Cross-platform Home Manager modules.

Home Manager entrypoints import the specific modules they need from
`shared/cli/` and `shared/gui/`. Profile-specific package lists and
`programs.*` choices belong in `home/`.

### `shared/cli/`

Reusable CLI and editor modules.

Examples:

- `fish/`: fish configuration
- `starship/`: prompt configuration
- `git/`: git configuration
- `lazygit/`: lazygit configuration
- `nvim/`: nixvim-based Neovim configuration

CLI package lists and profile-level program choices are intentionally not
declared here. Put those decisions in the importing Home Manager entrypoint
under `home/`.

### `shared/gui/`

Reusable GUI-oriented Home Manager modules.

Examples:

- `ghostty/`: Ghostty configuration
- `wezterm/`: WezTerm configuration and Lua config files
- `fonts/`: GUI font packages

### `darwin/`

Darwin-specific modules.

- `darwin/nix-darwin/system/`: nix-darwin system settings
- `darwin/nix-darwin/homebrew/`: nix-homebrew setup plus Homebrew casks and activation behavior
- `darwin/home-manager/`: Darwin-only Home Manager additions

Darwin-only user configuration, such as `macism`, macOS terminal keybinds, and
`darwin-rebuild` abbreviations, belongs in `darwin/home-manager`.
Darwin-only system packages from nixpkgs, such as `openfortivpn`, belong in
`darwin/nix-darwin/system`.

### `nixos/`

Reserved for future NixOS modules.

## Guidelines

- Use `module-name/default.nix` for module entrypoints.
- Import individual shared modules explicitly from Home Manager entrypoints.
- If the same explicit import set becomes noisy in multiple entrypoints, consider
  introducing a profile-specific group module.
- Keep profile package policy and optional tools such as `direnv`, `mise`, and
  `zoxide` in `home/`, where each user environment can opt in deliberately.
- Keep platform-specific behavior in platform modules or guard it with platform
  checks.
- Keep app-specific configuration near the app module. For example, WezTerm Lua
  files live under `shared/gui/wezterm/config`.
