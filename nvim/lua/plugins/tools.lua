return {
  {
    'maskudo/devdocs.nvim',
    cmd = 'DevDocs',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    keys = {
      { '<leader>ho', '<cmd>DevDocs get<cr>', desc = 'Open DevDocs' },
      { '<leader>hi', '<cmd>DevDocs install<cr>', desc = 'Install DevDocs' },
      {
        '<leader>hv',
        function()
          local devdocs = require('devdocs')
          local installed_docs = devdocs.GetInstalledDocs()
          vim.ui.select(installed_docs, {}, function(selected)
            if not selected then
              return
            end
            local doc_dir = devdocs.GetDocDir(selected)
            vim.cmd('Telescope find_files cwd=' .. vim.fn.fnameescape(doc_dir))
          end)
        end,
        desc = 'View DevDocs',
      },
      { '<leader>hd', '<cmd>DevDocs delete<cr>', desc = 'Delete DevDocs' },
    },
    opts = {
      ensure_installed = { 'go', 'html', 'http', 'lua~5.1' },
    },
  },
  {
    'azratul/live-share.nvim',
    cmd = { 'LiveShareHostStart', 'LiveShareJoin', 'LiveShareServer' },
    opts = {
      username = 'tosshy',
      port = 80,
      transport = 'ws',
    },
  },
  {
    'keaising/im-select.nvim',
    cond = vim.fn.has('mac') == 1,
    event = 'VeryLazy',
    opts = {
      default_command = 'macism',
      set_previous_events = {},
    },
  },
}
