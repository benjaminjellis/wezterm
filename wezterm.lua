-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.use_fancy_tab_bar = false
config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font 'MartianMono Nerd Font'
config.font_size = 16.0
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
  left = 0,
  right = 0,
  top = 10,
  bottom = 0,
}
config.window_close_confirmation = "NeverPrompt"

-- and finally, return the configuration to wezterm
return config
