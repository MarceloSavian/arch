-- Look & feel
local theme = require("modules.theme")

hl.config({
    general = {
        gaps_in          = 10,
        gaps_out         = 20,
        border_size      = 4,
        col = {
            active_border   = theme.accent,
            inactive_border = theme.inactive,
        },
        layout           = "dwindle",
        resize_on_border = true,
    },

    decoration = {
        rounding = 10,
        blur = {
            enabled = false,
        },
        shadow = {
            enabled        = true,
            range          = 0,
            render_power   = 4,
            color          = "rgba(00000088)",
            color_inactive = "rgba(00000044)",
            scale          = 1.0,
            offset         = { 0, 10 },
        },
        dim_inactive = false,
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    group = {
        col = {
            border_active   = theme.accent,
            border_inactive = theme.inactive,
        },
    },

    cursor = {
        inactive_timeout = 0,
    },

    binds = {
        workspace_back_and_forth = 1,
    },

    misc = {
        layers_hog_keyboard_focus = true,
        focus_on_activate         = true,
    },
})

-- Curves
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("slow",     { type = "bezier", points = { {0, 0.85},   {0.3, 1}    } })
hl.curve("overshot", { type = "bezier", points = { {0.7, 0.6},  {0.1, 1.1}  } })
hl.curve("bounce",   { type = "bezier", points = { {1, 1.6},    {0.1, 0.85} } })

-- Animations
hl.animation({ leaf = "windows",     enabled = true, speed = 5,  bezier = "bounce",   style = "popin" })
hl.animation({ leaf = "border",      enabled = true, speed = 20, bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 5,  bezier = "overshot" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "overshot", style = "slidevert" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5,  bezier = "slow",     style = "popin" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5,  bezier = "default" })
