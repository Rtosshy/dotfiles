return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      ensure_installed = {
        'lua',
        'go',
        'rust',
        'yaml',
        'bash',
        'fish',
        'c',
        'cpp',
        'nix',
        'terraform',
      },
      highlight = { enable = true },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
  {
    'saghen/blink.cmp',
    version = '1.*',
    event = 'InsertEnter',
    dependencies = { 'rafamadriz/friendly-snippets' },
    opts = {
      completion = {
        list = { selection = { preselect = false, auto_insert = false } },
        documentation = { auto_show = true },
      },
      keymap = {
        preset = 'none',
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-Space>'] = { 'show' },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<Tab>'] = { 'select_and_accept', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
      },
      sources = {
        default = { 'lsp', 'snippets', 'path', 'buffer' },
        min_keyword_length = 1,
      },
    },
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      check_ts = true,
      ts_config = { lua = { 'string' }, javascript = { 'template_string' } },
      disable_filetype = { 'TelescopePrompt' },
      enable_check_bracket_line = true,
      enable_moveright = true,
      map_bs = true,
      map_c_h = false,
      map_c_w = false,
    },
  },
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
        cpp = { 'clang-format' },
        c = { 'clang-format' },
        terraform = { 'terraform_fmt' },
        ['terraform-vars'] = { 'terraform_fmt' },
      },
      format_on_save = { timeout_ms = 500, lsp_format = 'fallback' },
    },
  },
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      { '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols (Trouble)' },
      {
        '<leader>cl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      { '<leader>xL', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List (Trouble)' },
      { '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List (Trouble)' },
    },
    opts = {},
  },
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    event = 'VeryLazy',
    opts = {
      direction = 'float',
      open_mapping = '[[<c-]>]]',
    },
  },
}
