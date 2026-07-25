return {
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    opts = {
      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
      lsp = {
        progress = { enabled = true },
        hover = { enabled = true },
        signature = { enabled = true },
      },
      routes = {
        { filter = { event = 'msg_show', find = 'written' }, opts = { skip = true } },
      },
      cmdline = {
        format = {
          shell = { pattern = '^:!', icon = '$', lang = 'bash' },
        },
      },
    },
  },
}
