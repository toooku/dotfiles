-- Pull in the wezterm API
local wezterm = require "wezterm"
local config = wezterm.config_builder()

-- Window size
config.initial_cols = 120
config.initial_rows = 28

-- Font
config.font_size = 14

-- Base color scheme
config.color_scheme = "ayu_light"

-- ======================
-- Colors (oxocarbon-ish light)
-- ======================
config.colors = {
  foreground = "#161616",
  background = "#ffffff",

  cursor_bg = "#161616",
  cursor_fg = "#ffffff",

  selection_bg = "#e0e0e0",
  selection_fg = "#161616",

  -- ANSI colors（★緑を抑える）
  ansi = {
    "#262626", -- black
    "#da1e28", -- red
    "#198038", -- green（ライム感を抑えた濃い緑）
    "#f1c21b", -- yellow
    "#0f62fe", -- blue
    "#8a3ffc", -- magenta
    "#1192e8", -- cyan
    "#f4f4f4", -- white
  },
  brights = {
    "#393939",
    "#fa4d56",
    "#24a148", -- bright green（控えめ）
    "#f1c21b",
    "#4589ff",
    "#a56eff",
    "#33b1ff",
    "#ffffff",
  },

  -- ======================
  -- Tab bar (Light)
  -- ======================
  tab_bar = {
    background = "#f3f4f5",

    active_tab = {
      bg_color = "#ffffff",
      fg_color = "#5c6166",
      intensity = "Bold",
      underline = "None",
      italic = false,
    },

    inactive_tab = {
      bg_color = "#e6e7e8",
      fg_color = "#8a9199",
    },

    inactive_tab_hover = {
      bg_color = "#dcdedf",
      fg_color = "#5c6166",
    },

    new_tab = {
      bg_color = "#e6e7e8",
      fg_color = "#8a9199",
    },

    new_tab_hover = {
      bg_color = "#dcdedf",
      fg_color = "#5c6166",
    },
  },
}

-- Tab bar options
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false

config.keys = {
  -- Alt + v で垂直分割 (Vertical)
  {
    key = 'v',
    mods = 'ALT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  -- Alt + s で水平分割 (Split)
  {
    key = 's',
    mods = 'ALT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  -- Alt + 矢印キーでペイン間を移動
  { key = 'LeftArrow',  mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Down' },
}

-- 日本語入力（IME）をウィンドウ内のカーソル位置で表示する
config.use_ime = true

config.font = wezterm.font_with_fallback({
  -- メインの英数フォント
  { family = 'JetBrains Mono', weight = 'Medium' },
  -- 日本語用フォント
  { family = 'Hiragino Sans', weight = 'Medium' },
})

return config
