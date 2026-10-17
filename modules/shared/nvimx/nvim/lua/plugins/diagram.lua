return {
  {
    '3rd/image.nvim',
    build = false,
    opts = {
      backend = 'kitty',
      processor = 'magick_cli',
    },
  },
  {
    '3rd/diagram.nvim',
    dependencies = { '3rd/image.nvim' },
    ft = { 'markdown' },
    keys = {
      {
        '<leader>md',
        function()
          require('diagram').show_diagram_hover()
        end,
        desc = 'Show diagram',
        ft = { 'markdown' },
      },
    },
    opts = function()
      return {
        integrations = { require('diagram.integrations.markdown') },
        renderer_options = {
          d2 = {
            theme_id = 200,
            layout = 'elk',
            cli_args = { '--pad', '0' },
          },
        },
      }
    end,
  },
  {
    'terrastruct/d2-vim',
    ft = 'd2',
    init = function()
      vim.g.d2_fmt_autosave = 1
      vim.g.d2_ascii_mode = 'extended'
    end,
  },
}
