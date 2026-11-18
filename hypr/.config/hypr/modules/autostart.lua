-- Autostart (replaces exec-once)
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Wallpaper daemon + rotation every 10 minutes
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("sh ~/.config/hypr/scripts/rotate-wallpaper.sh")

    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")   -- text clipboard history
    hl.exec_cmd("wl-paste --type image --watch cliphist store")  -- image clipboard history
    hl.exec_cmd("sleep 3 && /usr/lib/kdeconnectd")
end)
