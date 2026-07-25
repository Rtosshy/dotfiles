return {
  {
    'stevearc/oil.nvim',
    cmd = 'Oil',
    keys = {
      {
        '<leader>e',
        function()
          require('oil').toggle_float()
        end,
        desc = 'Oil file explorer',
      },
    },
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      {
        'refractalize/oil-git-status.nvim',
        opts = {},
      },
    },
    opts = {
      view_options = { show_hidden = true },
      win_options = { signcolumn = 'yes:2' },
      keymaps = {
        ['g?'] = { 'actions.show_help', mode = 'n' },
        ['<CR>'] = 'actions.select',
        ['<C-s>'] = { 'actions.select', opts = { vertical = true } },
        ['<C-h>'] = { 'actions.select', opts = { horizontal = true } },
        ['<C-t>'] = { 'actions.select', opts = { tab = true } },
        ['<C-p>'] = 'actions.preview',
        ['<C-c>'] = { 'actions.close', mode = 'n' },
        ['<C-l>'] = 'actions.refresh',
        ['-'] = { 'actions.parent', mode = 'n' },
        ['_'] = { 'actions.open_cwd', mode = 'n' },
        ['`'] = { 'actions.cd', mode = 'n' },
        ['g~'] = { 'actions.cd', opts = { scope = 'tab' }, mode = 'n' },
        ['gs'] = { 'actions.change_sort', mode = 'n' },
        ['gx'] = 'actions.open_external',
        ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
        ['g\\'] = { 'actions.toggle_trash', mode = 'n' },
      },
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files hidden=true<cr>', desc = 'Telescope find files' },
      { '<leader>fg', '<cmd>Telescope live_grep hidden=true<cr>', desc = 'Telescope live grep' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Telescope buffers' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Telescope help tags' },
      { '<leader>fG', '<cmd>Telescope git_status<cr>', desc = 'Telescope git status' },
      {
        '<leader>fl',
        function()
          require('telescope.builtin').live_grep({
            additional_args = function()
              return { '--hidden', '--fixed-strings' }
            end,
          })
        end,
        desc = 'Telescope live grep literal',
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
    opts = {
      pickers = {
        find_files = { hidden = true },
        live_grep = { additional_args = { '--hidden' } },
      },
      extensions = { fzf = {} },
    },
    config = function(_, opts)
      local telescope = require('telescope')
      telescope.setup(opts)
      pcall(telescope.load_extension, 'fzf')
    end,
  },
  {
    'folke/flash.nvim',
    keys = {
      {
        's',
        function()
          require('flash').jump()
        end,
        mode = { 'n', 'x' },
        desc = 'Flash jump',
      },
    },
    opts = {
      label = { before = true, after = false, style = 'inline' },
      modes = { search = { enabled = true } },
    },
  },
}
