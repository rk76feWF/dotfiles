local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.automatically_reload_config = true
config.font = wezterm.font_with_fallback({
  "MesloLGL Nerd Font",
  "Hiragino Sans",
  "Apple Color Emoji",
})
config.font_size = 16.0
config.use_ime = true
config.front_end = "WebGpu"
config.max_fps = 120
config.animation_fps = 60
config.window_background_opacity = 0.8
config.macos_window_background_blur = 0
config.scrollback_lines = 50000

----------------------------------------------------
-- Tab ----------------------------------------------------
-- タイトルバーを非表示
config.window_decorations = "RESIZE"
-- タブバーの表示
config.show_tabs_in_tab_bar = true
-- タブが一つの時は非表示
config.hide_tab_bar_if_only_one_tab = false

-- タブバーの透過
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
  font = wezterm.font("MesloLGL Nerd Font"),
  font_size = 14.0,
}

-- タブバーを背景色に合わせる
config.window_background_gradient = {
  colors = { "#000000" },
}

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false
-- タブ同士の境界線を非表示
config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

-- タブの形をカスタマイズ (Nerd Fontsを使用)
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"
  local edge_background = "none"
  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#FFFFFF"
  end
  local edge_foreground = background

  local tab_title = tab.tab_title
  if not tab_title or #tab_title == 0 then
    tab_title = tab.active_pane.title
  end
  local title = " " .. wezterm.truncate_right(tab_title, max_width - 1) .. " "

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

----------------------------------------------------
-- keybinds ----------------------------------------------------
config.disable_default_key_bindings = false
-- 外部ファイルからキーバインドを読み込む
-- ローカル読み込み用にパスを調整
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/wezterm/?.lua"
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
-- Leaderキーを Ctrl-b (tmuxデフォルト) に設定
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 2000 }

return config
