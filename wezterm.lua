-- local os = require("os")
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ======================================================================================
-- Session Manager ======================================================================
local session_manager = require("wezterm-session-manager/session-manager")

wezterm.on("save_session", function(window)
	session_manager.save_state(window)
end)
wezterm.on("load_session", function(window)
	session_manager.load_state(window)
end)
wezterm.on("restore_session", function(window)
	session_manager.restore_state(window)
end)

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

	-- Pane: Split Right (Comamnd RightArrow)
	{
		key = "RightArrow",
		mods = "CMD",
		action = wezterm.action.SplitPane({
			direction = "Right",
			size = { Percent = 50 },
		}),
	},
	-- Pane: Split Left (Comamnd LefttArrow)
	{
		key = "LeftArrow",
		mods = "CMD",
		action = wezterm.action.SplitPane({
			direction = "Left",
			size = { Percent = 50 },
		}),
	},
	-- Pane: Split Up (Comamnd UpArrow)
	{
		key = "UpArrow",
		mods = "CMD",
		action = wezterm.action.SplitPane({
			direction = "Up",
			size = { Percent = 50 },
		}),
	},
	-- Pane Split Down (Comamnd DownArrow)
	{
		key = "DownArrow",
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
	-- Worspace: Save Workspace (Session)
	{
		key = "s",
		mods = "LEADER",
		action = wezterm.action({ EmitEvent = "save_session" }),
	},
	-- Worspace: Load Workspace (Session)
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action({ EmitEvent = "load_session" }),
	},
	-- Worspace: Restore Workspace (Session)
	{
		key = "r",
		mods = "LEADER",
		action = wezterm.action({ EmitEvent = "restore_session" }),
	},

	-- { key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
}

-- ======================================================================================
-- Other Settings =======================================================================
-- TODO Organize these settings
config.initial_cols = 150
config.initial_rows = 50
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
config.macos_window_background_blur = 15
config.inactive_pane_hsb = {
	saturation = 0.5,
	brightness = 0.2,
}
-- config.text_background_opacity = 0.6
--config.hide_tab_bar_if_only_one_tab = true
config.switch_to_last_active_tab_when_closing_tab = true
config.use_fancy_tab_bar = true
config.tab_max_width = 100
config.enable_tab_bar = true
-- config.pane_focus_follows_mouse = true
config.scrollback_lines = 5000

config.font_size = 14
config.line_height = 1.25

-- To list all available fonts run: wezterm ls-fonts --list-system
config.font = wezterm.font("Monaspace Krypton NF", { weight = "DemiBold", stretch = "Normal", style = "Normal" })
-- /Users/tracy/Library/Fonts/MonaspaceKryptonNF-SemiWideMedium.otf, CoreText

config.color_scheme = "Catppuccin Mocha"

-- config.colors = {
--  tab_bar = {
--    active_tab = {
--      fg_color = "#073642",
--      bg_color = "#2aa198",
--    },
--  },
-- }

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.window_frame = {
	font_size = 11,
	font = wezterm.font("Monaspace Krypton NF", { weight = "Bold", stretch = "Normal", style = "Normal" }),
	-- Window Border Size
	border_top_height = "0.2cell",
	border_bottom_height = "0.2cell",
	border_left_width = "0.4cell",
	border_right_width = "0.4cell",
	-- Window Border Color
	border_top_color = "#6C7087",
	border_bottom_color = "#6C7087",
	border_left_color = "#6C7087",
	border_right_color = "#6C7087",
	--Titlebar
	active_titlebar_bg = "#2f2642",
	-- active_titlebar_fg = "#d4d4d4",
	-- active_titlebar_border_bottom = "#2b2042",
	-- inactive_titlebar_bg = "#353535",
	-- inactive_titlebar_fg = "#cccccc",
	-- inactive_titlebar_border_bottom = "#2b2042",
	-- Buttons
	-- button_fg = "#cccccc",
	-- button_bg = "#2b2042",
	-- button_hover_fg = "#ffffff",
	-- button_hover_bg = "#3b3052",
}

-- Print the workspace name in status bar
wezterm.on("update-right-status", function(window, pane)
	window:set_right_status("  " .. window:active_workspace() .. "  ")
end)

-- Hide the scrollbar when there is no scrollback or alternate screen is active
wezterm.on("update-status", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local dimensions = pane:get_dimensions()
	overrides.enable_scroll_bar = dimensions.scrollback_rows > dimensions.viewport_rows
		and not pane:is_alt_screen_active()

	window:set_config_overrides(overrides)
end)

-- load the previous configuration using the `gui-startup` event:
local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	-- maximize window when open
	-- window:gui_window():maximize()
	-- restore previous session state
	session_manager.restore_state(window:gui_window())
end)

-- Finally, return the configuration to wezterm:
return config
