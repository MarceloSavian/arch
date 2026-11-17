-- Monitors
-- Autodetect fallback: hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@144", position = "1920x0", scale = 1 })
hl.monitor({ output = "eDP-1",    mode = "1920x1080@60",  position = "0x0",    scale = 1 })

-- Workspaces 1-5 on the external monitor, 6-10 on the laptop, all persistent
for i = 1, 10 do
    hl.workspace_rule({
        workspace  = tostring(i),
        monitor    = (i <= 5) and "HDMI-A-1" or "eDP-1",
        persistent = true,
    })
end
