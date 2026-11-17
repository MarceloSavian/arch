# AGENTS.md — notes for AI agents working on this repo

Dotfiles for a Hyprland (Wayland) desktop on Arch Linux. `install.sh` builds the
whole setup; `README.md` explains what each piece is. This file is the stuff
you'd otherwise learn the hard way. Read it before running anything.

## The machine

- Acer Nitro laptop, hybrid graphics:
  - **AMD Vega 10 iGPU** (`05:00.0`, `amdgpu`) drives **both** displays.
  - **NVIDIA GTX 1650 Mobile** (`01:00.0`) is **render-offload only** — no outputs.
- Displays: `eDP-1` 1920x1080@60 (laptop, left) and `HDMI-A-1` 2560x1440@144 (LG, right).
  Workspaces 1-5 are pinned to HDMI-A-1, 6-10 to eDP-1.
- The NVIDIA card **cannot fully power off**: the driver reports
  "Runtime D3: Not supported" (firmware limit). Don't try to fix this.
- Audio: ALC255 analog (speakers/jack, default) + HDMI audio on the LG monitor.
- No Corsair hardware (ckb-next was removed on purpose).

## How the repo works

- GNU Stow packages mirroring `$HOME`: `hypr waybar wofi kitty yazi shell` (normal),
  `gtk nvidia` (**`--no-folding`** — they target dirs apps also write into, e.g.
  `~/.local/share/applications`; folding would make apps write into the repo).
- `system/` holds files `install.sh` copies into `/etc`. `sddm/` is installed by copy.
- `install.sh` is idempotent and the **source of truth for packages**. When you add a
  dependency, add it there (and to the README table).
- Commit style: conventional commits (`feat(hypr): ...`, `fix: ...`, `docs: ...`),
  author `marcelosavian`. Don't push without the user's OK.

## Hyprland (0.57+, Lua config)

- Config is `hypr/.config/hypr/hyprland.lua`, which `require`s `modules/*.lua`
  (env, monitors, autostart, look, input, rules, binds, theme).
- Validate every edit: `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`,
  then `hyprctl reload`, `hyprctl configerrors`, `hyprctl deprecated-config`.
- **`hyprctl keyword` no longer exists.** Runtime changes: `hyprctl eval '<lua>'`.
  Dispatch: `hyprctl dispatch 'hl.dsp.exit()'` (Lua dispatcher syntax).
- Docs: the wiki source (github.com/hyprwm/hyprland-wiki, `content/configuring/`)
  is far easier to read than the rendered site.
- If Hyprland crashes, `start-hyprland` restarts it in **safe mode** (config not
  loaded). Recovery: `hyprctl dispatch 'hl.dsp.exit()'` and log in again.
- Keyboard: `kb_options = "ctrl:swap_lalt_lctl"` — physical Left Alt is Ctrl
  (Mac-style copy/paste). So `CTRL+Q` (lock) is pressed with Left Alt+Q.

## GPU rules — read before touching anything graphics-related

- Apps render on AMD by default. **Never** set PRIME/NVIDIA env vars globally
  (`__NV_PRIME_RENDER_OFFLOAD`, `__GLX_VENDOR_LIBRARY_NAME`, `GBM_BACKEND=nvidia-drm`,
  `LIBVA_DRIVER_NAME=nvidia`) — it keeps the dGPU busy and broke VA-API.
- Per-app NVIDIA: `prime-run <app>`. Steam: launch Steam itself with `prime-run`
  (the "Steam (NVIDIA)" entry); every game inherits it.
- **Chrome on NVIDIA only works via XWayland**: `prime-run google-chrome-stable --ozone-platform=x11`.
  - Native Wayland + prime-run → silently stays on AMD.
  - `--use-angle=vulkan` on Wayland → GPU process loses context in a loop.
  - **`--render-node-override=/dev/dri/renderD129` CRASHES HYPRLAND** (it can't
    import NVIDIA-allocated dmabufs on the AMD renderer). Never use it.
