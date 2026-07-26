return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    config = function()
      local plugin = require('lazy.core.config').plugins['nvim-treesitter']
      local runtime = assert(
        plugin and plugin.dir,
        'nvim-treesitter plugin directory is unavailable'
      ) .. '/runtime'
      vim.opt.runtimepath:append(runtime)

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}
