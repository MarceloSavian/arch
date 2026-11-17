# Arch Linux Dotfiles

Hyprland (Wayland) setup with a unified dark neon palette across waybar, wofi,
kitty, hyprlock, and a custom SDDM theme. Tokyo-Night-ish surfaces, cyberpunk
pink/purple accents, Monocraft + Nerd Font typography.

![Desktop](screenshots/desktop.png)
![Login](screenshots/login.png)
![Lock](screenshots/lock.png)

> Drop the matching PNGs into `screenshots/` — see `screenshots/README.md` for capture commands.

---

## Layout

User-level configs use a [GNU Stow](https://www.gnu.org/software/stow/) style
layout: each top-level dir is a "package" whose contents mirror your `$HOME`.

| Package | What it ships | Stowed to |
|---|---|---|
| `hypr/` | Hyprland config, hyprlock config, helper scripts | `~/.config/hypr/` |
| `waybar/` | Bar config, CSS, scripts | `~/.config/waybar/` |
| `wofi/` | Launcher + powermenu | `~/.config/wofi/` |
| `kitty/` | Terminal config | `~/.config/kitty/` |
| `yazi/` | File manager | `~/.config/yazi/` |
| `gtk/` | GTK 2 theme | `~/.gtkrc-2.0` etc. |
| `shell/` | `.bashrc`, `.zshrc`, `.xprofile`, etc. | `$HOME` |
| `nvidia/` | "Google Chrome (NVIDIA)" / "Steam (NVIDIA)" launchers + `chrome-nvidia` script | `~/.local/share/applications/`, `~/.local/bin/` |
| `wallpapers/` | Wallpaper images (rotated by `awww-daemon`) | `~/wallpapers/` |
| `sddm/` | Custom SDDM login theme — **system-level**, not stowed | see `sddm/README.md` |

---

## Quick install

```bash
# 1. Clone
git clone https://github.com/MarceloSavian/arch.git ~/arch
cd ~/arch

# 2. Install packages (see the table below for what each is for)
sudo pacman -S --needed \
    hyprland hyprlock hypridle hyprpaper awww swaync \
    waybar wofi kitty yazi \
    sddm qt5-graphicaleffects \
    grim slurp swappy hyprpicker wl-clipboard cliphist \
    brightnessctl playerctl pavucontrol \
    polkit-kde-agent network-manager-applet blueman \
    thunar tesseract jq stow rsync \
    noto-fonts noto-fonts-emoji otf-font-awesome ttf-nerd-fonts-symbols \
    ttf-input-nerd ttf-jetbrains-mono-nerd ttf-material-icons neovim

# AUR (use yay or paru)
yay -S --needed otf-monocraft bibata-cursor-theme eww

```

Reboot (or `sudo systemctl restart sddm` from a TTY) and you're in.

---

## What each package does

### Wayland / compositor

| Package | Purpose |
|---|---|
| `hyprland` | Wayland compositor |
| `hyprlock` | Lock screen (bound to `SUPER+SHIFT+Q`) |
| `hypridle` | Idle daemon — auto-lock on inactivity / lid close |
| `awww` | Wallpaper daemon (`awww-daemon` rotates `~/wallpapers/` every 10 min) |

### Bar / launchers / shell

| Package | Purpose |
|---|---|
| `waybar` | Top status bar (sketchybar-style pill modules) |
| `wofi` | App launcher + powermenu (bound to `SUPER+D` / `SUPER+B`) |
| `swaync` | Notification daemon |
| `kitty` | Terminal |
| `yazi` | TUI file manager (bound to `SUPER+E`) |

### Login

| Package | Purpose |
|---|---|
| `sddm` | Display manager that renders the login theme in `sddm/cyberpunk-mr/` |
| `qt5-graphicaleffects` | Required for blur / fancy effects in the SDDM theme |

### Utilities pulled in by keybinds / scripts

| Package | What it's for |
|---|---|
| `grim` + `slurp` + `swappy` + `hyprpicker` | Screenshots (hyprpicker freezes the screen) (`SUPER+PRINT`, `CTRL+SHIFT+4`) |
| `wl-clipboard` + `cliphist` | Clipboard history |
| `brightnessctl` | Brightness keys |
| `playerctl` | Media keys |
| `pavucontrol` | GUI audio mixer |
| `polkit-kde-agent` | Auth prompts (sudo dialogs) |
| `tesseract` | OCR for `SUPER+O` (screenshot → clipboard text) |
| `blueman` | Bluetooth tray |
| `network-manager-applet` | Network tray |
| `bibata-cursor-theme` | Cursor theme |

### Fonts

The whole UI assumes:

- `ttf-monocraft` — primary UI font
- `ttf-input-nerd` (Nerd Font variant of Input Mono) — fallback + glyphs
- `ttf-font-awesome` — waybar icon glyphs
- Material Icons + Material Design Icons — used by some pill modules

If a font is missing, waybar / wofi will fall back silently but icons may render as tofu.

---

## Manual / per-machine bits

### `awww` wallpaper daemon

`hypr/.config/hypr/scripts/rotate-wallpaper.sh` rotates `~/wallpapers/` every
10 minutes. Adjust `INTERVAL` inside the script.

### Display layout

`hypr/.config/hypr/modules/monitors.lua` hardcodes two monitors:

```lua
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@144", position = "1920x0", scale = 1 })
hl.monitor({ output = "eDP-1",    mode = "1920x1080@60",  position = "0x0",    scale = 1 })
```

Edit those lines or replace with `hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })` for autodetect.

### NVIDIA env vars

Apps render on the integrated GPU by default so a hybrid laptop's NVIDIA
card can power down. Run games / heavy apps on NVIDIA with `prime-run <app>`
(package `nvidia-prime`).

The `nvidia/` package adds launcher entries for wofi (SUPER+D):

- **Google Chrome (NVIDIA)** runs `prime-run google-chrome-stable --ozone-platform=x11`.
  Chrome has to go through XWayland: on native Wayland it stays on the iGPU, and
  forcing it (`--render-node-override`) crashes Hyprland. Chrome is single-instance,
  so close the normal Chrome first (the launcher tells you if it's running).
- **Steam (NVIDIA)** runs `prime-run steam`; every game launched from it inherits
  the NVIDIA offload. Hidden until Steam is installed.

Note: `nvidia-smi` does not list Chrome's sandboxed GPU process. To verify, open
`chrome://gpu` and check the GL_RENDERER line.

### Hyprland config (Lua)

The Hyprland config uses the Lua format (Hyprland 0.57+): `hyprland.lua`
just `require`s the files in `modules/` (env, monitors, autostart, look,
input, rules, binds). Validate after editing with:

```bash
Hyprland --verify-config -c ~/.config/hypr/hyprland.lua
```

---

## Reproducing this setup with an AI

Hand this README + the `~/arch/` repo URL to an AI agent and tell it:

> "Reproduce the setup described in `https://github.com/MarceloSavian/arch`
> on a fresh Arch install. Use the package list and install commands in
> `README.md`. Stow the user configs, install the SDDM theme, enable sddm.
> Don't push anything; show me each command before running it."

The package list, stow commands, and SDDM install steps above are written
to be copy-pasteable. The agent should be able to walk a clean machine to
a working state without further input beyond confirming sudo commands.

---

## Keybinds cheatsheet

| Keys | Action |
|---|---|
| `SUPER+RETURN` | Open kitty |
| `SUPER+Q` | Close window |
| `CTRL+Q` | Lock screen (hyprlock) |
| `SUPER+D` | App launcher (wofi) |
| `SUPER+B` | Power menu |
| `SUPER+E` | File manager (yazi in kitty) |
| `SUPER+W` | Workspace overview (eww) |
| `SUPER+SHIFT+W` | Shuffle wallpaper |
| `SUPER+O` | OCR screenshot region → clipboard |
| `SUPER+PRINT` | Freeze + screenshot full screen |
| `PRINT` | Freeze + screenshot region |
| `CTRL+SHIFT+4` | Quick region screenshot to `~/Pictures/Screenshots/` |
| `SUPER+SHIFT+R` | Reload Hyprland |
| `SUPER+1..9,0` | Jump to workspace |
| `SUPER+SHIFT+1..9,0` | Move window to workspace |
