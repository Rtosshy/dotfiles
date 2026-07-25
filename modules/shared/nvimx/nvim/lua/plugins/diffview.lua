return {
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>gdo', '<cmd>DiffviewOpen<cr>', desc = 'Git diff open' },
      { '<leader>gdc', '<cmd>DiffviewClose<cr>', desc = 'Git diff close' },
      { '<leader>gdf', '<cmd>DiffviewFileHistory %<cr>', desc = 'Git diff current file history' },
      { '<leader>gdh', '<cmd>DiffviewFileHistory<cr>', desc = 'Git diff repository history' },
      {
        '<leader>gdr',
        function()
          if not vim.wo.diff then
            vim.notify('Git diff restore hunk is only available in diff mode', vim.log.levels.WARN)
            return
          end
          vim.cmd.diffget()
        end,
        desc = 'Git diff restore hunk',
      },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = { layout = 'diff2_horizontal', winbar_info = true },
        file_history = { layout = 'diff2_horizontal', winbar_info = true },
      },
      file_panel = {
        listing_style = 'tree',
        win_config = { position = 'left', width = 35 },
      },
    },
  },
}
