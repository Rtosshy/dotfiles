return {
  {
    "Saghen/blink.cmp",
    opts = function(_, opts)
      opts.keymap = opts.keymap or {}
      opts.keymap["<C-j>"] = { "select_next" }
      opts.keymap["<C-k>"] = { "select_prev" }
      opts.completion.list = opts.completion.list or {}
      opts.completion.list.selection = opts.completion.list.selection or {}
      opts.completion.list.selection.preselect = false
      opts.completion.list.selection.auto_insert = false
    end,
  },
}
