-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 30
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

config.font_size = 14
config.line_height = 1.25
--config.font = wezterm.font_with_fallback {
--  'Monaspace Krypton NF',
--}
wezterm.font("Monaspace Krypton NF", {weight="Medium", stretch="Normal", style="Normal"}) -- /Users/tracy/Library/Fonts/MonaspaceKryptonNF-SemiWideMedium.otf, CoreText

config.color_scheme = 'Catppuccin Mocha'

config.keys = {
  {
    key = 'w',
    mods = 'CTRL',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
}

  -- Hide the scrollbar when there is no scrollback or alternate screen is active
wezterm.on("update-status", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local dimensions = pane:get_dimensions()

  overrides.enable_scroll_bar = dimensions.scrollback_rows > dimensions.viewport_rows and not pane:is_alt_screen_active()

  window:set_config_overrides(overrides)
end)


-- Finally, return the configuration to wezterm:
return config
