-- Pull in the wezterm API
local wezterm = require("wezterm")

local config = wezterm.config_builder()
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- Integration with neovim panes
local function isViProcess(pane)
	-- get_foreground_process_name On Linux, macOS and Windows,
	-- the process can be queried to determine this path. Other operating systems
	-- (notably, FreeBSD and other unix systems) are not currently supported
	-- return pane:get_foreground_process_name():find('n?vim') ~= nil
	-- Use get_title as it works for multiplexed sessions too
	return pane:get_title():find("n?vim") ~= nil
end

local function conditionalActivatePane(window, pane, pane_direction, vim_direction)
	local vim_pane_changed = false

	if isViProcess(pane) then
		local before = pane:get_cursor_position()
		window:perform_action(wezterm.action.SendKey({ key = vim_direction, mods = "CTRL" }), pane)
		wezterm.sleep_ms(50)
		local after = pane:get_cursor_position()

		if before.x ~= after.x and before.y ~= after.y then
			vim_pane_changed = true
		end
	end

	if not vim_pane_changed then
		window:perform_action(wezterm.action.ActivatePaneDirection(pane_direction), pane)
	end
end

wezterm.on("ActivatePaneDirection-right", function(window, pane)
	conditionalActivatePane(window, pane, "Right", "l")
end)
wezterm.on("ActivatePaneDirection-left", function(window, pane)
	conditionalActivatePane(window, pane, "Left", "h")
end)
wezterm.on("ActivatePaneDirection-up", function(window, pane)
	conditionalActivatePane(window, pane, "Up", "k")
end)
wezterm.on("ActivatePaneDirection-down", function(window, pane)
	conditionalActivatePane(window, pane, "Down", "j")
end)
config.keys = {
	-- -- More easy split key mappings
	-- { key = "|", mods = "LEADER|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	-- { key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	--
	-- -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
	-- { key = "a", mods = "LEADER|CTRL", action = wezterm.action.SendString("\x01") },

	-- Integration with neovim panes
	{ key = "h", mods = "CTRL", action = wezterm.action.EmitEvent("ActivatePaneDirection-left") },
	{ key = "j", mods = "CTRL", action = wezterm.action.EmitEvent("ActivatePaneDirection-down") },
	{ key = "k", mods = "CTRL", action = wezterm.action.EmitEvent("ActivatePaneDirection-up") },
	{ key = "l", mods = "CTRL", action = wezterm.action.EmitEvent("ActivatePaneDirection-right") },

	-- Full screen
	{ key = "Enter", mods = "OPT", action = wezterm.action.ToggleFullScreen },
	{
		key = "D",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			pane:send_text("nvim\n")
			local left_pane = pane:split({
				direction = "Left",
				size = 0.2,
			})

			local bottom_left_pane = left_pane:split({
				direction = "Bottom",
				size = 0.5,
			})

			bottom_left_pane:send_text("spotify_player\n")
		end),
	},
}

config.use_fancy_tab_bar = false
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true
config.color_scheme = "Rosé Pine (Gogh)"
config.font = wezterm.font("MartianMono Nerd Font")
config.font_size = 16.0
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 0,
	right = 0,
	top = 10,
	bottom = 0,
}

config.colors = {
	tab_bar = {
		-- Background color of the entire tab bar
		background = "#191724",

		-- Active tab styling
		active_tab = {
			bg_color = "#C4A7E7",
			fg_color = "#ECEFF4",
		},

		new_tab = {
			bg_color = "#191724", -- Background color of new tab button
			fg_color = "#2E3440", -- Text color of new tab button
		},

		new_tab_hover = {

			bg_color = "#191724", -- Background color of new tab button
			fg_color = "#2E3440", -- Text color of new tab button
		},

		inactive_tab = {
			bg_color = "#191724",
			fg_color = "#E0DEF4",
		},

		inactive_tab_hover = {
			bg_color = "#191724",
			fg_color = "#E0DEF4",
		},
	},
}
return config
