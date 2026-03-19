local wezterm = require("wezterm")
local act = wezterm.action
local HOME = wezterm.home_dir

-- ステータスバーにアクティブなキーテーブルを表示
wezterm.on("update-right-status", function(window, pane)
  local name = window:active_key_table()
  if name then
    name = "TABLE: " .. name
  end
  window:set_right_status(name or "")
end)

return {
  keys = {
    ----------------------------------------------------
    -- Pane (tmux style) -------------------------------
    ----------------------------------------------------
    -- 左右に分割 (Side by Side)
    { key = "%", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    -- 上下に分割 (Top and Bottom)
    { key = '"', mods = "LEADER|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    -- ペインを閉じる
    { key = "x", mods = "LEADER", action = act({ CloseCurrentPane = { confirm = true } }) },
    -- ペインのズーム (最大化)
    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
    -- 次のペインへ
    { key = "o", mods = "LEADER", action = act.ActivatePaneDirection("Next") },
    -- ペイン移動 (hjkl)
    { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
    { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
    { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
    { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },

    ----------------------------------------------------
    -- Tab (tmux style) --------------------------------
    ----------------------------------------------------
    -- 新規タブ作成 (常にHOMEで開く)
    { key = "c", mods = "LEADER", action = act.SpawnCommandInNewTab({ cwd = HOME }) },
    { key = "t", mods = "SUPER", action = act.SpawnCommandInNewTab({ cwd = HOME }) },
    { key = "t", mods = "CTRL|SHIFT", action = act.SpawnCommandInNewTab({ cwd = HOME }) },
    -- 次のタブへ
    { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
    -- 前のタブへ
    { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
    -- タブを閉じる
    { key = "&", mods = "LEADER|SHIFT", action = act({ CloseCurrentTab = { confirm = true } }) },
    -- タブ名を変更 (tmux: Prefix + ,)
    {
      key = ",",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = "Rename tab (empty to reset)",
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      }),
    },

    ----------------------------------------------------
    -- Other -------------------------------------------
    ----------------------------------------------------
    -- コピーモード (tmux標準の [ キー)
    { key = "[", mods = "LEADER", action = act.ActivateCopyMode },
    -- Workspace切り替え
    { key = "s", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "WORKSPACES", title = "Select workspace" }), },
    -- 設定再読み込み
    { key = "r", mods = "LEADER", action = act.ReloadConfiguration },

    -- フォントサイズ (おまけ: CTRL系は残しておくと便利)
    { key = "+", mods = "CTRL", action = act.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
    { key = "0", mods = "CTRL", action = act.ResetFontSize },

    -- ペインサイズ調整 (Leader + resize_pane モード)
    { key = "S", mods = "LEADER|SHIFT", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
  },
  key_tables = {
    resize_pane = {
      { key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
      { key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
      { key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
      { key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
      { key = "Enter", action = "PopKeyTable" },
      { key = "Escape", action = "PopKeyTable" },
    },
  },
}
