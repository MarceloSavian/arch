-- Input
hl.config({
    input = {
        kb_layout          = "us",
        kb_variant         = "",
        kb_model           = "",
        kb_options         = "ctrl:swap_lalt_lctl,srvrkeys:none", -- Left Alt acts as Ctrl (Mac-style Cmd+C/V), Left Ctrl acts as Alt
        kb_rules           = "",
        numlock_by_default = true,
        follow_mouse       = 1,
        sensitivity        = 0, -- -1.0 - 1.0, 0 means no modification
        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Per-device
hl.device({ name = "epic-mouse-v1",          sensitivity = -0.5 })
hl.device({ name = "logitech-mx-master-3s",  natural_scroll = true })
