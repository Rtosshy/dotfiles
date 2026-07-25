local paths = require('config.paths')
local yoshi = require('config.yoshi')

local eat = yoshi.animation({
  frame_dir = paths.asset('frames/yoshi-eat'),
  frame_prefix = 'yoshi-eat-',
  frame_count = 38,
  frame_delay_ms = 40,
  image_cols = 23,
  image_rows = 9,
  image_id_base = 435000,
  cooldown_ms = 250,
})

vim.api.nvim_create_user_command('YoshiEat', eat.play, {})
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('YoshiYankAnimation', { clear = true }),
  callback = function()
    if vim.v.event.operator == 'y' then
      eat.play()
    end
  end,
})
vim.api.nvim_create_autocmd({ 'VimResized', 'WinResized' }, {
  group = vim.api.nvim_create_augroup('YoshiYankResize', { clear = true }),
  callback = eat.stop,
})
