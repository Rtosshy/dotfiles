return {
  {
    'goolord/alpha-nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')
      local logo = {
        [[ ██╗   ██╗  ██████╗  ███████╗ ██╗  ██╗ ██╗ ██╗   ██╗ ██╗ ███╗   ███╗]],
        [[ ╚██╗ ██╔╝ ██╔═══██╗ ██╔════╝ ██║  ██║ ██║ ██║   ██║ ██║ ████╗ ████║]],
        [[  ╚████╔╝  ██║   ██║ ███████╗ ███████║ ██║ ██║   ██║ ██║ ██╔████╔██║]],
        [[   ╚██╔╝   ██║   ██║ ╚════██║ ██╔══██║ ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║]],
        [[    ██║    ╚██████╔╝ ███████║ ██║  ██║ ██║  ╚████╔╝  ██║ ██║ ╚═╝ ██║]],
        [[    ╚═╝     ╚═════╝  ╚══════╝ ╚═╝  ╚═╝ ╚═╝   ╚═══╝   ╚═╝ ╚═╝     ╚═╝]],
      }
      local top_padding = 2
      local gap_after_logo = 1

      dashboard.section.buttons.val = {
        dashboard.button('e', '󰉋  Open directory', "<cmd>lua require('oil').toggle_float()<cr>"),
        dashboard.button('f', '  Find file', '<cmd>Telescope find_files hidden=true<cr>'),
        dashboard.button('r', '  Recent files', '<cmd>Telescope oldfiles<cr>'),
        dashboard.button('g', '󰊢  LazyGit', '<cmd>LazyGit<cr>'),
        dashboard.button('q', '  Quit', '<cmd>qa<cr>'),
      }
      dashboard.section.header.val = logo
      dashboard.section.header.opts = { hl = 'AlphaYoshiLogo', position = 'center' }
      dashboard.config.layout = {
        { type = 'padding', val = top_padding },
        dashboard.section.header,
        { type = 'padding', val = 18 },
        dashboard.section.buttons,
      }
      alpha.setup(dashboard.config)
      require('config.alpha-yoshi').setup({
        redraw = alpha.redraw,
        logo_line_count = #logo,
        top_padding = top_padding,
        gap_after_logo = gap_after_logo,
      })
    end,
  },
}
