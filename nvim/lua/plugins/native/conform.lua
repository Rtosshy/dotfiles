return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          go = { 'gofmt' },
          cpp = { 'clang-format' },
          c = { 'clang-format' },
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
