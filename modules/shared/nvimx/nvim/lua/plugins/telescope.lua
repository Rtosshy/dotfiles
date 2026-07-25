return {
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
}
