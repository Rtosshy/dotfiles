return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          go = { 'gofmt' },
          python = { 'ruff_format' },
          javascript = { 'biome' },
          typescript = { 'biome' },
          javascriptreact = { 'biome' },
          typescriptreact = { 'biome' },
          json = { 'biome' },
          css = { 'biome' },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_format = 'fallback',
        },
      })

      vim.keymap.set('n', 'gq', function()
        require('conform').format({ async = true })
      end, { desc = 'Format' })
    end,
  },
}
