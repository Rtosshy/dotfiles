local wezterm = require('wezterm')

local M = {}

local yoshi_error_gif = os.getenv('HOME')
  .. '/ghq/github.com/Rtosshy/dotfiles/assets/gif/yoshi-angry.gif'
local yoshi_error_state = {}
local yoshi_error_margin = {
  right = 4,
  bottom = 12,
}
local yoshi_error_base_size = 160
local yoshi_error_max_size = 320
local yoshi_error_pane_ratio = 0.28

local function pane_yoshi_error_size(pane_info)
  local available_width = math.max(0, pane_info.pixel_width - yoshi_error_margin.right)
  local available_height = math.max(0, pane_info.pixel_height - yoshi_error_margin.bottom)
  local available_size = math.min(available_width, available_height)
  local desired_size =
    math.max(yoshi_error_base_size, math.floor(available_size * yoshi_error_pane_ratio))
  local size = math.floor(math.min(yoshi_error_max_size, available_size, desired_size))

  if size <= 0 then
    return nil
  end

  return size
end

local function pane_background_geometry(pane)
  local ok, panes = pcall(function()
    return pane:tab():panes_with_info()
  end)
  if not ok then
    return nil
  end

  local pane_id = pane:pane_id()
  local active_info = nil
  for _, info in ipairs(panes) do
    if info.pane:pane_id() == pane_id then
      active_info = info
      break
    end
  end
  if not active_info or active_info.width == 0 or active_info.height == 0 then
    return nil
  end

  local cell_width = active_info.pixel_width / active_info.width
  local cell_height = active_info.pixel_height / active_info.height
  local tab_right = 0
  local tab_bottom = 0
  for _, info in ipairs(panes) do
    tab_right = math.max(tab_right, math.floor(info.left * cell_width + info.pixel_width))
    tab_bottom = math.max(tab_bottom, math.floor(info.top * cell_height + info.pixel_height))
  end

  local pane_right = math.floor(active_info.left * cell_width + active_info.pixel_width)
  local pane_bottom = math.floor(active_info.top * cell_height + active_info.pixel_height)

  local size = pane_yoshi_error_size(active_info)
  if not size then
    return nil
  end

  return {
    horizontal = pane_right - tab_right - yoshi_error_margin.right,
    vertical = pane_bottom - tab_bottom - yoshi_error_margin.bottom,
    size = size,
  }
end

local function with_yoshi_error_background(base_background, geometry)
  local background = {}
  if base_background then
    for _, layer in ipairs(base_background) do
      table.insert(background, layer)
    end
  end

  table.insert(background, {
    source = {
      File = {
        path = yoshi_error_gif,
        speed = 1.0,
      },
    },
    width = geometry and geometry.size or yoshi_error_base_size,
    height = geometry and geometry.size or yoshi_error_base_size,
    repeat_x = 'NoRepeat',
    repeat_y = 'NoRepeat',
    horizontal_align = 'Right',
    vertical_align = 'Bottom',
    horizontal_offset = geometry and geometry.horizontal or -yoshi_error_margin.right,
    vertical_offset = geometry and geometry.vertical or -yoshi_error_margin.bottom,
  })

  return background
end

function M.setup()
  wezterm.on('user-var-changed', function(window, pane, name, value)
    if name ~= 'YOSHI_ERROR' or value == '' then
      return
    end

    local window_id = window:window_id()
    local overrides = window:get_config_overrides() or {}
    local state = yoshi_error_state[window_id]
    if not state then
      state = {
        background = overrides.background,
      }
      yoshi_error_state[window_id] = state
    end

    state.nonce = value
    overrides.background =
      with_yoshi_error_background(state.background, pane_background_geometry(pane))
    window:set_config_overrides(overrides)

    wezterm.time.call_after(1.8, function()
      local current_state = yoshi_error_state[window_id]
      if not current_state or current_state.nonce ~= value then
        return
      end

      local current_overrides = window:get_config_overrides() or {}
      current_overrides.background = current_state.background
      window:set_config_overrides(current_overrides)
      yoshi_error_state[window_id] = nil
    end)
  end)
end

return M
