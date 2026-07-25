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
vim.api.nvim_create_autocmd({ 'VimResized', 'WinResized' }, {
  group = vim.api.nvim_create_augroup('YoshiErrorAnimation', { clear = true }),
  callback = angry.stop,
})
