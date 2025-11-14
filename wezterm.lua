-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.initial_cols = 120
config.initial_rows = 30
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
config.macos_window_background_blur = 15
config.inactive_pane_hsb = {
	saturation = 0.5,
	brightness = 0.2,
}
-- config.text_background_opacity = 0.6
--config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.enable_tab_bar = true

config.font_size = 14
config.line_height = 1.25

-- To list all available fonts run: wezterm ls-fonts --list-system
config.font = wezterm.font("Monaspace Krypton NF", { weight = "DemiBold", stretch = "Normal", style = "Normal" })
-- /Users/tracy/Library/Fonts/MonaspaceKryptonNF-SemiWideMedium.otf, CoreText

config.color_scheme = "Catppuccin Mocha"

config.keys = {
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
}

config.window_padding = {
	left = 4,
	right = 4,
	top = 4,
	bottom = 4,
}

-- Print the workspace name in status bar
wezterm.on("update-right-status", function(window, pane)
	window:set_right_status(window:active_workspace())
end)

-- Hide the scrollbar when there is no scrollback or alternate screen is active
wezterm.on("update-status", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local dimensions = pane:get_dimensions()

	overrides.enable_scroll_bar = dimensions.scrollback_rows > dimensions.viewport_rows
		and not pane:is_alt_screen_active()

	window:set_config_overrides(overrides)
end)

-- Finally, return the configuration to wezterm:
return config
