return {
  'keaising/im-select.nvim',
  config = function()
    require('im_select').setup({
      default_command = 'macism',
      set_previous_events = {},
    })
    vim.keymap.set('n', '<Esc>', function()
      vim.system({ 'macism', 'com.apple.keylayout.ABC' })
    end)
  end,
}
