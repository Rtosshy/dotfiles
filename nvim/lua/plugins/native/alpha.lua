-- alpha-nvim config with colored Yoshi header
-- Place yoshi_header.lua in ~/.config/nvim/lua/yoshi_header.lua
-- Place this file as your alpha-nvim plugin spec

return {
  'goolord/alpha-nvim',
  dependencies = {
    'nvim-mini/mini.icons',
    'nvim-lua/plenary.nvim',
  },
  config = function()
    local alpha = require('alpha')
    local dashboard = require('alpha.themes.dashboard')
    local yoshi = require('yoshi_header2')

    -- Setup color highlight groups
    yoshi.setup_highlights()

    -- Set header
    dashboard.section.header.val = yoshi.header
    dashboard.section.header.opts = {
      hl = yoshi.hl,
      position = 'center',
    }

    alpha.setup(dashboard.config)
  end,
}
