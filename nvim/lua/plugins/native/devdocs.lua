return {
  'maskudo/devdocs.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  cmd = { 'DevDocs' },
  keys = {
    {
      '<leader>ho',
      '<cmd>DevDocs get<cr>',
      mode = 'n',
      desc = 'Open DevDocs',
    },
    {
      '<leader>hi',
      '<cmd>DevDocs install<cr>',
      mode = 'n',
      desc = 'Install DevDocs',
    },
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
          require('telescope.builtin').find_files({ cwd = doc_dir })
        end)
      end,
      mode = 'n',
      desc = 'View DevDocs',
    },
    {
      '<leader>hd',
      '<cmd>DevDocs delete<cr>',
      mode = 'n',
      desc = 'Delete DevDocs',
    },
  },
  opts = {
    ensure_installed = {
      'go',
      'html',
      'http',
      'lua~5.1',
    },
  },
}
