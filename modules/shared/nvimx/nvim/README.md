# Neovim (lazy.nvim)

This is the Lua/lazy.nvim Neovim configuration managed by nvimx.

To use it directly:

```sh
XDG_CONFIG_HOME="$PWD/modules/shared/nvimx" nvim
```

Run that command from the repository root, or symlink this `nvim` directory
to `~/.config/nvim`. From `modules/shared/nvimx/default.nix`, this directory
can be referenced as `./nvim`. On first launch, `init.lua` bootstraps
lazy.nvim and lazy.nvim installs the plugins.

## Development workflow

Keep one feature in one file under `lua/plugins/`. Core settings live under
`lua/config/`, while macOS-specific settings live under `lua/platform/`.

For a Lua-only configuration change, format and build from the repository root:

```sh
stylua modules/shared/nvimx/nvim
nix run .#build
```

When adding or removing a plugin, or changing its source, branch, tag, commit,
or build setting, regenerate the nvimx lock:

```sh
nvimx-lock
git diff -- modules/shared/nvimx/nvim/nvimx-lock
```

Commit the generated `plugins.json`, `flake.nix`, and `flake.lock` together with
the Lua change. Prefer an explicit `branch`, `tag`, or `commit` when a plugin
must stay on a specific release line; nvimx does not currently resolve lazy.nvim
semver constraints such as `version = "1.*"`.

Git-backed flakes ignore untracked files. After creating a new Lua file, stage
it before running the normal build or switch:

```sh
git add modules/shared/nvimx/nvim
nix run .#build
nix run .#home-switch
```

The pre-commit hook runs the Lua formatter again. A configuration-only change
that does not alter the plugin spec does not require `nvimx-lock`.

The Neovim wrapper provides `lua-language-server`, `pyright`, `gopls`,
`kotlin-language-server`, `terraform-ls`, `rust-analyzer`, and `nixd`.
Formatting additionally expects `stylua`, `gofmt`, `ktlint`, `rustfmt`,
`clang-format`, and `terraform` on `PATH`.

The configured plugins also expect `lazygit`, `rg`, `fd`, `curl`, `jq`,
`pandoc`, `make`, a C compiler, OpenSSL, and SSH for their corresponding
features.

The macOS-only features require `macism`; the Yoshi animations require a
terminal that implements the Kitty graphics protocol.
