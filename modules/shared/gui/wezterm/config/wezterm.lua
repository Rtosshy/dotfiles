local wezterm = require('wezterm')
local keybinds = require('keybinds')
local yoshi_error = require('yoshi-error')
local config = wezterm.config_builder()

config.keys = keybinds.keys

config.automatically_reload_config = true
config.font_size = 14.0
config.use_ime = true
config.window_background_opacity = 0.65
if wezterm.target_triple:find('darwin') then
  config.macos_window_background_blur = 20
end
config.window_decorations = 'RESIZE'
config.hide_tab_bar_if_only_one_tab = true
config.color_scheme = 'Tokyo Night'
config.window_frame = {
  inactive_titlebar_bg = 'none',
  active_titlebar_bg = 'none',
}
config.font = wezterm.font_with_fallback({
  { family = 'JetBrains Mono', weight = 'Bold' },
  { family = 'PlemolJP Console NF', weight = 'Medium' },
})
config.window_background_gradient = {
  colors = { '#1a1b26' },
}

yoshi_error.setup()
config.show_new_tab_button_in_tab_bar = false
-- `show_close_tab_button_in_tabs` is only available in nightly builds.
pcall(function()
  config.show_close_tab_button_in_tabs = false
end)
config.colors = {
  tab_bar = {
    inactive_tab_edge = 'none',
  },
}
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local background = '#5c6d74'
  local foreground = '#FFFFFF'
  local edge_background = 'none'
  if tab.is_active then
    background = '#7aa2f7'
    foreground = '#FFFFFF'
  end
  local edge_foreground = background
  local title = '   ' .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. '   '
  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

return config
