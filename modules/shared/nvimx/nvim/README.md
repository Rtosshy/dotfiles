# Neovim (lazy.nvim)

This is the Lua/lazy.nvim equivalent of `modules/shared/nixvim`.

To use it directly:

```sh
XDG_CONFIG_HOME="$PWD/modules/shared/nvimx" nvim
```

Run that command from the repository root, or symlink this `nvim` directory
to `~/.config/nvim`. From `modules/shared/nvimx/default.nix`, this directory
can be referenced as `./nvim`. On first launch, `init.lua` bootstraps
lazy.nvim and lazy.nvim installs the plugins.

Language servers and formatters remain external executables, as in the NixVim
configuration. Install `lua-language-server`, `pyright`, `gopls`,
`kotlin-language-server`, `terraform-ls`, `rust-analyzer`, and `nixd` as
needed. Formatting additionally uses `stylua`, `gofmt`, `ktlint`, `rustfmt`,
`clang-format`, and `terraform`.

The configured plugins also expect `lazygit`, `rg`, `fd`, `curl`, `jq`,
`pandoc`, `make`, a C compiler, OpenSSL, and SSH for their corresponding
features.

The macOS-only features require `macism`; the Yoshi animations require a
terminal that implements the Kitty graphics protocol.
