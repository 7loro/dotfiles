local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font("D2CodingLigature Nerd Font")
config.font_size = 18

-- Theme
config.color_scheme = "catppuccin-mocha"
config.colors = {
  -- The color of the scrollbar "thumb"; the portion that represents the current viewport
  scrollbar_thumb = '#447dd7',
}

-- Decoration
config.window_padding = {
  left   = '20px',
  right  = '20px',
  top    = '20px',
  bottom = '20px',
}
config.window_background_opacity = 0.9
config.macos_window_background_blur = 10
config.window_decorations = "RESIZE"
config.scrollback_lines = 100000
config.enable_scroll_bar = true
-- config.enable_tab_bar = false
config.warn_about_missing_glyphs = false
config.window_close_confirmation = "NeverPrompt"
config.tab_bar_at_bottom = true

-- Plugins
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
  options = {
    icons_enabled = true,
    theme = 'Catppuccin Mocha',
    tabs_enabled = true,
    theme_overrides = {},
    section_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
    component_separators = {
      left = wezterm.nerdfonts.pl_left_soft_divider,
      right = wezterm.nerdfonts.pl_right_soft_divider,
    },
    tab_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
  },
  sections = {
    tabline_a = {  },
    tabline_b = { 'workspace' },
    tabline_c = { ' ' },
    tab_active = {
      'index',
      { 'cwd', padding = { left = 2, right = 2 } },
    },
    tab_inactive = {
      'index',
      { 'cwd', padding = { left = 2, right = 2 } },
    },
    tabline_x = { },
    tabline_y = { },
    tabline_z = {
      {
        'datetime',
        format = '%Y-%m-%d %H:%M',
      }
    },
  },
  extensions = {},
})

local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)
local suppress_notification = false
wezterm.on('resurrect.save_state.finished', function (session_path)
    local is_workspace_save = session_path:find("state/workspace")

    if is_workspace_save == nil then
        return
    end

    if suppress_notification then
        suppress_notification = false
        return
    end

    local path = session_path:match(".+/([^+]+)$")
    local name = path:match("^(.+)%.json$")
    -- notify.send("Wezterm - Save workspace", 'Saved workspace ' .. name .. "\n\n" .. session_path)
    notify.send("Wezterm Session Saved", "Current session state has been saved.")
end)

wezterm.on('resurrect.load_state.finished', function(name, type)
    local msg  = 'Completed loading ' .. type .. ' state: ' .. name
    notify.send("Wezterm - Restore session", msg)
end)

local smart_splits = wezterm.plugin.require('https://github.com/mrjones2014/smart-splits.nvim')

local direction_keys = {
    h = "Left",
    j = "Down",
    k = "Up",
    l = "Right",
}

local function split_nav(key)
    return {
        key = key,
        mods = "CTRL",
        action = wezterm.action_callback(function(win, pane)
            if pane:get_user_vars().IS_NVIM == "true" then
                -- pass the keys through to vim/nvim
                win:perform_action({
                    SendKey = { key = key, mods = "CTRL" },
                }, pane)
            else
                win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
            end
        end),
    }
end

