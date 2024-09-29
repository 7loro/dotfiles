local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("D2CodingLigature Nerd Font")
config.font_size = 19

-- config.enable_tab_bar = false

config.window_decorations = "RESIZE"

-- config.colors = {
-- 	foreground = "#CBE0F0",
-- 	background = "#1A1B26",
-- 	cursor_bg = "#47FF9C",
-- 	cursor_border = "#47FF9C",
-- 	selection_bg = "#033259",
-- 	selection_fg = "#CBE0F0",
-- 	ansi = {
-- 		"black",
-- 		"maroon",
-- 		"green",
-- 		"olive",
-- 		"navy",
-- 		"purple",
-- 		"teal",
-- 		"silver",
-- 	},
-- }
config.color_scheme = "Gruvbox Dark (Gogh)"
config.window_background_opacity = 0.9
config.macos_window_background_blur = 10

local act = wezterm.action

config.keys = {
	{ key = "u", mods = "CTRL", action = act.ScrollByPage(-1) },
	{ key = "d", mods = "CTRL", action = act.ScrollByPage(1) },
	{ key = "u", mods = "CTRL|SHIFT", action = act.ScrollByLine(-1) },
	{ key = "d", mods = "CTRL|SHIFT", action = act.ScrollByLine(1) },
}
config.scrollback_lines = 100000
config.enable_scroll_bar = true

return config
