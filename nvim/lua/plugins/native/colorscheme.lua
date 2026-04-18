return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('tokyonight')
    end,
  },
  { 'rebelot/kanagawa.nvim', lazy = true },
  { 'catppuccin/nvim', name = 'catppuccin', lazy = true },
  { 'sainnhe/gruvbox-material', lazy = true },
  { 'rose-pine/neovim', name = 'rose-pine', lazy = true },
  { 'sainnhe/everforest', lazy = true },
  { 'EdenEast/nightfox.nvim', lazy = true },
  { 'craftzdog/solarized-osaka.nvim', lazy = true },
}
