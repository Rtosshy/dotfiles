return {
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
