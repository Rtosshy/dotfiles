return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = 'ConformInfo',
    keys = {
      {
        'gq',
        function()
          require('conform').format({ async = true })
        end,
        desc = 'Format',
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        go = { 'gofmt' },
        kotlin = { 'ktlint' },
        rust = { 'rustfmt' },
        haskell = { 'ormolu' },
        cpp = { 'clang-format' },
        c = { 'clang-format' },
        terraform = { 'terraform_fmt' },
        ['terraform-vars'] = { 'terraform_fmt' },
      },
      format_on_save = { timeout_ms = 500, lsp_format = 'fallback' },
    },
  },
}
