# Neovim configuration

This directory contains the nixvim-based Neovim configuration.

`default.nix` is the entry point imported from `modules/shared/cli/default.nix`.
It enables `programs.nixvim` and imports the smaller modules below.

## Core

- `core/options.nix`: global leader keys, standard Neovim options, and early Lua
  setup such as `shortmess`, `iskeyword`, terminal underline escape sequences,
  and LuaRocks package path.
- `core/autocmds.nix`: general autocmds for paste mode cleanup, JSON display
  behavior, and C/C++ indentation.
- `core/keymaps.nix`: plugin-independent keymaps for save/quit, scrolling,
  search result centering, buffer navigation, window splitting/resizing, and
  visual-mode editing.

## Plugins

- `plugins/ui.nix`: colorscheme, icons, bufferline, lualine, which-key groups,
  smear-cursor, and snacks.
- `plugins/oil.nix`: oil.nvim enablement, `<leader>e`, hidden file display, and
  oil buffer keymaps.
- `plugins/telescope.nix`: Telescope, fzf-native extension, and file/search/help
  keymaps.
- `plugins/treesitter.nix`: Treesitter enablement, parser list, and the FileType
  autocmd that starts Treesitter.
- `plugins/lsp.nix`: LSP servers, `LspAttach` keymaps, diagnostic keymaps, and
  diagnostic display settings.
- `plugins/formatting.nix`: conform.nvim formatter settings, format-on-save, and
  the manual `gq` format keymap.
- `plugins/trouble.nix`: trouble.nvim enablement and diagnostics/symbols/list
  keymaps.
- `plugins/lazygit.nix`: lazygit.nvim enablement and `<leader>gg`.
- `plugins/devdocs.nix`: devdocs.nvim manual plugin loading, DevDocs keymaps,
  lazy setup function, and `DevDocs` user command wrapper.
- `plugins/alpha.nix`: alpha.nvim dashboard, dashboard buttons, YOSHI VIM header,
  and the Yoshi image animation.

## Platform

- `platform/darwin-ime.nix`: macOS IME integration through `macism` and
  im-select.nvim, including the `<Esc>` keymap that switches input source to ABC.
  It is guarded with `pkgs.stdenv.isDarwin`.
