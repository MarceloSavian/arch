#!/bin/sh
# Run by hypridle when SDDM logs you back into this session (logind Unlock).
#
# 1. Go back to the workspace you were on when you locked.
# 2. Repair XWayland's socket. The lock screen is a temporary SDDM X server; when it
#    shuts down (a few seconds after you're back) it deletes /tmp/.X11-unix/X<n>,
#    which belongs to this session's XWayland. Running X11 apps keep working, but
#    new ones (Steam, Chrome via XWayland...) fail with "Can't open display".
#    Hyprland also listens on /tmp/.X11-unix/X<n>_, so point X<n> back at it.
F="${XDG_RUNTIME_DIR:-/tmp}/lock-workspace"
if [ -s "$F" ]; then
    ws=$(cat "$F"); rm -f "$F"
    sleep 0.3   # let Hyprland finish re-activating the session
    hyprctl dispatch "hl.dsp.focus({ workspace = $ws })" >/dev/null
fi

n="${DISPLAY#:}"; n="${n%%.*}"
[ -n "$n" ] || exit 0
sock="/tmp/.X11-unix/X$n"
(
    for _ in $(seq 20); do
        if [ ! -e "$sock" ] && [ -S "${sock}_" ]; then
            ln -sf "${sock}_" "$sock" && echo "$(date '+%F %T') repaired $sock" >> "${XDG_RUNTIME_DIR:-/tmp}/lock.log"
        fi
        sleep 1
    done
) &
