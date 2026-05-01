# SDDM theme — `cyberpunk-mr`

Custom QML theme matching the rest of this dotfiles palette
(neon pink/purple over Tokyo-Night-ish dark surfaces). Centered
password card, configurable background and avatar, top-right
clock, bottom power buttons, bottom-left session selector.

Built against SDDM 0.21 (Qt5 + `SddmComponents 2.0`).

## Install

```bash
sudo cp -r cyberpunk-mr /usr/share/sddm/themes/
sudo chown -R root:root /usr/share/sddm/themes/cyberpunk-mr
sudo chmod -R a+rX    /usr/share/sddm/themes/cyberpunk-mr

# Activate
sudo install -d /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=cyberpunk-mr" | sudo tee /etc/sddm.conf.d/theme.conf
```

## Preview without logging out

```bash
sddm-greeter --test-mode --theme /usr/share/sddm/themes/cyberpunk-mr
```

## Customize

Everything tweakable lives in `cyberpunk-mr/theme.conf`:

| Key | What it does |
|---|---|
| `Background` | Path to the background image (relative to theme dir or absolute) |
| `Avatar` | Path to the avatar image — show/hide via `ShowAvatar` |
| `AvatarSize` | Avatar diameter in px |
| `DimOpacity` | Dark overlay strength (0.0–1.0) |
| `AccentColor` | Neon accent (focused input border, avatar ring, power glyphs) |
| `BgColor` / `SurfaceColor` / `BorderColor` / `TextColor` / `MutedTextColor` / `ErrorColor` | Palette |
| `FontFamily` / `FontSize` | Typography |
| `DefaultUser` | Fallback username if SDDM has no last-user record |
| `ShowClock` / `ClockFormat24h` | Top-right clock toggles |

To swap the photo:

```bash
sudo cp /path/to/your.png /usr/share/sddm/themes/cyberpunk-mr/Backgrounds/wallpaper.png
# or for the avatar:
sudo cp /path/to/avatar.png /usr/share/sddm/themes/cyberpunk-mr/Backgrounds/avatar.png
```

No greeter restart needed — SDDM reads the theme fresh on each login.
