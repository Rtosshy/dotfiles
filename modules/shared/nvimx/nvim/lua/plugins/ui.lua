return {
  {
    'scottmckendry/cyberdream.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = { sidebars = 'transparent', floats = 'transparent' },
      highlights = {
        FloatBorder = { fg = '#ffffff' },
        BlinkCmpMenuBorder = { fg = '#ffffff' },
        BlinkCmpDocBorder = { fg = '#ffffff' },
        BlinkCmpSignatureHelpBorder = { fg = '#ffffff' },
        TelescopeBorder = { fg = '#ffffff' },
      },
    },
    config = function(_, opts)
      require('cyberdream').setup(opts)
      vim.cmd.colorscheme('cyberdream')
    end,
  },
  { 'nvim-tree/nvim-web-devicons', lazy = true },
  {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = { theme = 'cyberdream' },
      sections = {
        lualine_x = {
          {
            function()
              local reg = vim.fn.reg_recording()
              return reg ~= '' and ('● REC @' .. reg) or ''
            end,
            color = { fg = '#ff6e5e' },
          },
          'encoding',
          'fileformat',
          'filetype',
        },
      },
    },
    config = function(_, opts)
      require('lualine').setup(opts)
      vim.api.nvim_create_autocmd('RecordingEnter', {
        callback = function()
          require('lualine').refresh()
        end,
      })
      vim.api.nvim_create_autocmd('RecordingLeave', {
        callback = function()
          vim.defer_fn(function()
            require('lualine').refresh()
          end, 50)
        end,
      })
    end,
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      triggers = {
        { '<auto>', mode = 'nxso' },
        { 'q', mode = 'n' },
        { '@', mode = 'n' },
      },
      spec = {
        { '<leader>b', group = 'buffer' },
        { '<leader>d', group = 'diagnostics' },
        { '<leader>f', group = 'find' },
        { '<leader>g', group = 'git' },
        { '<leader>gd', group = 'git diff' },
        { '<leader>h', group = 'help' },
        { '<leader>l', group = 'line' },
        { '<leader>s', group = 'save' },
        { '<leader>w', group = 'window' },
        {
          'q',
          mode = 'n',
          group = 'record macro',
          expand = function()
            local items = {}
            for i = string.byte('a'), string.byte('z') do
              local reg = string.char(i)
              local content = vim.fn.getreg(reg)
              items[#items + 1] = {
                reg,
                function()
                  vim.api.nvim_feedkeys('q' .. reg, 'nit', false)
                end,
                desc = content == '' and '(empty)' or vim.fn.keytrans(content):sub(1, 40),
              }
            end
            return items
          end,
        },
        {
          '@',
          mode = 'n',
          group = 'play macro',
          expand = function()
            local items = {}
            for i = string.byte('a'), string.byte('z') do
              local reg = string.char(i)
              local content = vim.fn.getreg(reg)
              if content ~= '' then
                items[#items + 1] = {
                  reg,
                  function()
                    local count = vim.v.count > 0 and tostring(vim.v.count) or ''
                    vim.api.nvim_feedkeys(count .. '@' .. reg, 'nit', false)
                  end,
                  desc = vim.fn.keytrans(content):sub(1, 40),
                }
              end
            end
            return items
          end,
        },
      },
    },
  },
  {
    'sphamba/smear-cursor.nvim',
    event = 'VeryLazy',
    opts = {},
  },
}
