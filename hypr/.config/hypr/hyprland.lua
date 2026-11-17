-- Hyprland Lua config (converted from hyprland.conf for Hyprland 0.57+)
-- Docs: https://wiki.hypr.land/configuring/
--
-- Each module is require()'d separately, so an error in one file does not
-- stop the others from loading. Check for errors with:
--   Hyprland --verify-config -c ~/.config/hypr/hyprland.lua
--   hyprctl configerrors

require("modules.env")
require("modules.monitors")
require("modules.autostart")
require("modules.look")
require("modules.input")
require("modules.rules")
require("modules.binds")
