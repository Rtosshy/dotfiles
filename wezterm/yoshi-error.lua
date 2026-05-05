local wezterm = require('wezterm')

local M = {}

local yoshi_error_gif = os.getenv('HOME')
  .. '/ghq/github.com/Rtosshy/dotfiles/assets/gif/yoshi-angry.gif'
local yoshi_error_state = {}

local function with_yoshi_error_background(base_background)
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
    width = 160,
    height = 160,
    repeat_x = 'NoRepeat',
    repeat_y = 'NoRepeat',
    horizontal_align = 'Right',
    vertical_align = 'Bottom',
    -- horizontal_offset = -4,
    -- vertical_offset = -12,
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
    overrides.background = with_yoshi_error_background(state.background)
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
