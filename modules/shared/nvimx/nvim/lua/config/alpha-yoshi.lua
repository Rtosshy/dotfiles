local M = {}

local uv = vim.uv or vim.loop

local image_id_base = 424242
local presets = require('config.alpha-yoshi.presets')
local selector = require('config.alpha-yoshi.selector')
local canvas = require('config.alpha-yoshi.canvas')

---@param opts { alpha: table, logo_line_count: integer, top_padding: integer, gap_after_logo: integer }
function M.setup(opts)
  local active = selector.weighted(presets)
  local current_frame = 1
  local running = false
  local generation = 0
  local static_image = uv.os_uname().sysname == 'Linux'
  local layout = {
    top_padding = opts.top_padding,
    logo_line_count = opts.logo_line_count,
    gap_after_logo = opts.gap_after_logo,
  }

  local function reroll()
    active = selector.weighted(presets)
    current_frame = 1
  end

  local function apply_color(frame)
    vim.api.nvim_set_hl(0, 'AlphaYoshiLogo', {
      fg = active.colors[frame] or active.colors[1],
      bold = true,
    })
  end

  local function draw(frame)
    if canvas.draw(active, frame, layout, image_id_base) then
      apply_color(frame)
    end
  end

  local function start()
    if static_image then
      draw(current_frame)
      return
    end
    if running then
      return
    end

    running = true
    generation = generation + 1
    local current_generation = generation
    local function tick()
      if current_generation ~= generation then
        return
      end
      if vim.bo.filetype ~= 'alpha' then
        running = false
        generation = generation + 1
        canvas.clear(active.frame_count, image_id_base)
        return
      end

      draw(current_frame)
      current_frame = (current_frame % active.frame_count) + 1
      vim.defer_fn(tick, active.frame_delay_ms)
    end
    tick()
  end

  local function stop()
    if static_image then
      canvas.clear(active.frame_count, image_id_base)
      return
    end
    if running then
      running = false
      generation = generation + 1
      canvas.clear(active.frame_count, image_id_base)
    end
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
        pcall(opts.alpha.redraw)
        vim.defer_fn(start, 160)
      end
    end,
  })
end

return M
