-- Layer rules
hl.layer_rule({ name = "waybar-blur",            match = { namespace = "waybar" },    blur = true })
hl.layer_rule({ name = "no_anim_for_selection",  match = { namespace = "selection" }, no_anim = true })

-- Window rules
hl.window_rule({ name = "pavucontrol-rules",     match = { class = "^(pavucontrol)$" },   max_size = { 600, 800 }, center = true, float = true })
hl.window_rule({ name = "libreoffice-tile",      match = { class = "^(libreoffice)$" },   tile = true })
hl.window_rule({ name = "blueman-float",         match = { class = "^(blueman-manager)$" }, float = true })
hl.window_rule({ name = "libreoffice-suppress",  match = { class = "^(.*libreoffice.*)$" }, suppress_event = "maximize" })
hl.window_rule({ name = "calculator-rules",      match = { class = "^(org.gnome.Calculator)$" }, size = { 490, 600 }, float = true })
hl.window_rule({ name = "polkit-float",          match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" }, float = true })
hl.window_rule({ name = "confirm-replace-float", match = { title = "^(Confirm to replace files)$" }, float = true })
hl.window_rule({ name = "file-op-float",         match = { title = "^(File Operation Progress)$" }, float = true })
hl.window_rule({ name = "eog-rules",             match = { class = "^(eog)$" },  center = true, float = true })
hl.window_rule({ name = "vlc-rules",             match = { class = "^(vlc)$" },  center = true, float = true })
hl.window_rule({ name = "imv-float",             match = { class = "^(imv)$" },  float = true })
hl.window_rule({ name = "steam-news-float",      match = { title = "^(Steam - News)$" }, float = true })