- `nvidia-smi` does **not** list Chrome's sandboxed GPU process. Verify with
  `chrome://gpu` (GL_RENDERER) or by checking `/proc/<gpu-pid>/fd` for `/dev/nvidia0`.
- SDDM's greeter Xorg stays running after login; `system/xorg.conf.d/10-no-gpu-hotplug.conf`
  stops it from holding the NVIDIA GPU.

## Process / environment gotchas

- **Never `pkill chrome` / `pkill -x chrome`** — it kills the user's own browser.
  Target test instances by a dedicated `--user-data-dir` and kill by PID.
- `pgrep -f`/`pkill -f` patterns also match your own shell's command line; filter
  by the real executable.
- Chrome "Continue running background apps" must be OFF (Local State
  `background_mode.enabled=false`), otherwise closing the window leaves Chrome
  running and the NVIDIA launcher refuses to start.
- Apps started before PipeWire was running (Chrome, waybar) need a restart to get audio.
- `~/.local/bin` is added to PATH in **`.bash_profile`**, because `.bashrc` returns
  early for non-interactive shells and the login session never ran it.
  Desktop entries should still not rely on `~/.local/bin` being on PATH.
- sudo needs a password; agents can't type it. Put privileged steps in a script and
  ask the user to run it in kitty (the `!` prefix in Claude Code can't prompt).

## Package names that changed (don't trust old guides)

| Old name | Current |
|---|---|
| `ttf-font-awesome` | `otf-font-awesome` |
| `ttf-monocraft` (AUR) | `otf-monocraft` (AUR) |
| `awww`, `swaync`, `ttf-input-nerd` (AUR) | official repos |
| `grimblast` | AUR only — scripts use `grim` + `slurp` instead |

Steam needs **multilib** enabled; name `lib32-vulkan-radeon` / `lib32-nvidia-utils`
explicitly or pacman prompts for a provider.

## Waybar

- Prefer native modules (pulseaudio, battery, bluetooth) and event-driven scripts
  (`playerctl --follow`) over `interval` polling — the old 1s scripts spawned ~10
  processes/second.
- Icon "halves" are second instances of the native module (`battery#icon`,
  `pulseaudio#icon`); CSS targets them as `#battery.icon` / `#pulseaudio.icon`.
- Check after edits: run waybar with stderr to a file and look for warnings.

## Lock screen = the SDDM login screen (one lock for everything, no hyprlock)

- Every lock ends on the SDDM login screen (same as boot, with the user picker):
  CTRL+Q, power menu → Lock, and suspend/lid (hypridle `before_sleep_cmd` →
  `loginctl lock-session` → `lock_cmd`). All of them run `scripts/lock.sh`, which calls
  SDDM `Seat0.SwitchToGreeter`. The user explicitly wants exactly ONE lock screen —
  **don't reintroduce hyprlock** (it was removed; it showed up as a second lock screen
  and its unlock delay left the user on the wrong workspace).
- The session keeps running **unlocked** on VT1 behind the login screen. That is only
  safe because VT switching is disabled everywhere:
  - Hyprland: xkb `srvrkeys:none` in `modules/input.lua` (no Ctrl+Alt+F-keys keysyms)
  - SDDM's Xorg: `DontVTSwitch` in `system/xorg.conf.d/10-sddm-greeter.conf`
  Never remove either. Recovery if stuck: SSH in, or log in on the SDDM screen.
- Logging back in as the same user: SDDM `ReuseSession=true` (default) sends logind
  `UnlockSession` + `ActivateSession`; hypridle `unlock_cmd` runs `scripts/unlock.sh`,
  which refocuses the workspace saved by `lock.sh`.
- Logs: `$XDG_RUNTIME_DIR/lock.log`, `journalctl --user -u hypridle`, `journalctl -t sddm`.

## Known open items

- `SUPER+W` runs `eww open overview` but no eww config exists yet.
- hypridle has no idle timeouts (no auto-lock on inactivity) — only lock/unlock/sleep handling.
