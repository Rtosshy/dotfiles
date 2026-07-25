local paths = require('config.paths')
local yoshi = require('config.yoshi')

local egg = yoshi.animation({
  frame_dir = paths.asset('frames/yoshi-egg'),
  frame_prefix = 'yoshi-egg-',
  frame_count = 44,
  frame_delay_ms = 40,
  image_cols = 20,
  image_rows = 11,
  image_id_base = 436000,
  cooldown_ms = 250,
})

local function put_with_yoshi(keys)
  return function()
    vim.defer_fn(egg.play, 20)
    return keys
  end
end

vim.api.nvim_create_user_command('YoshiEgg', egg.play, {})
for _, key in ipairs({ 'p', 'P', 'gp', 'gP' }) do
  vim.keymap.set({ 'n', 'x' }, key, put_with_yoshi(key), { silent = true, expr = true })
end

vim.api.nvim_create_autocmd({ 'VimResized', 'WinResized' }, {
  group = vim.api.nvim_create_augroup('YoshiPasteAnimation', { clear = true }),
  callback = egg.stop,
})
