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

  local function delete_sequence()
    local chunks = {}
    for frame = 1, active.frame_count do
      chunks[#chunks + 1] = ('\27_Ga=d,d=i,i=%d,q=2\27\\'):format(image_id_base + frame)
    end
    return table.concat(chunks)
  end

  local function clear()
    canvas.send(delete_sequence())
  end

  local function draw(frame)
    local file = ('%s/%s%02d.png'):format(active.frame_dir, active.frame_prefix, frame - 1)
    local handle = io.open(file, 'rb')
    if not handle then
      vim.notify('Yoshi frame was not found: ' .. file, vim.log.levels.ERROR)
      return
    end
    handle:close()

    local row = opts.top_padding + opts.logo_line_count + opts.gap_after_logo + 1
    local col = math.max(0, math.floor((vim.o.columns - active.image_cols) / 2))
    canvas.send(table.concat({
      '\27[s',
      ('\27[%d;%dH'):format(row, col + 1),
      delete_sequence(),
      ('\27_Ga=T,t=f,f=100,i=%d,c=%d,r=%d,q=2;'):format(
        image_id_base + frame,
        active.image_cols,
        active.image_rows
      ),
      vim.base64.encode(file),
      '\27\\',
      '\27[u',
    }))
    apply_color(frame)
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
        clear()
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
      clear()
      return
    end
    if running then
      running = false
      generation = generation + 1
      clear()
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
