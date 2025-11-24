-- local os = require("os")
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ======================================================================================
-- Split Management =====================================================================
local is_vim = function(pane)
	local process_info = pane:get_foreground_process_info()
	local process_name = process_info and process_info.name

	return process_name == "nvim" or process_name == "vim"
end

local direction_keys = {
	Left = "h",
	Down = "j",
	Up = "k",
	Right = "l",
	-- reverse lookup
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key) -- https://github.com/letieu/wezterm-move.nvim
	-- Note: META is Alt on Windows; Option on macOS
	return {
		key = key,
		-- Note: META is Alt on Windows; Option on macOS
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

-- ======================================================================================
-- Keymaps ==============================================================================
config.leader = {
	key = "a",
	mods = "CTRL",
	timeout_milliseconds = 2000,
}

config.keys = {
	-- Pane: Move between split panes
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
	-- Pane: Resize panes
	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),

	-- Pane: Split Right (Command RightArrow)
	{
		key = "L",
		mods = "CMD",
		action = wezterm.action.SplitPane({
			direction = "Right",
			size = { Percent = 50 },
		}),
	},
	-- Pane: Split Left (Command LefttArrow)
	{
		key = "H",
		mods = "CMD",
		action = wezterm.action.SplitPane({
			direction = "Left",
			size = { Percent = 50 },
		}),
	},
	-- Pane: Split Up (Command UpArrow)
	{
		key = "K",
		mods = "CMD",
		action = wezterm.action.SplitPane({
			direction = "Up",
			size = { Percent = 50 },
		}),
	},
	-- Pane Split Down (Command DownArrow)
	{
		key = "J",
		mods = "CMD",
		action = wezterm.action.SplitPane({
			direction = "Down",
			size = { Percent = 50 },
		}),
	},
	-- Pane: Toggle zoom of current pane (Command + Shift + F)
	{
		key = "F",
		mods = "CMD",
		action = wezterm.action.TogglePaneZoomState,
	},
	-- Pane: Swap panes (Command + Shift 8)
	{
		key = "*",
		mods = "CMD",
		action = wezterm.action.PaneSelect({ mode = "SwapWithActiveKeepFocus" }),
	},
	-- Pane: Move to previous pane (Command + [)
	{
		key = "[",
		mods = "CMD",
		action = wezterm.action.ActivatePaneDirection("Prev"),
	},
	-- Pane: Move to next pane (Comamnd + ])
	{
		key = "]",
		mods = "CMD",
		action = wezterm.action.ActivatePaneDirection("Next"),
	},
	-- Pane: Close current Pane; close Tab if is last Pane (Command + w)
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},

	-- Tab: Show All Tabs (Command + Shift + T)
	{
		key = "T",
		mods = "CMD",
		action = wezterm.action.ShowTabNavigator,
	},
	-- Tab: Rename Tab (Command + Shift + N)
	{
		key = "N",
		mods = "CMD",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- Workspace: Show All Workspaces (Sessions)
	{
		key = "w",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({ flags = "WORKSPACES" }),
	},
	-- Workspace: Rename Workspace (Session)
	{
		key = "n",
		mods = "LEADER",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for Workspace",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					wezterm.mux.rename_workspace(window:mux_window():get_workspace(), line)
				end
			end),
		}),
	},

	-- { key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
}

-- ======================================================================================
-- Other Settings =======================================================================

config.color_scheme = "Catppuccin Mocha"
-- To list all available fonts run: wezterm ls-fonts --list-system
config.font = wezterm.font("Monaspace Krypton NF", { weight = "DemiBold", stretch = "Normal", style = "Normal" })
-- /Users/tracy/Library/Fonts/MonaspaceKryptonNF-SemiWideMedium.otf, CoreText
config.font_size = 14
config.line_height = 1.25

config.initial_cols = 150
config.initial_rows = 50

-- config.text_background_opacity = 0.6
config.scrollback_lines = 5000

