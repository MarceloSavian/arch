#!/bin/sh
# Run by hypridle when SDDM logs you back into this session (logind Unlock):
# go back to the workspace you were on when you locked.
F="${XDG_RUNTIME_DIR:-/tmp}/lock-workspace"
[ -s "$F" ] || exit 0
ws=$(cat "$F"); rm -f "$F"
sleep 0.3   # let Hyprland finish re-activating the session
hyprctl dispatch "hl.dsp.focus({ workspace = $ws })" >/dev/null
