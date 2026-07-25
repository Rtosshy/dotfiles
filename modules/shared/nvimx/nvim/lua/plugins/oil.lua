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
    config = function(_, opts)
      require('oil').setup(opts)
      require('oil-git-status').setup()
    end,
  },
}