-- Tabs
config.enable_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.use_fancy_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_max_width = 100
config.colors = {
	tab_bar = {
		background = "#11111C", -- Background color of the entire tab bar
		active_tab = {
			bg_color = "#1E1E2F", -- Background color of the active tab
			fg_color = "#FFFFFF", -- Foreground color (text) of the active tab
			intensity = "Normal",
		},
		inactive_tab = {
			bg_color = "#313244", -- Background color of inactive tabs
			fg_color = "#cdd6f4", -- Foreground color (text) of inactive tabs
			intensity = "Normal",
		},
		inactive_tab_hover = {
			bg_color = "#45475a", -- Background color of inactive tabs on hover
			fg_color = "#cdd6f4", -- Foreground color (text) of inactive tabs on hover
		},
		new_tab = {
			bg_color = "#89b4fa", -- Background color of the new tab button
			fg_color = "#1e1e2e", -- Foreground color (icon) of the new tab button
		},
		new_tab_hover = {
			bg_color = "#74c7ec", -- Background color of the new tab button on hover
			fg_color = "#1e1e2e", -- Foreground color (icon) of the new tab button on hover
		},
	},
}
-- Window
config.window_decorations = "RESIZE | MACOS_FORCE_ENABLE_SHADOW"
-- config.window_decorations = "RESIZE | MACOS_FORCE_SQUARE_CORNERS"
-- config.window_decorations = "RESIZE | MACOS_USE_BACKGROUND_COLOR_AS_TITLEBAR_COLOR | TITLE"
-- https://wezterm.org/config/lua/config/window_decorations.html

config.window_background_opacity = 0.9
config.macos_window_background_blur = 15
config.window_padding = {
	left = 12,
	right = 0,
	top = 12,
	bottom = 12,
}
config.window_frame = {
	font_size = 11,
	font = wezterm.font("Monaspace Krypton NF", { weight = "Bold", stretch = "Normal", style = "Normal" }),
	-- Window Border Size
	border_top_height = 12,
	border_bottom_height = 12,
	border_left_width = 12,
	border_right_width = 12,
	-- Window Border Color
	border_top_color = "#11111C",
	border_bottom_color = "#11111C",
	border_left_color = "#11111C",
	border_right_color = "#11111C",
}

-- Panes
-- config.pane_focus_follows_mouse = true
config.inactive_pane_hsb = {
	saturation = 0.5,
	brightness = 0.2,
}

-- Hide the scrollbar when there is no scrollback or alternate screen is active
-- wezterm.on("update-status", function(window, pane)
-- 	local overrides = window:get_config_overrides() or {}
-- 	local dimensions = pane:get_dimensions()
-- 	overrides.enable_scroll_bar = dimensions.scrollback_rows > dimensions.viewport_rows
-- 		and not pane:is_alt_screen_active()
--
-- 	window:set_config_overrides(overrides)
-- end)

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
	options = {
		icons_enabled = true,
		theme = "Catppuccin Mocha",
		tabs_enabled = true,
		theme_overrides = {
			normal_mode = {
				a = { fg = "#444444", bg = "#11111C" },
				b = { fg = "#89b4fa", bg = "#313244" },
				c = { fg = "#cdd6f4", bg = "#181825" },
				y = { fg = "#CDCDCD", bg = "11111C" },
				z = { fg = "#CDCDCD", bg = "11111C" },
			},
			tab = {
				active = { fg = "#FFFFFF", bg = "#1E1E2F" },
				inactive = { fg = "#555555", bg = "#11111C" },
				inactive_hover = { fg = "#999999", bg = "#1D1F2F" },
			},
		},
		section_separators = {
			left = "",
			right = "",
		},
		component_separators = {
			left = wezterm.nerdfonts.pl_left_soft_divider,
			right = wezterm.nerdfonts.pl_right_soft_divider,
		},
		tab_separators = {
			left = " ",
			right = "",
		},
	},
	sections = {
		tabline_a = { " " },
		tabline_b = {},
		tabline_c = {},
		tab_active = { "index", { "tab", padding = { left = 0, right = 1 } } },
		tab_inactive = { "index", { "tab", padding = { left = 0, right = 1 } } },
		tabline_x = {},
		tabline_y = { "workspace" },
		tabline_z = { " " },
	},
	extensions = {},
})

-- Finally, return the configuration to wezterm:
return config
