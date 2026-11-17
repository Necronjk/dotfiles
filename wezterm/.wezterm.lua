local wezterm = require 'wezterm'

local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
local act = wezterm.action

front_end = "WebGpu"
webgpu_power_preference = "HighPerformance"
max_fps = 60

-- ==========================================
-- Custom Tab Bar
-- ==========================================

local TAB_BG = "#0f0f0f"
local ACTIVE_BG = "#cba6f7"
local HOVER_BG = "#292938"

local TAB_FG = "#a6adc8"
local ACTIVE_FG = "#11111b"
local HOVER_FG = "#cdd6f4"

local RIGHT_BORDER = ""

-- Get the last directory component
local function basename(path)
    if not path then
        return ""
    end

    path = path:gsub("[/\\]+$", "")
    return path:match("([^/\\]+)$") or path
end

-- Get the working directory
local function get_cwd(pane)
    local cwd = pane.current_working_dir

    if not cwd then
        return nil
    end

    if type(cwd) == "userdata" then
        return cwd.file_path or tostring(cwd)
    end

    return cwd
end

-- Generate tab content
local function get_tab_title(tab)
    local pane = tab.active_pane

    -- Explicit title always takes priority
    if tab.tab_title and tab.tab_title ~= "" then
        return tab.tab_title
    end

    if tab.is_active then
        -- Active: parent / cwd
        local cwd = get_cwd(pane)

        if cwd then
            local current = basename(cwd)
            local parent = basename(
                cwd:gsub("[/\\]+$", ""):match("^(.*)[/\\][^/\\]+$")
            )

            if parent ~= "" then
                return parent .. "/" .. current
            end

            return current
        end

        return pane.title
    end

    -- Inactive: process name
    return basename(pane.foreground_process_name)
        ~= "" and basename(pane.foreground_process_name)
        or pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)

    local background = TAB_BG
    local foreground = TAB_FG

    if tab.is_active then
        background = ACTIVE_BG
        foreground = ACTIVE_FG
    elseif hover then
        background = HOVER_BG
        foreground = HOVER_FG
    end

    local title = get_tab_title(tab)

    -- Add index
    local index = tostring(tab.tab_index + 1)

    -- Add zoom indicator
    if tab.is_active and tab.active_pane.is_zoomed then
        title = title .. " 󰊓"
    end

    local text = index .. "  " .. title

    -- Truncate to available space
    text = wezterm.truncate_right(text, max_width - 2)

    return {
        -- Tab content
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = " " .. text .. " " },

        -- Right powerline separator
        { Background = { Color = TAB_BG } },
        { Foreground = { Color = background } },
        { Text = RIGHT_BORDER },
    }
end)

wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

custom.background = "#040404"

local config = {
  adjust_window_size_when_changing_font_size = false,
  color_schemes = {
    ["OLEDppuccin"] = custom,
  },
  color_scheme = "OLEDppuccin",
  -- color_scheme = 'Catppuccin Mocha',
  -- enable_tab_bar = false,
  font_size = 13.0,
  font = wezterm.font('CaskaydiaCove Nerd Font'),

  window_background_opacity = 0.8,
  window_decorations = 'RESIZE',

  keys = {
    {
      key = "w",
      mods = "CMD",
      action = act.CloseCurrentPane { confirm = true },
    },
    {
      key = "=",
      mods = "CMD",
      action = act.SplitHorizontal { domain = "CurrentPaneDomain" },
    },
    {
      key = "-",
      mods = "CMD",
      action = act.SplitVertical { domain = "CurrentPaneDomain" },
    },
    {
      key = "t",
      mods = "CTRL|SHIFT",
      action = act.SpawnCommandInNewTab { cwd = wezterm.home_dir, },
    },
    {
      key = "y",
      mods = "CTRL|SHIFT",
      action = act.SpawnTab 'CurrentPaneDomain',
    },
    {
      key = "LeftArrow",
      mods = "CTRL|SHIFT",
      action = act.ActivateTabRelative(-1),
    },
    {
      key = "RightArrow",
      mods = "CTRL|SHIFT",
      action = act.ActivateTabRelative(1),
    },
    {
      key = "LeftArrow",
      mods = "ALT",
      action = act.ActivatePaneDirection 'Left',
    },
    {
      key = "RightArrow",
      mods = "ALT",
      action = act.ActivatePaneDirection 'Right',
    },
    {
      key = "UpArrow",
      mods = "ALT",
      action = act.ActivatePaneDirection 'Up',
    },
    {
      key = "DownArrow",
      mods = "ALT",
      action = act.ActivatePaneDirection 'Down',
    },
    {
      key = "LeftArrow",
      mods = "CTRL|CMD|ALT",
      action = act.AdjustPaneSize { 'Left', 5 },
    },
    {
      key = "RightArrow",
      mods = "CTRL|CMD|ALT",
      action = act.AdjustPaneSize {'Right', 5 },
    },
    {
      key = "UpArrow",
      mods = "CTRL|CMD|ALT",
      action = act.AdjustPaneSize { 'Up', 5 },
    },
    {
      key = "DownArrow",
      mods = "CTRL|CMD|ALT",
      action = act.AdjustPaneSize { 'Down', 5 },
    },
    {
      key = 'q',
      mods = 'CTRL',
      action = act.ToggleFullScreen,
    },
    {
      key = '\'',
      mods = 'CTRL',
      action = act.ClearScrollback 'ScrollbackAndViewport',
    },
    {
      key = 'LeftArrow',
      mods = 'CTRL',
      action = act.SendKey { key = 'b', mods = 'ALT' },
    },
    {
      key = 'RightArrow',
      mods = 'CTRL',
      action = act.SendKey { key = 'f', mods = 'ALT' },
    },
    {
      key = 'Backspace',
      mods = 'CTRL',
      action = act.SendKey { key = 'w', mods = 'CTRL' },
    },
    {
      key = 'Delete',
      mods = 'CTRL',
      action = act.SendKey { key = 'd', mods = 'ALT' },
    },
    {
      key = 'H',
      mods = 'SHIFT|CTRL',
      action = act.Search { CaseInSensitiveString = 'hash' },
    },
    {
      key = 'E',
      mods = 'CTRL|SHIFT',
      action = act.PromptInputLine {
        description = 'Enter new tab name',
        action = wezterm.action_callback(function(window, pane, line)
          if line ~= nil then
            window:active_tab():set_title(line)
          end
        end),
      },
    },
  },
  mouse_bindings = {
    -- Ctrl-click will open the link under the mouse cursor
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
    },
  },
}

config.use_fancy_tab_bar = false
config.tab_max_width = 50

config.colors = {
    tab_bar = {
        background = "#000000",
    },
}


-- Window padding
config.window_padding = {
	left = 3,
	right = 3,
	top = 3,
	bottom = 0,
}

return config
