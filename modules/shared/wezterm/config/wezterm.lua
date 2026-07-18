local wezterm = require('wezterm') ---@type Wezterm
local keybinds = require('keybinds')
local yoshi_error = require('yoshi-error')
local config = wezterm.config_builder()

config.disable_default_key_bindings = true
config.keys = keybinds.keys
config.key_tables = keybinds.key_tables

config.automatically_reload_config = true
config.adjust_window_size_when_changing_font_size = false
config.font_size = 20.0
config.use_ime = true
config.enable_kitty_graphics = true
-- Required for kitty kittens (e.g. `kitten themes`) to receive key input.
-- WARNING: wezterm's kitty keyboard protocol has known bugs (AltGr/dead keys,
-- Esc handling in some TUI apps). If keys misbehave elsewhere, disable this first.
config.enable_kitty_keyboard = true
config.window_background_opacity = 0.15
if wezterm.target_triple:find('darwin') then
  config.macos_window_background_blur = 40
  config.send_composed_key_when_left_alt_is_pressed = false
  config.send_composed_key_when_right_alt_is_pressed = true
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
local BLANK_ARROW = '\u{00a0}'
local ACTIVE_TAB_BACKGROUND = '#9ece6a'

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local EDGE_WIDTH = 2 -- left + right arrow/space
  local PADDING_WIDTH = 6 -- left 3 + right 3
  local title_width = math.max(0, max_width - EDGE_WIDTH - PADDING_WIDTH)
  local title_text =
    wezterm.pad_right(wezterm.truncate_right(tab.active_pane.title, title_width), title_width)
  local title = '   ' .. title_text .. '   '
  if not tab.is_active then
    return {
      { Background = { Color = 'none' } },
      { Text = BLANK_ARROW },
      { Foreground = { Color = '#FFFFFF' } },
      { Text = title },
      { Background = { Color = 'none' } },
      { Text = BLANK_ARROW },
    }
  end

  return {
    { Background = { Color = 'none' } },
    { Foreground = { Color = ACTIVE_TAB_BACKGROUND } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = ACTIVE_TAB_BACKGROUND } },
    { Foreground = { Color = '#FFFFFF' } },
    { Text = title },
    { Background = { Color = 'none' } },
    { Foreground = { Color = ACTIVE_TAB_BACKGROUND } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

return config
