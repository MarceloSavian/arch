# AGENTS.md — notes for AI agents working on this repo

Dotfiles for a Hyprland (Wayland) desktop on Arch Linux. `install.sh` builds the whole
setup; `README.md` explains what each piece is. This file is what you'd otherwise learn
the hard way. **Read it fully before running anything.**

---

## Rebuild from scratch (fresh Arch install)

Prerequisites: Arch installed with a user in `wheel` that can sudo, network up, `git`.
You (the agent) usually **can't type the sudo password** — write/point to scripts and
ask the user to run them in a real terminal (kitty). The `!` prefix in Claude Code
can't show a password prompt.

1. `git clone https://github.com/MarceloSavian/arch.git ~/arch`
2. Read `install.sh` end to end, then ask the user to run `~/arch/install.sh`.
3. Ask the user to **reboot** and log in from SDDM.
4. Manual steps only the user can do: `nordvpn login`; Chrome → Settings → System →
   turn off "Continue running background apps"; `gh auth login && gh auth setup-git`.
5. Other people on the machine: `~/arch/add-user.sh <name> "Display Name"` (user runs it).
6. Run the verification checklist below and fix anything that fails before saying done.

### Verification checklist (run these, don't assume)

| Check | Command | Expected |
|---|---|---|
| Hyprland config | `hyprctl configerrors; hyprctl deprecated-config` | empty / "all good!" |
| Links in place | `readlink ~/.config/hypr/hyprland.lua ~/.bashrc` | point into `~/arch/` |
| Autostart | `pgrep -x waybar; pgrep -f awww-daemon; pgrep swaync` | all running |
| Waybar warnings | start waybar with stderr to a file | no warnings |
| Audio | `wpctl status` | sinks listed; default = analog |
| Default GPU | `glxinfo -B \| grep renderer` | AMD Radeon |
| Offload GPU | `prime-run glxinfo -B \| grep renderer` | NVIDIA GeForce |
| XWayland | `xrandr --listmonitors` | 2 monitors |
| hypridle | `systemctl --user is-active hypridle` | active |
| VT switching off | `hyprctl getoption input.kb_options` | contains `srvrkeys:none` |
| Greeter Xorg file | `ls /etc/X11/xorg.conf.d/` | `10-sddm-greeter.conf` |
| Bluetooth | `systemctl is-active bluetooth` | active |
| Browser | `xdg-settings get default-web-browser` | `google-chrome.desktop` |
| SDDM theme | `diff -r ~/arch/sddm/cyberpunk-mr /usr/share/sddm/themes/cyberpunk-mr` | no output |

The lock flow (CTRL+Q → SDDM → log back in) can only be tested by the user — ask them.

---

## The machine

- Acer Nitro laptop, hybrid graphics:
  - **AMD Vega 10 iGPU** (`05:00.0`, `amdgpu`) drives **both** displays.
  - **NVIDIA GTX 1650 Mobile** (`01:00.0`) is **render-offload only** — no outputs.
- Displays: `eDP-1` 1920x1080@60 (laptop, left) and `HDMI-A-1` 2560x1440@144 (LG, right).
  Workspaces 1-5 are pinned to HDMI-A-1, 6-10 to eDP-1.
- The NVIDIA card **cannot fully power off**: the driver reports
  "Runtime D3: Not supported" (firmware limit). Don't try to fix this (an
  `NVreg_DynamicPowerManagement` modprobe option + udev rules were tried; useless here).
- Audio: ALC255 analog (speakers/jack, default) + HDMI audio on the LG monitor.
- No Corsair hardware (ckb-next was removed on purpose).
- Users: the main user (SDDM `DefaultUser` in `sddm/cyberpunk-mr/theme.conf`) plus
  additional accounts created with `add-user.sh`. Home dirs are `700` — one user
  can't read another's repo copy.

## User preferences (decided — don't re-litigate)

- Left Alt ⇄ Left Ctrl swapped (Mac-style ⌘C/⌘V).
- Exactly **one lock screen**: the SDDM login screen. No hyprlock.
- Chrome is the default browser; Thunar opens folders.
- No eww / workspace overview, no idle auto-lock (hypridle only handles lock/unlock/sleep).
- Keep the session running when locking (not log out).

## How the repo works

- GNU Stow packages mirroring `$HOME`: `hypr waybar wofi kitty yazi shell` (normal),
  `gtk nvidia` (**`--no-folding`** — they target dirs apps also write into, e.g.
  `~/.local/share/applications`; folding would make apps write into the repo).
