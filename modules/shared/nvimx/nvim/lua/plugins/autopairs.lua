return {
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      check_ts = true,
      ts_config = { lua = { 'string' }, javascript = { 'template_string' } },
      disable_filetype = { 'TelescopePrompt' },
      enable_check_bracket_line = true,
      enable_moveright = true,
      map_bs = true,
      map_c_h = false,
      map_c_w = false,
    },
  },
}
