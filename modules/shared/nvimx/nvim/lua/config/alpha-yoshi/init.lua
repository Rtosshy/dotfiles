local M = {}

local uv = vim.uv or vim.loop

local presets = require('config.alpha-yoshi.presets')
local selector = require('config.alpha-yoshi.selector')
local canvas = require('config.alpha-yoshi.canvas')
local animated = require('config.alpha-yoshi.renderer.animated')
local static = require('config.alpha-yoshi.renderer.static')

---@param opts AlphaYoshiSetupOptions
function M.setup(opts)
  -- Initialized by reroll() before the renderer starts.
  ---@type AlphaYoshiPreset
  local active

  local static_image = uv.os_uname().sysname == 'Linux'

  ---@type AlphaYoshiLayout
  local layout = {
    top_padding = opts.top_padding,
    logo_line_count = opts.logo_line_count,
    gap_after_logo = opts.gap_after_logo,
  }

  ---@type AlphaYoshiRenderer
  local renderer

  local function reroll()
    active = selector.weighted(presets)
    renderer:reset()
  end

  local function apply_color(frame)
    vim.api.nvim_set_hl(0, 'AlphaYoshiLogo', {
      fg = active.colors[frame] or active.colors[1],
      bold = true,
    })
  end

  local function draw(frame)
    if canvas.draw(active, frame, layout) then
      apply_color(frame)
    end
  end

  local context = {
    draw = draw,
    clear = function()
      canvas.clear(active.frame_count)
    end,
    frame_count = function()
      return active.frame_count
    end,
    frame_delay_ms = function()
      return active.frame_delay_ms
    end,
    is_active = function()
      return vim.bo.filetype == 'alpha'
    end,
  }

  if static_image then
    renderer = static.new(context)
  else
    renderer = animated.new(context)
  end

  local function start()
    renderer:start()
  end

  local function stop()
    renderer:stop()
  end

  local active_buffer

  local function defer_start(buffer, delay)
    vim.defer_fn(function()
      if active_buffer == buffer and vim.api.nvim_get_current_buf() == buffer then
        start()
      end
    end, delay)
  end

  local function activate()
    if vim.bo.filetype ~= 'alpha' then
      return
    end

    local buffer = vim.api.nvim_get_current_buf()
    active_buffer = buffer

    reroll()
    apply_color(1)
    defer_start(buffer, 80)
  end

  local function deactivate(args)
    if active_buffer ~= args.buf then
      return
    end

    stop()
    active_buffer = nil
  end

  local function redraw()
    local buffer = vim.api.nvim_get_current_buf()
    if active_buffer ~= buffer then
      return
    end

    pcall(opts.redraw)
    defer_start(buffer, 160)
  end

  local group = vim.api.nvim_create_augroup('AlphaYoshiImage', { clear = true })
  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'AlphaReady',
    callback = activate,
  })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = activate,
  })
  vim.api.nvim_create_autocmd('BufLeave', {
    group = group,
    callback = deactivate,
  })
  vim.api.nvim_create_autocmd({ 'VimResized', 'WinResized' }, {
    group = group,
    callback = redraw,
  })
end

return M
