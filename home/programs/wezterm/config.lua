-- References: [dotfiles/.config/wezterm at main · aperum/dotfiles](https://github.com/aperum/dotfiles/tree/main/.config/wezterm)

-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- font.lua
local function font_with_fallback(name, params)
  local names = { name, "Hack Nerd Font Mono" }
  return wezterm.font_with_fallback(names, params)
end

local term_font = "FiraMono Nerd Font"
if wezterm.target_triple == 'x86_64-pc-windows-msvc' or wezterm.target_triple == 'aarch64-apple-darwin' then
  term_font = "FiraMono Nerd Font Mono"
end

config.font_size = 14
config.line_height = 1.0
config.font = font_with_fallback(term_font)
config.font_rules = {
  {
    italic = true,
    font = font_with_fallback(term_font, { italic = true }),
  },
  {
    italic = true,
    intensity = "Bold",
    font = font_with_fallback(term_font, { bold = true, italic = true }),
  },
  {
    intensity = "Bold",
    font = font_with_fallback(term_font, { bold = true }),
  },
}

-- colors.lua
config.color_scheme = "Tokyo Night"
config.window_background_opacity = 0.97

-- keybinds.lua - Coordinated with Aerospace, Zellij, and Neovim
config.keys = {
  -- Terminal-level operations
  { key = 't', mods = 'CMD', action = act.SpawnTab('CurrentPaneDomain') },
  { key = 'w', mods = 'CMD', action = act.CloseCurrentTab { confirm = true } },
  { key = 'Enter', mods = 'CMD', action = act.ToggleFullScreen },
  
  -- Tab navigation
  { key = '[', mods = 'CMD|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = ']', mods = 'CMD|SHIFT', action = act.ActivateTabRelative(1) },
  
  -- Don't bind Cmd+1-9 (let Aerospace handle workspace switching)
  -- Don't bind Ctrl+t (let Zellij handle multiplexing)
  
  -- Keep some useful terminal shortcuts that don't conflict
  { key = 'k', mods = 'CMD', action = act.ClearScrollback('ScrollbackAndViewport') },
  { key = 'r', mods = 'CMD', action = act.ReloadConfiguration },
}
-- mousebinds.lua
config.mouse_bindings = {
  -- Change the default click behavior so that it only selects
  -- text and doesn't open hyperlinks
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },

  -- and make CMD-Click open hyperlinks
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = act.OpenLinkAtMouseCursor,
  },
  {
    event = { Down = { streak = 3, button = 'Left' } },
    action = wezterm.action.SelectTextAtMouseCursor 'SemanticZone',
    mods = 'NONE',
  },
}

-- general random config
config.scrollback_lines = 7000
config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = 'NeverPrompt'

-- Set to PowerShell for Windows
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
end

return config
