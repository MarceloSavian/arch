# Screenshots

Drop screenshots here with these exact names so the top-level README references them:

| File | What to capture |
|---|---|
| `desktop.png` | Hyprland desktop with waybar visible, ideally over the cyberpunk wallpaper |
| `login.png` | SDDM login — capture from `sddm-greeter --test-mode --theme /usr/share/sddm/themes/cyberpunk-mr` (run from a kitty window, screenshot the popup with `grim`) |
| `lock.png` | Lock screen = the SDDM login screen (see `login.png`) |

## Quick capture commands

```bash
# Desktop (full screen of focused output)
grim -o "$(hyprctl monitors -j | jq -r '.[0].name')" ~/arch/screenshots/desktop.png

# SDDM test-mode (run greeter, then in another terminal):
grim -g "$(slurp)" ~/arch/screenshots/login.png

# Lock screen (5s delay so you have time to lock)
```
