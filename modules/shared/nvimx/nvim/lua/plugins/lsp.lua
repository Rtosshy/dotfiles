return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'saghen/blink.cmp',
      {
        'DrKJeff16/wezterm-types',
        commit = 'd8b1671db6de96e3c4e44ce5cfd1c9c31d3828bf',
        lazy = true,
      },
    },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local wezterm_plugin = require('lazy.core.config').plugins['wezterm-types']
      local wezterm_types = assert(
        wezterm_plugin and wezterm_plugin.dir,
        'wezterm-types plugin directory is unavailable'
      )
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { library = { wezterm_types } },
              diagnostics = { globals = { 'vim' } },
            },
          },
        },
        pyright = {},
        gopls = {},
        kotlin_language_server = {
          init_options = {
            storagePath = vim.fn.stdpath('cache') .. '/kotlin-language-server',
          },
        },
        terraformls = {},
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              check = { command = 'clippy' },
              cargo = { allFeatures = true },
            },
          },
        },
        nixd = {},
      }

      for name, config in pairs(servers) do
        config.capabilities =
          vim.tbl_deep_extend('force', {}, capabilities, config.capabilities or {})
        if vim.lsp.config and vim.lsp.enable then
          vim.lsp.config(name, config)
          vim.lsp.enable(name)
        else
          require('lspconfig')[name].setup(config)
        end
      end

      local group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = group,
        callback = function(args)
          local function lsp_map(key, action, desc)
            vim.keymap.set('n', key, action, { buffer = args.buf, silent = true, desc = desc })
          end
          lsp_map('gd', function()
            vim.cmd('Telescope lsp_definitions')
          end, 'LSP definitions (Telescope)')
          lsp_map('gD', vim.lsp.buf.declaration, 'LSP declaration')
          lsp_map('gri', function()
            vim.cmd('Telescope lsp_implementations')
          end, 'LSP implementations (Telescope)')
          lsp_map('grr', function()
            vim.cmd('Telescope lsp_references')
          end, 'LSP references (Telescope)')
          lsp_map('grt', function()
            vim.cmd('Telescope lsp_type_definitions')
          end, 'LSP type definitions (Telescope)')
          lsp_map('K', vim.lsp.buf.hover, 'LSP hover')
          lsp_map('grn', vim.lsp.buf.rename, 'LSP rename')
          lsp_map('gra', vim.lsp.buf.code_action, 'LSP code action')
        end,
      })

      vim.diagnostic.config({
        virtual_text = { prefix = '' },
        severity_sort = true,
        float = { source = true },
      })
    end,
    keys = {
      {
        '[d',
        function()
          vim.diagnostic.jump({ count = -1, float = true })
        end,
        desc = 'Go to previous diagnostic message',
      },
      {
        ']d',
        function()
          vim.diagnostic.jump({ count = 1, float = true })
        end,
        desc = 'Go to next diagnostic message',
      },
      { '<leader>df', vim.diagnostic.open_float, desc = 'Open floating diagnostic message' },
      { '<leader>dl', vim.diagnostic.setloclist, desc = 'Open diagnostics list' },
    },
  },
}
