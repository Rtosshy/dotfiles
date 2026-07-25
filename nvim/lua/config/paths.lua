local uv = vim.uv or vim.loop
local config_dir = uv.fs_realpath(vim.fn.stdpath('config')) or vim.fn.stdpath('config')

return {
  repo = vim.fn.fnamemodify(config_dir, ':h'),
  asset = function(relative)
    return vim.fn.fnamemodify(config_dir, ':h') .. '/assets/' .. relative
  end,
}
