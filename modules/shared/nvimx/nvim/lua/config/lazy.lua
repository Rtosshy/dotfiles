local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local result = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error('Failed to install lazy.nvim:\n' .. result)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = {
    { import = 'plugins' },
    { import = 'platform.darwin-ime' },
  },
  install = { colorscheme = { 'cyberdream' } },
  checker = { enabled = false },
  change_detection = { notify = false },
})
