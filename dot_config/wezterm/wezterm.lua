local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- macOS 시스템 알림 유틸리티 (wezterm.run_child_process 사용)
local notify = {
  send = function(title, message)
    wezterm.run_child_process({
      'osascript', '-e',
      string.format(
        'display notification "%s" with title "%s"',
        message:gsub('"', '\\"'), title:gsub('"', '\\"')
      ),
    })
  end,
}

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

-- 탭별 고유 색상 (활성 탭 배경 / 비활성 탭 인디케이터)
local tab_accent = {
  '#ff4d6d', -- red
  '#ff9248', -- peach
  '#ffd000', -- yellow
  '#4cc840', -- green
  '#20c0e8', -- sky
  '#5898f8', -- blue
  '#b080f8', -- mauve
  '#f868c8', -- pink
}

local INACTIVE_BG = '#2a2b3d'
local TAB_BAR_BG  = '#1e1e2e'
local SEP = wezterm.nerdfonts.pl_left_hard_divider  --

local function get_tab_title(tab)
  local title = tab.tab_title
  if title and #title > 0 then
    return title
  end
  local cwd = tab.active_pane.current_working_dir
  if cwd then
    return cwd.file_path:match("([^/]+)/?$") or cwd.file_path
  end
  return tab.active_pane.title
end

-- 탭을 보면 🔔 제거 (🔔 prefix 제거 후 원래 타이틀로 복구)
local BELL = '\xf0\x9f\x94\x94'  -- 🔔 UTF-8 (4바이트)

-- 탭을 보면 🔔 제거: update-right-status는 탭 전환 시에도 발생
wezterm.on('update-right-status', function(window, pane)
  local tab = window:active_tab()
  local title = tab:get_title()
  if title:sub(1, 4) == BELL then
    local original = title:sub(5):match('^%s*(.*)')
    tab:set_title(original or '')
  end
end)

local function tab_bg(t)
  return t.is_active and tab_accent[(t.tab_index % #tab_accent) + 1] or INACTIVE_BG
end

wezterm.on('format-tab-title', function(tab, tabs)
  local idx    = (tab.tab_index % #tab_accent) + 1
  local accent = tab_accent[idx]
  local title  = get_tab_title(tab)
  local index  = tostring(tab.tab_index + 1)

  local next_tab = tabs[tab.tab_index + 2]
  local next_bg  = next_tab and tab_bg(next_tab) or TAB_BAR_BG

  if tab.is_active then
    return {
      { Background = { Color = accent } },
      { Foreground = { Color = '#1e1e2e' } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = '  ' .. index .. '  ' .. title .. '  ' },
      { Attribute = { Intensity = 'Normal' } },
      { Background = { Color = next_bg } },
      { Foreground = { Color = accent } },
      { Text = SEP },
    }
  else
    return {
      { Background = { Color = INACTIVE_BG } },
      { Foreground = { Color = accent } },
      { Text = '▎' },
      { Foreground = { Color = '#a0a8c0' } },
      { Text = index .. '  ' .. title .. '  ' },
      { Background = { Color = next_bg } },
      { Foreground = { Color = INACTIVE_BG } },
      { Text = SEP },
    }
  end
end)

-- Plugins
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
  options = {
    icons_enabled = true,
    theme = 'Catppuccin Mocha',
    tabs_enabled = false,  -- 탭 렌더링은 format-tab-title 이벤트로 직접 처리
    theme_overrides = {
      normal_mode = {
        a = { fg = '#1e1e2e', bg = '#89b4fa' },  -- blue
        b = { fg = '#cdd6f4', bg = '#313244' },  -- surface0
        c = { fg = '#cdd6f4', bg = '#313244' },
      },
      copy_mode = {
        a = { fg = '#1e1e2e', bg = '#f9e2af' },  -- yellow
        b = { fg = '#cdd6f4', bg = '#313244' },
        c = { fg = '#cdd6f4', bg = '#313244' },
      },
      search_mode = {
        a = { fg = '#1e1e2e', bg = '#a6e3a1' },  -- green
        b = { fg = '#cdd6f4', bg = '#313244' },
        c = { fg = '#cdd6f4', bg = '#313244' },
      },
    },
    section_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
    component_separators = {
      left = wezterm.nerdfonts.pl_left_soft_divider,
      right = wezterm.nerdfonts.pl_right_soft_divider,
    },
  },
  sections = {
    tabline_a = { 'mode' },
    tabline_b = { },
    tabline_c = { ' ' },
    tabline_x = {
      function()
        local expires = wezterm.GLOBAL.notification_expires or 0
        if os.time() < expires then
          return wezterm.GLOBAL.notification or ''
        end
        return ''
      end,
    },
    tabline_y = { },
    tabline_z = {
      function()
        return '  ' .. os.date('%Y-%m-%d %H:%M') .. ' '
      end,
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
    notify.send("Wezterm Session Saved", "Current session state has been saved.")
end)

wezterm.on('resurrect.load_state.finished', function(name, type)
    local msg = 'Completed loading ' .. type .. ' state: ' .. name
    notify.send("Wezterm - Restore session", msg)
end)

-- 설정 리로드 시 우측 상단에 3초간 알림 표시
wezterm.on('window-config-reloaded', function(window)
  window:set_right_status(wezterm.format({
    { Attribute = { Intensity = 'Bold' } },
    { Foreground = { Color = '#a6e3a1' } },
    { Text = '  config reloaded ' },
  }))
  wezterm.sleep_ms(3000)
  window:set_right_status('')
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
      notify.send("WezTerm", "Session saved")
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
  {
    key = 'l',
    mods = 'LEADER',
    action = wezterm.action.ClearScrollback 'ScrollbackAndViewport',
  },
  -- 탭 순서 변경 (LEADER + < / >)
  {
    key = '<',
    mods = 'LEADER',
    action = wezterm.action_callback(function(win, pane)
      local tab = win:active_tab()
      local tabs = win:mux_window():tabs_with_info()
      for i, t in ipairs(tabs) do
        if t.tab:tab_id() == tab:tab_id() then
          if i > 1 then
            win:perform_action(wezterm.action.MoveTab(i - 2), pane)
          end
          return
        end
      end
    end),
  },
  {
    key = '>',
    mods = 'LEADER',
    action = wezterm.action_callback(function(win, pane)
      local tab = win:active_tab()
      local tabs = win:mux_window():tabs_with_info()
      for i, t in ipairs(tabs) do
        if t.tab:tab_id() == tab:tab_id() then
          if i < #tabs then
            win:perform_action(wezterm.action.MoveTab(i), pane)
          end
          return
        end
      end
    end),
  },
  -- 직전 탭으로 전환
  { mods = 'LEADER', key = 'Tab', action = act.ActivateLastTab },
  {
    key = 't',
    mods = "LEADER",
    action = wezterm.action.PromptInputLine {
      description = 'Tab 이름 입력',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  }
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

tabline.apply_to_config(config)

-- apply_to_config가 padding을 0으로 덮어쓰므로 재설정
config.window_padding = {
  left   = '12px',
  right  = '12px',
  top    = '12px',
  bottom = '0px',  -- 탭바가 하단에 있으므로 bottom은 0
}

return config
