return {
  "nwiizo/marp.nvim",
  ft = "markdown",
  config = function()
    require("marp").setup {
      -- options
      marp_command = "marp", -- default: "marp"
      browser = nil, -- auto detection
      server_mode = false, -- use watch mode(-w)
    }
  end,
}
