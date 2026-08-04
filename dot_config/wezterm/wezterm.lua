-- ~/.config/wezterm/wezterm.lua  — кроссплатформенный конфиг (Windows / macOS / Linux)
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

--=============================================================================
-- 1. Определение платформы
--=============================================================================
local triple   = wezterm.target_triple
local is_win   = triple:find('windows') ~= nil
local is_mac   = triple:find('darwin') ~= nil
local is_linux = triple:find('linux') ~= nil

--=============================================================================
-- 2. Базовое
--=============================================================================
config.initial_cols = 120
config.initial_rows = 40
config.canonicalize_pasted_newlines = 'LineFeed'
config.scrollback_lines = 10000

--=============================================================================
-- 3. Домены и launch_menu
--=============================================================================
local launch_menu = {}

-- Безопасная проверка наличия исполняемого файла.
-- ВАЖНО: run_child_process бросает Lua-ошибку, если бинарник не найден,
-- поэтому оборачиваем в pcall (на macOS нет /usr/bin/where — это и роняло конфиг).
local function exe_exists(name)
  local argv = is_win and { 'where.exe', name } or { '/usr/bin/env', 'which', name }
  local pok, ok = pcall(wezterm.run_child_process, argv)
  return pok and ok
end

---------------------------------------------------------------- Windows / WSL
if is_win then
  local wsl_domains = wezterm.default_wsl_domains()
  for _, dom in ipairs(wsl_domains) do
    dom.default_cwd = '~'
  end
  -- без этой строки правка default_cwd выше ни на что не влияла
  config.wsl_domains = wsl_domains

  if #wsl_domains > 0 then
    config.default_domain = wsl_domains[1].name -- напр. "WSL:Ubuntu-24.04"
  end

  if exe_exists('pwsh.exe') then
    table.insert(launch_menu, {
      label = 'PowerShell 7 (pwsh)',
      domain = { DomainName = 'local' },
      args = { 'pwsh.exe', '-NoLogo' },
    })
  end
  if exe_exists('powershell.exe') then
    table.insert(launch_menu, {
      label = 'PowerShell (Windows)',
      domain = { DomainName = 'local' },
      args = { 'powershell.exe', '-NoLogo' },
    })
  end
  table.insert(launch_menu, {
    label = 'Command Prompt',
    domain = { DomainName = 'local' },
    args = { 'cmd.exe' },
  })

  for _, dom in ipairs(wsl_domains) do
    table.insert(launch_menu, {
      label = 'WSL: ' .. dom.distribution,
      domain = { DomainName = dom.name },
    })
  end
end

------------------------------------------------------------------ macOS/Linux
if is_mac or is_linux then
  for _, sh in ipairs { '/opt/homebrew/bin/fish', '/usr/local/bin/fish', '/bin/zsh', '/bin/bash' } do
    local f = io.open(sh, 'r')
    if f then
      f:close()
      table.insert(launch_menu, { label = sh:match('[^/]+$'), args = { sh, '-l' } })
    end
  end
end

------------------------------------------------------------------------- SSH
-- Свои хосты одним списком (никаких копипаст-блоков с одинаковым тайтлом).
local ssh_hosts = {
  { title = '🌐 VPS LV', host = 'root@vpslv.askin.su' },
  { title = '🌐 VPS DE', host = 'root@vpsde.askin.su' },
  { title = '🌐 VPS',    host = 'root@vps.askin.su' },
  { title = '💾 NAS',    host = 'root@172.30.30.5' },
  { title = '🖥 PVE1',   host = 'root@172.30.30.6' },
  { title = '🖥 PVE2',   host = 'root@192.168.58.254' },
}

local seen_ssh = {}
for _, h in ipairs(ssh_hosts) do
  seen_ssh[h.host] = true
  table.insert(launch_menu, {
    label = 'SSH: ' .. h.title .. ' (' .. h.host .. ')',
    args = { 'ssh', h.host },
    set_environment_variables = { WEZTERM_TAB_TITLE = h.title },
  })
end

-- Плюс хосты из ~/.ssh/config (парсинг тоже может кинуть ошибку → pcall)
local pok, ssh_domains = pcall(wezterm.default_ssh_domains)
if pok and ssh_domains then
  for _, domain in ipairs(ssh_domains) do
    local addr = domain.remote_address
    if not domain.name:match('^SSHMUX:') and addr and not seen_ssh[addr] then
      seen_ssh[addr] = true
      table.insert(launch_menu, {
        label = 'SSH: ' .. addr,
        args = { 'ssh', addr },
      })
    end
  end
end

config.launch_menu = launch_menu

--=============================================================================
-- 4. Клавиши
--=============================================================================
config.disable_default_key_bindings = true
config.leader = { key = 'Space', mods = 'CTRL|SHIFT', timeout_milliseconds = 2000 }

-- На macOS левый Option по умолчанию = чистый ALT, так что ALT-биндинги ниже
-- работают. Если Option начнёт вставлять символы — раскомментируй:
-- config.send_composed_key_when_left_alt_is_pressed = false

local MoveToNewTab = wezterm.action_callback(function(_, pane)
  local tab = pane:move_to_new_tab()
  tab:activate()
end)

-- Ctrl+C: копирует, если есть выделение, иначе отправляет SIGINT в шелл.
local SmartCopy = wezterm.action_callback(function(win, pane)
  local sel = win:get_selection_text_for_pane(pane)
  if sel and sel ~= '' then
    win:perform_action(act.CopyTo 'ClipboardAndPrimarySelection', pane)
    win:perform_action(act.ClearSelection, pane)
  else
    win:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
  end
end)

