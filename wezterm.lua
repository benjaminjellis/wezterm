-- Pull in the wezterm API
local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- try to load the private module
local loaded, private = pcall(function()
	return require("private")
end)

if loaded then
	private.run(config)
end

-- when wezterm is opened make it fill the screen
wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- Integration with neovim panes
local function is_vi_process(pane)
	-- get_foreground_process_name On Linux, macOS and Windows,
	-- the process can be queried to determine this path. Other operating systems
	-- (notably, FreeBSD and other unix systems) are not currently supported
	-- return pane:get_foreground_process_name():find('n?vim') ~= nil
	-- Use get_title as it works for multiplexed sessions too
	return pane:get_title():find("n?vim") ~= nil
end

local function conditional_activate_pane(window, pane, pane_direction, vim_direction)
	local vim_pane_changed = false

	if is_vi_process(pane) then
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

wezterm.on("ActivatePaneDirection-Right", function(window, pane)
	conditional_activate_pane(window, pane, "Right", "l")
end)
wezterm.on("ActivatePaneDirection-Left", function(window, pane)
	conditional_activate_pane(window, pane, "Left", "h")
end)
wezterm.on("ActivatePaneDirection-Up", function(window, pane)
	conditional_activate_pane(window, pane, "Up", "k")
end)
wezterm.on("ActivatePaneDirection-Down", function(window, pane)
	conditional_activate_pane(window, pane, "Down", "j")
end)

---@param mode string
---@param size number
local function set_up_two_panes(mode, size)
	return wezterm.action_callback(function(_, pane)
		local new_pane = pane:split({
			direction = mode,
			size = size,
		})

		new_pane:send_text("nvim\n")
		new_pane:activate()
	end)
end

local function set_up_horizontal_panes()
	return set_up_two_panes("Right", 0.7)
end

local function set_up_vertical_panes()
	return set_up_two_panes("Top", 0.6)
end

---@param launch_spotify boolean
local function set_up_dev_panes(launch_spotify)
	return wezterm.action_callback(function(_, pane)
		local left_pane = pane:split({
			direction = "Left",
			size = 0.3,
		})
		local bottom_left_pane = left_pane:split({
			direction = "Bottom",
			size = 0.5,
		})

		if launch_spotify then
			bottom_left_pane:send_text("spotify_player\n")
		end

		pane:activate()
		pane:send_text("nvim\n")
	end)
end

config.leader = { key = "a", mods = "CTRL" }
-- enabling these make the terminal transparent
config.window_background_opacity = 0.9
config.macos_window_background_blur = 70
config.use_fancy_tab_bar = false
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true
config.color_scheme = "Rosé Pine (Gogh)"
config.font = wezterm.font({
	family = "Monaspace Neon",
	weight = "Bold",
	harfbuzz_features = { "calt", "liga", "dlig", "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08" },
})
config.font_size = 17.0
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.max_fps = 120
config.window_padding = {
	left = 0,
	right = 0,
	top = 10,
	bottom = 0,
}

config.keys = {
	-- tmux bindings for switching between panes
	{ key = "h", mods = "CTRL", action = wezterm.action.EmitEvent("ActivatePaneDirection-Left") },
	{ key = "j", mods = "CTRL", action = wezterm.action.EmitEvent("ActivatePaneDirection-Down") },
	{ key = "k", mods = "CTRL", action = wezterm.action.EmitEvent("ActivatePaneDirection-Up") },
	{ key = "l", mods = "CTRL", action = wezterm.action.EmitEvent("ActivatePaneDirection-Right") },

	{
		key = "D",
		mods = "CTRL|SHIFT",
		action = set_up_dev_panes(false),
	},
	{
		key = "S",
		mods = "CTRL|SHIFT",
		action = set_up_dev_panes(true),
	},
	{
		key = "|",
		mods = "CTRL|SHIFT",
		action = set_up_horizontal_panes(),
	},
	{
		key = "B",
		mods = "CTRL|SHIFT",
		action = set_up_vertical_panes(),
	},
	{
		key = "H",
		mods = "LEADER",
		action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
	},
	{
		key = "J",
		mods = "LEADER",
		action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
	},
	{ key = "K", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
	{
		key = "L",
		mods = "LEADER",
		action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
	},
}

config.colors = {
	-- tab colours to match rose-pine colour scheme
	tab_bar = {
		-- Background color of the entire tab bar, doesn't affect the fancy tab bar
		background = "#191724",

		active_tab = {
			bg_color = "#eb6f92",
			fg_color = "#e0def4",
		},

		new_tab = {
			bg_color = "#191724",
			fg_color = "#2E3440",
		},

		new_tab_hover = {
			bg_color = "#191724",
			fg_color = "#2E3440",
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
