if vim.fn.has('mac') ~= 1 then
  return
end

local paths = require('config.paths')
local yoshi = require('config.yoshi')

local angry = yoshi.animation({
  frame_dir = paths.asset('frames/yoshi-angry'),
  frame_prefix = 'yoshi-angry-',
  frame_count = 38,
  frame_delay_ms = 60,
  image_cols = 14,
  image_rows = 7,
  image_id_base = 434343,
  cooldown_ms = 3000,
})
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
  if level == vim.log.levels.ERROR then
    vim.schedule(angry.play)
  end
  return original_notify(msg, level, opts)
end
local last_errmsg = ''
local errmsg_timer = (vim.uv or vim.loop).new_timer()
errmsg_timer:start(
  0,
  250,
  vim.schedule_wrap(function()
    local current = vim.v.errmsg or ''
    if current ~= '' and current ~= last_errmsg then
      last_errmsg = current
      angry.play()
    elseif current == '' then
      last_errmsg = ''
    end
  end)
)
vim.api.nvim_create_user_command('YoshiAngry', angry.play, {})

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
  group = vim.api.nvim_create_augroup('YoshiAnimations', { clear = true }),
  callback = function()
    angry.stop()
    egg.stop()
    eat.stop()
  end,
})
