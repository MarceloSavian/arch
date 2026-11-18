# Arch Linux Dotfiles

Hyprland (Wayland) setup with a unified dark neon palette across waybar, wofi,
kitty and a custom SDDM theme (which is also the lock screen). Tokyo-Night-ish
surfaces, cyberpunk pink/purple accents, Monocraft + Nerd Font typography.

![Desktop](screenshots/desktop.png)
![Login](screenshots/login.png)

> See `screenshots/README.md` for capture commands.

> **Rebuilding with an AI?** Point it at [`AGENTS.md`](AGENTS.md) first — it has the
> step-by-step rebuild + verification procedure and every pitfall hit on this machine.

---

## Layout

User-level configs use a [GNU Stow](https://www.gnu.org/software/stow/) layout:
each top-level dir is a "package" whose contents mirror your `$HOME`.

| Package | What it ships | Stowed to |
|---|---|---|
| `hypr/` | Hyprland config (Lua, `modules/`), hypridle config, helper scripts | `~/.config/hypr/` |
| `waybar/` | Bar config, CSS, scripts | `~/.config/waybar/` |
| `wofi/` | Launcher, power menu, emoji picker | `~/.config/wofi/` |
| `kitty/` | Terminal config | `~/.config/kitty/` |
| `yazi/` | File manager | `~/.config/yazi/` |
| `gtk/` | GTK 2/3/4 dark theme + cursor settings | `~/.gtkrc-2.0`, `~/.config/gtk-{3,4}.0/` (`--no-folding`) |
| `shell/` | `.bashrc`, `.bash_profile` (adds `~/.local/bin` to PATH), `.bash_logout` | `$HOME` |
| `nvidia/` | "Google Chrome (NVIDIA)" / "Steam (NVIDIA)" launchers + `chrome-nvidia` | `~/.local/share/applications/`, `~/.local/bin/` (`--no-folding`) |
| `wallpapers/` | Wallpaper images (rotated by `awww-daemon`) | copied to `~/wallpapers/` |
| `sddm/` | SDDM login theme (also the lock screen) — **system-level**, copied | `/usr/share/sddm/themes/` |
| `system/` | System files `install.sh` copies into `/etc` | `/etc/X11/xorg.conf.d/` |

Scripts at the repo root:

| Script | Purpose |
|---|---|
| `install.sh` | Full setup (system + current user). Idempotent. `--user` = per-user part only, no sudo. |
| `add-user.sh <user> ["Name"]` | Create another account with the same setup (sudo, groups, dotfiles, Claude Code). |

---

## Quick install

```bash
git clone https://github.com/MarceloSavian/arch.git ~/arch
~/arch/install.sh
```

Run it in a real terminal as your normal user (it asks for your sudo password).
It is idempotent, so re-running it after a `git pull` is safe. It:

1. enables **multilib** (Steam / 32-bit drivers)
2. installs every package below (plus NVIDIA drivers when an NVIDIA GPU is detected)
3. bootstraps **yay** and installs the AUR packages
4. backs up conflicting dotfiles to `~/dotfiles-backup-<timestamp>/`, removes broken
   links into the repo, and stows the packages
5. installs the SDDM theme and the login-screen Xorg settings (no VT switching, iGPU only)
6. enables services: sddm, bluetooth, NetworkManager, nordvpnd, hypridle (all users), PipeWire
7. sets defaults: Chrome as browser, Thunar for folders, dark GTK theme
8. validates the Hyprland config

`install.sh` is the source of truth for the package list.

### After it finishes

1. **Reboot** (needed for groups, PATH, the Xorg settings).
2. `nordvpn login` (opens a browser).
3. Open Chrome once, then **Settings → System → turn off "Continue running background
   apps"** — otherwise closing Chrome leaves it running and the NVIDIA launcher refuses.
4. To push this repo: `gh auth login && gh auth setup-git`.
5. Steam's first launch silently downloads ~500 MB before any window appears — wait.

## Adding another user

```bash
~/arch/add-user.sh alice "Alice"
```

Creates the account in `wheel` (sudo) + `nordvpn`, asks for its password, copies this
repo to its home, runs `install.sh --user` as that user and installs Claude Code for it.
System packages are shared, so they need nothing else. The new user then logs in from
SDDM (↑↓ on the login card picks the user) and signs in to their own accounts.

## Updating

```bash
git -C ~/arch pull && ~/arch/install.sh          # you (system + your dotfiles)
sudo -u alice -H git -C /home/alice/arch pull    # each other user: their own copy
```

Config files are symlinks into each user's copy, so a `git pull` is enough for most
changes. Re-run `install.sh` when packages, the SDDM theme or `system/` files changed.
Hyprland reloads its config automatically; waybar needs a restart; other users pick up
changes at their next login.

---

## What each package does

### Wayland / compositor

| Package | Purpose |
|---|---|
| `hyprland` | Wayland compositor |
| `hypridle` | Lock/unlock events: lock before sleep, restore workspace + XWayland socket after unlock |
| `awww` | Wallpaper daemon (`awww-daemon` rotates `~/wallpapers/` every 10 min) |

### Bar / launchers / shell

| Package | Purpose |
|---|---|
| `waybar` | Top status bar (sketchybar-style pill modules) |
| `wofi` | App launcher + power menu (`SUPER+D` / `SUPER+B`) |
| `swaync` | Notification daemon |
| `kitty` | Terminal |
| `yazi` + `neovim` | TUI file manager (`SUPER+E`), nvim as its editor |
| `thunar` | GUI file manager, default for folders |

### Audio

| Package | Purpose |
|---|---|
| `pipewire` + `wireplumber` | Sound server + session manager (no sound without both) |
| `pipewire-pulse` | PulseAudio API: `pactl`, waybar volume, pavucontrol, Chrome |
| `pipewire-alsa` | Apps that talk to ALSA directly |

### Graphics (hybrid AMD + NVIDIA)

| Package | Purpose |
|---|---|
| `nvidia-open` + `nvidia-utils` + `lib32-nvidia-utils` | NVIDIA driver (installed only when an NVIDIA GPU is found) |
| `nvidia-prime` | `prime-run <app>` — run one app on the NVIDIA GPU |
| `lib32-mesa` + `lib32-vulkan-radeon` | 32-bit AMD drivers for Steam |
| `mesa-utils` | `glxinfo` to check which GPU renders (`glxinfo -B` vs `prime-run glxinfo -B`) |

### Apps

| Package | Purpose |
|---|---|
| `google-chrome` (AUR) | Default browser |
| `spotify` (AUR) | Music; the waybar media pills control it |
| `nordvpn-bin` (AUR) | VPN; waybar pill + wofi connect menu (`nordvpnd` service, `nordvpn` group) |
| `steam` (multilib) | Games; use the **Steam (NVIDIA)** launcher |
| `github-cli` | `gh auth` for pushing this repo |
| `kdeconnect` | Phone integration (autostarted) |

### Login / lock

| Package | Purpose |
|---|---|
| `sddm` | Login screen **and lock screen** (theme in `sddm/cyberpunk-mr/`, with user switcher) |
| `qt5-graphicaleffects` | Background blur in the SDDM theme |

### Utilities pulled in by keybinds / scripts

| Package | What it's for |
|---|---|
| `grim` + `slurp` + `swappy` + `hyprpicker` | Screenshots (hyprpicker freezes the screen) |
| `wl-clipboard` + `cliphist` | Clipboard history (`SUPER+V`) |
| `brightnessctl` | Brightness keys |
| `playerctl` | Media keys, spotify pills |
| `pavucontrol` | GUI audio mixer (right-click the volume pill) |
| `polkit-kde-agent` | Auth prompts (sudo dialogs) |
| `tesseract` + `tesseract-data-eng` | OCR for `SUPER+O` (screenshot → clipboard text) |
| `bluez` + `bluez-utils` + `blueman` | Bluetooth stack, `bluetoothctl`, tray/manager |
| `network-manager-applet` | Network tray |
| `jq`, `libnotify`, `python`, `pacman-contrib` | Used by scripts |
| `qt6ct` | Qt theming (`QT_QPA_PLATFORMTHEME=qt6ct`) |
| `bibata-cursor-theme` (AUR) | Cursor theme |
| `gnome-themes-extra` + `breeze-icons` | Adwaita-dark (GTK 2) + breeze-dark icons |

### Fonts

- `otf-monocraft` (AUR) — primary UI font
- `ttf-input-nerd` (Nerd Font variant of Input Mono) — fallback + glyphs
- `ttf-jetbrains-mono-nerd` — kitty
- `otf-font-awesome` — waybar icon glyphs
- `ttf-material-icons` — spotify / memory pills

If a font is missing, waybar / wofi fall back silently but icons may render as tofu.

---

## Manual / per-machine bits

### Display layout

`hypr/.config/hypr/modules/monitors.lua` hardcodes two monitors (and pins workspaces
1-5 to the external one, 6-10 to the laptop):

```lua
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@144", position = "1920x0", scale = 1 })
hl.monitor({ output = "eDP-1",    mode = "1920x1080@60",  position = "0x0",    scale = 1 })
```

Replace with `hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })` for autodetect.

### Hybrid GPU (AMD iGPU + NVIDIA dGPU)

Apps render on the integrated GPU by default. Run games / heavy apps on NVIDIA with
`prime-run <app>`. The `nvidia/` package adds launcher entries for wofi (`SUPER+D`):

- **Google Chrome (NVIDIA)** runs `prime-run google-chrome-stable --ozone-platform=x11`.
  Chrome has to go through XWayland: on native Wayland it stays on the iGPU, and
  forcing it (`--render-node-override`) crashes Hyprland. Chrome is single-instance,
  so close the normal Chrome first (the launcher tells you if it's running).
- **Steam (NVIDIA)** runs `prime-run steam`; every game launched from it inherits
  the NVIDIA offload. Hidden until Steam is installed.

`nvidia-smi` does not list Chrome's sandboxed GPU process — check `chrome://gpu` (GL_RENDERER).

### Lock screen

There is **one** lock screen: the SDDM login screen you see at boot. `CTRL+Q`, power
menu → Lock and suspend/lid all go there (`hypr/.config/hypr/scripts/lock.sh`); your
session keeps running behind it and logging in again returns to it. Ctrl+Alt+F-keys VT
switching is disabled everywhere so nobody can bypass it. Details in `AGENTS.md`.

### Keyboard

Left Alt and Left Ctrl are swapped (`ctrl:swap_lalt_lctl`) for Mac-style ⌘C/⌘V, and
`srvrkeys:none` disables Ctrl+Alt+F-key VT switching. Both in `modules/input.lua`.

### Hyprland config (Lua)

`hyprland.lua` just `require`s the files in `modules/` (env, monitors, autostart, look,
input, rules, binds, theme). Validate after editing:

```bash
Hyprland --verify-config -c ~/.config/hypr/hyprland.lua
hyprctl configerrors; hyprctl deprecated-config
```

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Hyprland shows "safe mode" | It crashed and restarted without your config. `hyprctl dispatch 'hl.dsp.exit()'`, log in again; see `~/.cache/hyprland/hyprlandCrashReport*.txt`. |
| No sound / volume pill shows 0% | `systemctl --user status pipewire pipewire-pulse wireplumber`; apps started before PipeWire (Chrome, waybar) need a restart. |
| Steam / X11 apps: "Can't open display" | XWayland socket was removed by the lock screen: `ln -s /tmp/.X11-unix/X1_ /tmp/.X11-unix/X1` (normally `unlock.sh` does this). |
| New terminal covers the old one | kitty re-opened maximized: keep `remember_window_size no` in `kitty.conf`; `SUPER+F` un-maximizes. |
| Chrome (NVIDIA) refuses to start | Chrome is still running (background apps setting) — see "After it finishes". |
| Login screen not updated | Theme changes need `install.sh` (or `sudo cp -r sddm/cyberpunk-mr /usr/share/sddm/themes/`). |
| Lock logs | `$XDG_RUNTIME_DIR/lock.log`, `journalctl --user -u hypridle`, `journalctl -t sddm` |

---

## Keybinds cheatsheet

> **Left Alt and Left Ctrl are swapped.** Binds written as `CTRL` below are pressed
> with the physical **Left Alt** key.

| Keys | Action |
|---|---|
| `SUPER+RETURN` | Open kitty |
| `SUPER+Q` | Close window |
| `CTRL+Q` | Lock → SDDM login screen (↑↓ picks a user) |
| `SUPER+D` | App launcher (wofi) |
| `SUPER+B` | Power menu (shutdown, reboot, suspend, lock, logout) |
| `SUPER+E` | File manager (yazi in kitty) |
| `SUPER+V` | Clipboard history |
| `SUPER+.` | Emoji picker |
| `SUPER+N` | Notification center |
| `SUPER+F` | Fullscreen (toggle) |
| `SUPER+SPACE` | Float / tile window (toggle) |
| `SUPER+R` | Resize mode (arrows, `ESC` to exit; border turns red) |
| `SUPER+SHIFT+H` | Toggle gaps + rounding |
| `SUPER+P` / `SUPER+SHIFT+J` | Pseudo-tile / toggle split (dwindle) |
| `SUPER+U` | Swap with master |
| `SUPER+G` / `SUPER+SHIFT+G` / `SUPER+CTRL+G` | Group toggle / move out of group / move into group |
| `SUPER+TAB` | Last window / next in group |
| `SUPER+←↑→↓` or `SUPER+H/J/K/L` | Move focus |
| `SUPER+SHIFT+←↑→↓` | Move window |
| `SUPER+1..9,0` | Jump to workspace |
| `SUPER+SHIFT+1..9,0` | Move window to workspace |
| `SUPER+CTRL+1..9,0` | Move window to workspace silently |
| `SUPER+CTRL+←/→` or `SUPER+scroll` | Previous / next workspace |
| `SUPER+A` / `SUPER+-` | Move to / toggle special workspace |
| `SUPER+[` / `SUPER+]` | Volume down / up |
| `SUPER+O` | OCR screenshot region → clipboard |
| `SUPER+PRINT` | Freeze screen, select region → save to `~/Pictures/screenshots/` |
| `PRINT` | Freeze screen, select region → clipboard |
| `CTRL+PRINT` | Select region → annotate in swappy |
| `CTRL+SHIFT+4` | Quick region screenshot to `~/Pictures/Screenshots/` |
| `SUPER+SHIFT+W` | Shuffle wallpaper |
| `SUPER+SHIFT+R` | Reload Hyprland |
| `ALT+F10` | Pass to OBS (global hotkey) |
| `SUPER+drag` (left / right button) | Move / resize window |
