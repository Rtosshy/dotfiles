return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      highlight = { enable = true },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)

      pcall(vim.treesitter.start)
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}
