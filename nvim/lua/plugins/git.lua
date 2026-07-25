local signs = {
  add = { text = '┃' },
  change = { text = '┃' },
  delete = { text = '_' },
  topdelete = { text = '‾' },
  changedelete = { text = '~' },
  untracked = { text = '┆' },
}

return {
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {
      {
        ']c',
        function()
          if vim.wo.diff then
            vim.cmd.normal({ args = { ']c' }, bang = true })
          else
            require('gitsigns').nav_hunk('next')
          end
        end,
        desc = 'Git next hunk',
      },
      {
        '[c',
        function()
          if vim.wo.diff then
            vim.cmd.normal({ args = { '[c' }, bang = true })
          else
            require('gitsigns').nav_hunk('prev')
          end
        end,
        desc = 'Git previous hunk',
      },
      { '<leader>gsp', '<cmd>Gitsigns preview_hunk_inline<cr>', desc = 'Git preview hunk inline' },
      { '<leader>gsP', '<cmd>Gitsigns preview_hunk<cr>', desc = 'Git preview hunk popup' },
      { '<leader>gsr', '<cmd>Gitsigns reset_hunk<cr>', desc = 'Git reset hunk' },
      { '<leader>gsR', '<cmd>Gitsigns reset_buffer<cr>', desc = 'Git reset buffer' },
    },
    opts = {
      signs = signs,
      signs_staged = signs,
      signs_staged_enable = true,
      signcolumn = true,
      numhl = false,
      linehl = false,
      word_diff = false,
      watch_gitdir = { follow_files = true },
      auto_attach = true,
      attach_to_untracked = false,
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
        use_focus = true,
      },
      current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
      sign_priority = 6,
      update_debounce = 100,
      max_file_length = 40000,
      preview_config = {
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1,
      },
    },
  },
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
  {
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitLog',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
      'LazyGitConfig',
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
  },
}
