return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    spec = {
      { '<leader>b', group = 'buffer' },
      { '<leader>d', group = 'diagnostics' },
      { '<leader>f', group = 'find' },
      { '<leader>g', group = 'git' },
      { '<leader>l', group = 'line' },
      { '<leader>s', group = 'save' },
      { '<leader>w', group = 'window' },
      { '<leader>ws', group = 'split' },
    },
  },
}
