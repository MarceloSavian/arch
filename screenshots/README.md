# Screenshots

Drop screenshots here with these exact names so the top-level README references them:

| File | What to capture |
|---|---|
| `desktop.png` | Hyprland desktop with waybar visible, ideally over the cyberpunk wallpaper |
| `login.png` | SDDM login — capture from `sddm-greeter --test-mode --theme /usr/share/sddm/themes/cyberpunk-mr` (run from a kitty window, screenshot the popup with `grim`) |
| `lock.png` | Hyprlock screen — trigger with `SUPER+SHIFT+Q`, take a screenshot from a second machine / phone, OR grab the scene with `grim` running on a delay before locking |

## Quick capture commands

```bash
# Desktop (full screen of focused output)
grim -o "$(hyprctl monitors -j | jq -r '.[0].name')" ~/arch/screenshots/desktop.png

# SDDM test-mode (run greeter, then in another terminal):
grim -g "$(slurp)" ~/arch/screenshots/login.png

# Lock screen (5s delay so you have time to lock)
sh -c 'sleep 5 && grim ~/arch/screenshots/lock.png' & hyprlock
```
