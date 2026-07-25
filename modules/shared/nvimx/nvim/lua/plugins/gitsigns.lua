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
}
