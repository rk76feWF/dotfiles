-- Hammerspoon configuration
-- Managed by nix-darwin dotfiles

hs.window.animationDuration = 0

local mod = { "ctrl", "alt" }

-- Window management (vim-style)
-- Ctrl+Option+h: left half
hs.hotkey.bind(mod, "h", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local screen = win:screen():frame()
  win:setFrame(hs.geometry.rect(screen.x, screen.y, screen.w / 2, screen.h))
end)

-- Ctrl+Option+l: right half
hs.hotkey.bind(mod, "l", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local screen = win:screen():frame()
  win:setFrame(hs.geometry.rect(screen.x + screen.w / 2, screen.y, screen.w / 2, screen.h))
end)

-- Ctrl+Option+u: top-left quarter
hs.hotkey.bind(mod, "u", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local screen = win:screen():frame()
  win:setFrame(hs.geometry.rect(screen.x, screen.y, screen.w / 2, screen.h / 2))
end)

-- Ctrl+Option+i: top-right quarter
hs.hotkey.bind(mod, "i", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local screen = win:screen():frame()
  win:setFrame(hs.geometry.rect(screen.x + screen.w / 2, screen.y, screen.w / 2, screen.h / 2))
end)

-- Ctrl+Option+j: bottom-left quarter
hs.hotkey.bind(mod, "j", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local screen = win:screen():frame()
  win:setFrame(hs.geometry.rect(screen.x, screen.y + screen.h / 2, screen.w / 2, screen.h / 2))
end)

-- Ctrl+Option+k: bottom-right quarter
hs.hotkey.bind(mod, "k", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local screen = win:screen():frame()
  win:setFrame(hs.geometry.rect(screen.x + screen.w / 2, screen.y + screen.h / 2, screen.w / 2, screen.h / 2))
end)

-- Ctrl+Option+Return: maximize
hs.hotkey.bind(mod, "return", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:setFrame(win:screen():frame())
end)

-- Option+Space: toggle WezTerm (launch/focus or hide)
hs.hotkey.bind({ "alt" }, "space", function()
  local app = hs.application.get("WezTerm")
  if app and app:isFrontmost() then
    app:hide()
  elseif app then
    app:activate()
  else
    hs.application.launchOrFocus("WezTerm")
  end
end)
