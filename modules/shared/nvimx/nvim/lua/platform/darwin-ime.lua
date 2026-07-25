-- This platform module is imported as a lazy.nvim spec from config.lazy.
return {
  {
    'keaising/im-select.nvim',
    cond = vim.fn.has('mac') == 1,
    event = 'VeryLazy',
    init = function()
      vim.keymap.set('n', '<Esc>', function()
        vim.system({ 'macism', 'com.apple.keylayout.ABC' })
      end, { silent = true })
    end,
    opts = {
      default_command = 'macism',
      set_previous_events = {},
    },
  },
}