-- Keymaps
local act = wezterm.action

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 2000 }
config.keys = {
  -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
  {
    key = 'a',
    mods = 'LEADER|CTRL',
    action = wezterm.action.SendKey { key = 'a', mods = 'CTRL' },
  },
  {
    key = 'Enter',
    mods = 'OPT',
    action = wezterm.action.SendKey { key = 'Enter', mods = 'OPT' },
  },
  -- { key = "u", mods = "CTRL", action = act.ScrollByPage(-1) },
  -- { key = "d", mods = "CTRL", action = act.ScrollByPage(1) },
  -- { key = "u", mods = "CTRL|SHIFT", action = act.ScrollByLine(-1) },
  -- { key = "d", mods = "CTRL|SHIFT", action = act.ScrollByLine(1) },
  { mods = "LEADER", key  = "v",          action = act.ActivateKeyTable { name = 'split_pane_horizontal', one_shot = true } },
  { mods = "LEADER", key  = "s",          action = act.ActivateKeyTable { name = 'split_pane_vertical', one_shot = true } },
  { mods = "LEADER", key  = "z",          action = act.TogglePaneZoomState },
  { mods = "LEADER", key  = "x",          action = act.CloseCurrentPane { confirm = false } },
  split_nav('h'),
  split_nav('j'),
  split_nav('k'),
  split_nav('l'),
  { mods = 'LEADER', key  = 'a',          action = act.ActivateKeyTable { name = 'activate_pane', one_shot = false } },
  { mods = 'LEADER', key  = 'r',          action = act.ActivateKeyTable { name = 'resize_pane'  , one_shot = false } },
  { mods = 'LEADER', key  = 'c',          action = act.ActivateKeyTable { name = 'rotate_pane'  , one_shot = false } },
  { mods = 'LEADER', key = ']',           action = act.RotatePanes "Clockwise"        },
  { mods = 'LEADER', key = '[',           action = act.RotatePanes "CounterClockwise" },
  { mods = 'LEADER', key = '0',           action = act.PaneSelect { mode = "SwapWithActive" } },
  { mods = 'LEADER', key = 'p',           action = act{PaneSelect={alphabet="0123456789"}}},
  -- activate copy mode or vim mode
  {
    key = 'Enter',
    mods = 'LEADER',
    action = wezterm.action.ActivateCopyMode
  },
  {
    key = 'p',
    mods = 'SUPER',
    action = wezterm.action.ActivateCommandPalette,
  },
  {
    key = "S",
    mods = "LEADER",
    action = wezterm.action_callback(function(win, pane)
      resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
      resurrect.window_state.save_window_action()
      win:toast_notification("Wezterm - Save session", "Saving current session state...", nil, 2000)
    end),
  },
  {
    key = "R",
    mods = "LEADER",
    action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
        local type = string.match(id, "^([^/]+)") -- match before '/'
        id = string.match(id, "([^/]+)$") -- match after '/'
        id = string.match(id, "(.+)%..+$") -- remove file extention
        local opts = {
          relative = true,
          restore_text = true,
          on_pane_restore = resurrect.tab_state.default_on_pane_restore,
        }
        if type == "workspace" then
          local state = resurrect.state_manager.load_state(id, "workspace")
          resurrect.workspace_state.restore_workspace(state, opts)
        elseif type == "window" then
          local state = resurrect.state_manager.load_state(id, "window")
          resurrect.window_state.restore_window(pane:window(), state, opts)
        elseif type == "tab" then
          local state = resurrect.state_manager.load_state(id, "tab")
          resurrect.tab_state.restore_tab(pane:tab(), state, opts)
        end
      end)
    end),
  },
}
config.key_tables = {
  activate_pane = {
    { key = 'h',  action = act.ActivatePaneDirection 'Left'  },
    { key = 'l', action = act.ActivatePaneDirection 'Right' },
    { key = 'k',    action = act.ActivatePaneDirection 'Up'    },
    { key = 'j',  action = act.ActivatePaneDirection 'Down'  },
    -- Cancel the mode by pressing escape
    { key = 'Escape',     action = 'PopKeyTable' },
    { key = 'q',     action = 'PopKeyTable' },
  },
  resize_pane = {
    { key = 'h',  action = act.AdjustPaneSize { 'Left',  1 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'k',    action = act.AdjustPaneSize { 'Up',    1 } },
    { key = 'j',  action = act.AdjustPaneSize { 'Down',  1 } },
    { key = 'Escape',     action = 'PopKeyTable' },
    { key = 'q',     action = 'PopKeyTable' },
  },
  rotate_pane = {
    { key = 'l', action = act.RotatePanes "CounterClockwise" },
    { key = 'h',  action = act.RotatePanes "Clockwise"        },
    { key = 'Escape',     action = 'PopKeyTable' },
    { key = 'q',     action = 'PopKeyTable' },
  },
  split_pane_horizontal = {
    { key = 's',     action = act.SplitHorizontal },
  },
  split_pane_vertical = {
    { key = 'p',     action = act.SplitVertical },
  }
}

return config
