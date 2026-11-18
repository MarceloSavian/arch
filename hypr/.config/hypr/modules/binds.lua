-- Keybinds
local theme   = require("modules.theme")
local mainMod = "SUPER"
local scripts = "~/.config/hypr/scripts/"
local exec    = hl.dsp.exec_cmd

local function key(k) return mainMod .. " + " .. k end

-- Wofi menus
hl.bind(key("D"),      exec("pkill wofi || wofi --show drun --term=kitty --style ~/.config/wofi/style.css --width=35% --height=50% --columns 1 -I"))
hl.bind(key("B"),      exec("pkill wofi || sh ~/.config/wofi/scripts/powermenu.sh"))
hl.bind(key("period"), exec("pkill wofi || sh ~/.config/wofi/scripts/wofi-emoji.sh"))
hl.bind(key("V"),      exec("pkill wofi || cliphist list | wofi --dmenu --style ~/.config/wofi/style.css | cliphist decode | wl-copy"))

-- Resize submap (active border turns red while resizing)
hl.bind(key("R"), function()
    hl.config({ general = { col = { active_border = theme.resize } } })
    hl.dispatch(hl.dsp.submap("resize"))
end)
hl.define_submap("resize", function()
    hl.bind("right", hl.dsp.window.resize({ x =  15, y =   0, relative = true }), { repeating = true })
    hl.bind("left",  hl.dsp.window.resize({ x = -15, y =   0, relative = true }), { repeating = true })
    hl.bind("up",    hl.dsp.window.resize({ x =   0, y = -15, relative = true }), { repeating = true })
    hl.bind("down",  hl.dsp.window.resize({ x =   0, y =  15, relative = true }), { repeating = true })
    hl.bind("escape", function()
        hl.config({ general = { col = { active_border = theme.accent } } })
        hl.dispatch(hl.dsp.submap("reset"))
    end)
end)

-- Scroll workspaces with mainMod + scroll wheel
hl.bind(key("mouse_down"), hl.dsp.focus({ workspace = "e-1" }))
hl.bind(key("mouse_up"),   hl.dsp.focus({ workspace = "e+1" }))

-- Main binds
hl.bind(key("return"),      exec("kitty"))
hl.bind(key("Q"),           hl.dsp.window.close())
hl.bind("CTRL + Q",         exec(scripts .. "lock.sh")) -- THE lock: SDDM login screen (same as boot), any user
hl.bind(key("E"),           exec("kitty --hold -e yazi"))
hl.bind(key("G"),           hl.dsp.group.toggle())
hl.bind(key("SHIFT + G"),   hl.dsp.window.move({ out_of_group = true }))
hl.bind(key("CTRL + G"),    hl.dsp.window.move({ into_group = "right" }))
hl.bind(key("F"),           hl.dsp.window.fullscreen())
hl.bind(key("A"),           hl.dsp.window.move({ workspace = "special:special" }))
hl.bind(key("SHIFT + R"),   hl.dsp.reload_config())
hl.bind(key("P"),           hl.dsp.window.pseudo())              -- dwindle
hl.bind(key("SHIFT + J"),   hl.dsp.layout("togglesplit"))        -- dwindle
hl.bind(key("SHIFT + W"),   exec("sh " .. scripts .. "shuffle-wallpaper.sh"))
hl.bind(key("O"),           exec('f=$(mktemp --suffix=.png) && grim -g "$(slurp)" "$f" && tesseract "$f" - | wl-copy; rm -f "$f"'))
hl.bind(key("N"),           exec("swaync-client -t"))
hl.bind(key("U"),           hl.dsp.layout("swapwithmaster"))
hl.bind("ALT + F10",        hl.dsp.pass({ window = "class:^(com\\.obsproject\\.Studio)$" }))
hl.bind(key("SPACE"),       hl.dsp.window.float())

-- SUPER+Tab: cycle the active group if focused window is in one, else jump to last window
-- (the old config bound both focuscurrentorlast and changegroupactive to this key)
hl.bind(key("Tab"), function()
    hl.dispatch(hl.dsp.focus({ last = true }))
    hl.dispatch(hl.dsp.group.next())
end)

-- Toggle gaps + rounding (was scripts/toggle-gaps.sh)
local gapsOn = true
hl.bind(key("SHIFT + H"), function()
    gapsOn = not gapsOn
    if gapsOn then
        hl.config({ general = { gaps_in = 10, gaps_out = 20 }, decoration = { rounding = 10 } })
    else
        hl.config({ general = { gaps_in = 0,  gaps_out = 0  }, decoration = { rounding = 0 } })
    end
end)

-- Hardware keys
hl.bind("XF86MonBrightnessDown", exec("brightnessctl set 10%-"), { repeating = true })
hl.bind("XF86MonBrightnessUp",   exec("brightnessctl set +10%"), { repeating = true })

local notifyVol = " && sh " .. scripts .. "notify-volume.sh"
hl.bind("XF86AudioRaiseVolume", exec("pactl -- set-sink-volume @DEFAULT_SINK@ +5%" .. notifyVol), { repeating = true })
hl.bind("XF86AudioLowerVolume", exec("pactl -- set-sink-volume @DEFAULT_SINK@ -5%" .. notifyVol), { repeating = true })
hl.bind("XF86AudioMute",        exec("pactl set-sink-mute @DEFAULT_SINK@ toggle" .. notifyVol))

hl.bind("XF86AudioPlay", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", exec("playerctl previous"),   { locked = true })
hl.bind("XF86AudioNext", exec("playerctl next"),       { locked = true })

-- Volume with mainMod + [ / ]
hl.bind(key("bracketleft"),  exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind(key("bracketright"), exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })


-- Focus: arrows and hjkl
for k, dir in pairs({ left = "left", right = "right", up = "up", down = "down",
                      H = "left", L = "right", K = "up", J = "down" }) do
    hl.bind(key(k), hl.dsp.focus({ direction = dir }))
end

-- Move window: mainMod + SHIFT + arrows
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(key("SHIFT + " .. dir), hl.dsp.window.move({ direction = dir }))
end

hl.bind(key("CTRL + left"),  hl.dsp.focus({ workspace = "e-1" }))
hl.bind(key("CTRL + right"), hl.dsp.focus({ workspace = "e+1" }))

-- Special workspace
hl.bind(key("MINUS"), hl.dsp.workspace.toggle_special("special"))

-- Workspaces 1-10: switch / move / move silently
for i = 1, 10 do
    local k = tostring(i % 10)
    hl.bind(key(k),            hl.dsp.focus({ workspace = i }))
    hl.bind(key("SHIFT + " .. k), hl.dsp.window.move({ workspace = i }))
    hl.bind(key("CTRL + " .. k),  hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Move/resize windows with mainMod + LMB/RMB drag
hl.bind(key("mouse:272"), hl.dsp.window.drag(),   { mouse = true })
hl.bind(key("mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- Screenshots
hl.bind(key("Print"),      exec(scripts .. "freeze-screenshot.sh 0"))
hl.bind("Print",           exec(scripts .. "freeze-screenshot.sh 1"))
hl.bind("CTRL + Print",    exec('grim -g "$(slurp)" - | swappy -f -'))
hl.bind("CTRL + SHIFT + 4", exec([[d=~/Pictures/Screenshots && mkdir -p "$d" && f="$d/screenshot-$(date +%s).png" && grim -g "$(slurp)" "$f" && wl-copy -t image/png < "$f"]]))