config.keys = {
  -- tabs
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = '!', mods = 'LEADER', action = MoveToNewTab },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(1) },
  { key = 'LeftArrow',  mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },

  { key = '0', mods = 'ALT', action = act.ShowLauncherArgs { flags = 'FUZZY|LAUNCH_MENU_ITEMS' } },

  -- panes
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'RightArrow', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'DownArrow',  mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = false } },
  { key = 'r', mods = 'LEADER', action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false } },

  { key = 'DownArrow',  mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
  { key = 'UpArrow',    mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'LeftArrow',  mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },

  -- font
  { key = ']', mods = 'LEADER', action = act.IncreaseFontSize },
  { key = '[', mods = 'LEADER', action = act.DecreaseFontSize },
  { key = '=', mods = 'LEADER', action = act.ResetFontSize },

  -- misc
  { key = 'P', mods = 'CTRL', action = act.ActivateCommandPalette },
  { key = 'L', mods = 'CTRL', action = act.ShowDebugOverlay },
  { key = 'S', mods = 'LEADER', action = act.ReloadConfiguration },

  -- scroll
  { key = 'UpArrow',   mods = 'SHIFT', action = act.ScrollByLine(-10) },
  { key = 'DownArrow', mods = 'SHIFT', action = act.ScrollByLine(10) },
  { key = 'PageUp',   action = act.ScrollByPage(-1) },
  { key = 'PageDown', action = act.ScrollByPage(1) },
  { key = 'End',  mods = 'CTRL', action = act.ScrollToBottom },
  { key = 'Home', mods = 'CTRL', action = act.ScrollToTop },

  -- rename tab
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Введите новое имя для вкладки',
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
}

-- ALT+1..7 -> вкладки
for i = 1, 7 do
  table.insert(config.keys, { key = tostring(i), mods = 'ALT', action = act.ActivateTab(i - 1) })
end

-- Платформенные буфер обмена / системные хоткеи
if is_mac then
  for _, k in ipairs {
    { key = 'c', action = act.CopyTo 'Clipboard' },
    { key = 'v', action = act.PasteFrom 'Clipboard' },
    { key = 'n', action = act.SpawnWindow },
    { key = 't', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'w', action = act.CloseCurrentTab { confirm = true } },
    { key = 'q', action = act.QuitApplication },
    { key = 'k', action = act.ClearScrollback 'ScrollbackOnly' },
    { key = 'f', action = act.Search 'CurrentSelectionOrEmptyString' },
    { key = 'Enter', mods_extra = 'CTRL', action = act.ToggleFullScreen },
  } do
    table.insert(config.keys, {
      key = k.key,
      mods = k.mods_extra and ('SUPER|' .. k.mods_extra) or 'SUPER',
      action = k.action,
    })
  end
else
  table.insert(config.keys, { key = 'c', mods = 'CTRL', action = SmartCopy })
  table.insert(config.keys, { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' })
  table.insert(config.keys, { key = 'C', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' })
  table.insert(config.keys, { key = 'V', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' })
  table.insert(config.keys, { key = 'F', mods = 'CTRL|SHIFT', action = act.Search 'CurrentSelectionOrEmptyString' })
  table.insert(config.keys, { key = 'Enter', mods = 'ALT', action = act.ToggleFullScreen })
end

config.key_tables = {
  resize_pane = {
    { key = 'LeftArrow',  action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'DownArrow',  action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'UpArrow',    action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'Escape',     action = 'PopKeyTable' },
  },
}

--=============================================================================
-- 5. Внешний вид
--=============================================================================
-- font_with_fallback: если шрифта нет (типичный случай на новой машине),
-- WezTerm молча возьмёт следующий, а не будет ругаться в лог.
config.font = wezterm.font_with_fallback {
  'JetBrainsMonoNL NF',
  'JetBrainsMono Nerd Font',
  'JetBrains Mono',
  is_mac and 'Menlo' or 'Consolas',
  'Symbols Nerd Font Mono',
}
config.font_size = is_mac and 14.0 or 13.0

config.color_scheme = 'Kasugano (terminal.sexy)'
config.window_background_gradient = {
  orientation = 'Vertical',
  colors = { '#223343', '#000000' },
  interpolation = 'Linear',
  blend = 'Rgb',
}
config.window_background_opacity = 0.96
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.5 }

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

if is_mac then
  config.macos_window_background_blur = 20
  config.native_macos_fullscreen_mode = true
  config.window_decorations = 'TITLE | RESIZE'
end

--=============================================================================
-- 6. Плагины (сеть + git; падение плагина не должно ронять конфиг)
--=============================================================================
local function use_plugin(url, apply)
  local ok, plugin = pcall(wezterm.plugin.require, url)
  if not ok then
    wezterm.log_error('plugin load failed: ' .. url .. ' -> ' .. tostring(plugin))
    return
  end
  local ok2, err = pcall(apply, plugin)
  if not ok2 then
    wezterm.log_error('plugin apply failed: ' .. url .. ' -> ' .. tostring(err))
  end
end

use_plugin('https://github.com/yriveiro/wezterm-tabs', function(p)
  p.apply_to_config(config)
end)

use_plugin('https://github.com/usrivastava92/widgets.wez', function(sys)
  sys.apply_to_config(config, {
    right = {
      sys.cpu.utilization.widget(),
      sys.ram.utilization.widget(),
      sys.network.download.widget(),
      sys.network.upload.widget(),
    },
    separator = { text = '|', color = '#3b4261' },
  })
end)

use_plugin('https://github.com/pro-vi/wezterm-attention', function(p)
  p.apply_to_config(config)
end)

return config
