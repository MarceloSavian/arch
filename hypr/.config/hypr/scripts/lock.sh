#!/bin/sh
# THE lock: switch to the SDDM login screen (the same one as at boot, with the
# user picker). Used by CTRL+Q, power menu -> Lock, and hypridle lock_cmd
# (so suspend / lid close land here too).
#
# There is no hyprlock underneath. That is only safe because VT switching
# (Ctrl+Alt+F1..) is disabled everywhere - in Hyprland (xkb srvrkeys:none) and in
# SDDM's X server (DontVTSwitch) - so the only way back into this session is
# logging in on SDDM (ReuseSession=true returns you to this session).
LOG="${XDG_RUNTIME_DIR:-/tmp}/lock.log"
exec >>"$LOG" 2>&1
echo "--- $(date '+%F %T') lock.sh (parent: $(ps -o comm= -p $PPID))"
# remember the focused workspace; scripts/unlock.sh restores it on return
hyprctl activeworkspace -j | jq -r .id > "${XDG_RUNTIME_DIR:-/tmp}/lock-workspace" 2>/dev/null
busctl --system call org.freedesktop.DisplayManager \
    /org/freedesktop/DisplayManager/Seat0 \
    org.freedesktop.DisplayManager.Seat SwitchToGreeter
echo "busctl exit=$?"
