local M = {}

local uv = vim.uv or vim.loop

local presets = require('config.alpha-yoshi.presets')
local selector = require('config.alpha-yoshi.selector')
local canvas = require('config.alpha-yoshi.canvas')
local animated = require('config.alpha-yoshi.renderer.animated')

---@param opts AlphaYoshiSetupOptions
function M.setup(opts)
  local active = selector.weighted(presets)
  local current_frame = 1
  local static_image = uv.os_uname().sysname == 'Linux'

  ---@type AlphaYoshiLayout
  local layout = {
    top_padding = opts.top_padding,
    logo_line_count = opts.logo_line_count,
    gap_after_logo = opts.gap_after_logo,
  }

  ---@type AlphaYoshiRenderer
  local animated_renderer

  local function reroll()
    active = selector.weighted(presets)
    current_frame = 1
    animated_renderer:reset()
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

  animated_renderer = animated.new({
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
  })

  local function start()
    if static_image then
      draw(current_frame)
      return
    end
    animated_renderer:start()
  end

  local function stop()
    if static_image then
      canvas.clear(active.frame_count)
      return
    end
    animated_renderer:stop()
  end

  apply_color(current_frame)

  local group = vim.api.nvim_create_augroup('AlphaYoshiImage', { clear = true })
  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'AlphaReady',
    callback = function()
      reroll()
      apply_color(current_frame)
      vim.defer_fn(start, 80)
    end,
  })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = function()
      if vim.bo.filetype ~= 'alpha' then
        return
      end
      reroll()
      apply_color(current_frame)
      vim.defer_fn(function()
        if vim.bo.filetype == 'alpha' then
          start()
        end
      end, 80)
    end,
  })
  vim.api.nvim_create_autocmd('BufLeave', { group = group, callback = stop })
  vim.api.nvim_create_autocmd({ 'VimResized', 'WinResized' }, {
    group = group,
    callback = function()
      if vim.bo.filetype == 'alpha' then
        pcall(opts.redraw)
        vim.defer_fn(start, 160)
      end
    end,
  })
end

return M