- `system/` holds files `install.sh` copies into `/etc`. `sddm/` is installed by copy.
- `install.sh` is idempotent and the **source of truth for packages**. When you add a
  dependency, add it there (and to the README table). It removes broken links into the
  repo on every run, so deleting a file from the repo is safe.
- `install.sh --user`: per-user part only (no sudo). `add-user.sh` runs it via
  `sudo -u <user>`, where there is no `XDG_RUNTIME_DIR` and no user systemd — which is why
  hypridle is enabled with `systemctl --global` and the Hyprland check makes a temp
  runtime dir. Don't add `systemctl --user` steps that must succeed there.
- Each user has their **own clone** in `~/arch`; update other users with
  `sudo -u <user> -H git -C /home/<user>/arch pull`.
- Commit style: conventional commits (`feat(hypr): ...`, `fix: ...`, `docs: ...`),
  author `marcelosavian`. Don't push without the user's OK. Before pushing, scan the
  diff for secrets and personal data (other people's names/usernames included).

## Hyprland (0.57+, Lua config)

- Config is `hypr/.config/hypr/hyprland.lua`, which `require`s `modules/*.lua`
  (env, monitors, autostart, look, input, rules, binds, theme).
- Validate every edit: `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`,
  then `hyprctl reload`, `hyprctl configerrors`, `hyprctl deprecated-config`.
  (`--verify-config` needs `XDG_RUNTIME_DIR`; under `sudo -u` set a temp one.)
- **`hyprctl keyword` no longer exists.** Runtime changes: `hyprctl eval '<lua>'`.
  Dispatch: `hyprctl dispatch 'hl.dsp.exit()'` (Lua dispatcher syntax).
- Docs: the wiki source (github.com/hyprwm/hyprland-wiki, `content/configuring/`)
  is far easier to read than the rendered site (which is mostly navigation).
- If Hyprland crashes, `start-hyprland` restarts it in **safe mode** (config not
  loaded). Recovery: `hyprctl dispatch 'hl.dsp.exit()'` and log in again. Crash
  reports: `~/.cache/hyprland/hyprlandCrashReport*.txt`.
- Keyboard: `kb_options = "ctrl:swap_lalt_lctl,srvrkeys:none"` — Left Alt acts as Ctrl
  (so `CTRL+Q` is pressed with Left Alt+Q) and Ctrl+Alt+F-keys VT switching is off
  (required by the lock design — see below).
- `hyprctl binds` modmask: 64=SUPER, 1=SHIFT, 4=CTRL, 8=ALT (sum for combos).

## GPU rules — read before touching anything graphics-related

- Apps render on AMD by default. **Never** set PRIME/NVIDIA env vars globally
  (`__NV_PRIME_RENDER_OFFLOAD`, `__GLX_VENDOR_LIBRARY_NAME`, `GBM_BACKEND=nvidia-drm`,
  `LIBVA_DRIVER_NAME=nvidia`) — it keeps the dGPU busy and broke VA-API.
- Hyprland itself must stay on AMD (the displays are wired to it).
- Per-app NVIDIA: `prime-run <app>`. Steam: launch Steam itself with `prime-run`
  (the "Steam (NVIDIA)" entry); every game inherits it.
- **Chrome on NVIDIA only works via XWayland**: `prime-run google-chrome-stable --ozone-platform=x11`.
  - Native Wayland + prime-run → silently stays on AMD.
  - `--use-angle=vulkan` on Wayland → GPU process loses context in a loop.
  - **`--render-node-override=/dev/dri/renderD129` CRASHES HYPRLAND** (it can't
    import NVIDIA-allocated dmabufs on the AMD renderer). Never use it.
- `nvidia-smi` does **not** list Chrome's sandboxed GPU process. Verify with
  `chrome://gpu` (GL_RENDERER) or by checking `/proc/<gpu-pid>/fd` for `/dev/nvidia0`.
- SDDM's greeter Xorg stays running after login; `AutoAddGPU off` in
  `system/xorg.conf.d/10-sddm-greeter.conf` stops it from holding the NVIDIA GPU.

## Lock screen = the SDDM login screen (one lock for everything, no hyprlock)

- Every lock ends on the SDDM login screen (same as boot, with the user picker):
  CTRL+Q, power menu → Lock, and suspend/lid (hypridle `before_sleep_cmd` →
  `loginctl lock-session` → `lock_cmd`). All of them run `scripts/lock.sh`, which saves
  the focused workspace and calls SDDM `Seat0.SwitchToGreeter` (any user may call it).
  **Don't reintroduce hyprlock** — it showed as a second lock screen and its slow
  unlock left the user on the wrong workspace. hyprlock can't list other users anyway.
- The session keeps running **unlocked** on VT1 behind the login screen. That is only
  safe because VT switching is disabled everywhere:
  - Hyprland: xkb `srvrkeys:none` in `modules/input.lua`
  - SDDM's Xorg: `DontVTSwitch` in `system/xorg.conf.d/10-sddm-greeter.conf`
  **Never remove either.**
- Logging back in as the same user: SDDM `ReuseSession=true` (default) sends logind
  `UnlockSession` + `ActivateSession`; hypridle `unlock_cmd` runs `scripts/unlock.sh`,
  which refocuses the saved workspace and repairs the XWayland socket (next point).
- **The lock deletes the XWayland socket.** The lock screen is a temporary SDDM X
  server; when it exits (~5s after you log back in) `/tmp/.X11-unix/X<n>` of the
  session's XWayland disappears. Running X11 apps survive, new ones (Steam!) fail with
  "Can't open display" / "Check your DISPLAY". Hyprland also listens on `X<n>_`, so
  `unlock.sh` re-links `X<n> -> X<n>_` for 20s after unlock. Manual fix:
  `ln -s /tmp/.X11-unix/X1_ /tmp/.X11-unix/X1`.
- Logs: `$XDG_RUNTIME_DIR/lock.log`, `journalctl --user -u hypridle`, `journalctl -t sddm`.

## SDDM theme (`sddm/cyberpunk-mr/`, Qt5, SddmComponents 2.0)

- The login card has a **user switcher** (‹ › or ↑↓ in the password box) over SDDM's
  `userModel` (via a `Repeater`, so `itemAt()` works). `DefaultUser` must be a real
  username — it gets the configured avatar photo; other users get their face icon.
- Background blur uses `QtGraphicalEffects` `FastBlur` (`qt5-graphicaleffects`).
- Test without logging out: `QT_QPA_PLATFORM=offscreen sddm-greeter --test-mode --theme <dir>`
  — `console.log` output goes to the **journal** (`journalctl -t sddm-greeter`), not stdout.
  Add temporary `console.log`s in a scratch copy to check logic. A visible test window
  gets tiled by Hyprland and can't be screenshotted reliably — don't fight it.
- Installing a changed theme needs root: `install.sh`, or `sudo cp -r` + `chmod -R a+rX`.

## Process / environment gotchas

- **Never `pkill chrome` / `pkill -x chrome`** — it kills the user's own browser.
  Target test instances by a dedicated `--user-data-dir` and kill by PID.
- `pgrep -f`/`pkill -f` patterns also match your own shell's command line; filter
  by the real executable.
- Chrome "Continue running background apps" must be OFF (Local State
  `background_mode.enabled=false`), otherwise closing the window leaves Chrome
  running and the NVIDIA launcher refuses to start.
- kitty: keep `remember_window_size no`. kitty records its tiled window as
  `"window-state": "maximized"` in `~/.cache/kitty/main.json` and would reopen every new
  terminal maximized, covering the others.
- Apps started before PipeWire was running (Chrome, waybar) need a restart to get audio.
- `~/.local/bin` is added to PATH in **`.bash_profile`**, because `.bashrc` returns
  early for non-interactive shells and the login session never ran it.
  Desktop entries should still not rely on `~/.local/bin` being on PATH.
- Steam's first launch downloads ~500 MB with no visible window — check
  `~/.local/share/Steam/logs/bootstrap_log.txt` before assuming it's broken.
- Don't use foreground `sleep N` to wait in Claude Code; poll with
  `timeout N bash -c 'until <check>; do sleep 2; done'`.

## Package names that changed (don't trust old guides)

| Old name | Current |
|---|---|
| `ttf-font-awesome` | `otf-font-awesome` |
| `ttf-monocraft` (AUR) | `otf-monocraft` (AUR) |
| `awww`, `swaync`, `ttf-input-nerd`, `ckb-next` (AUR) | official repos |
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

## Known open items

- hypridle has no idle timeouts (no auto-lock on inactivity) — by choice so far; ask
  before adding one.
