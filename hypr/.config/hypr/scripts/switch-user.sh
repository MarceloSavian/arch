#!/bin/sh
# Switch user: keep this session running (locked) and open the SDDM login
# screen on another VT so someone else can log in.
# Coming back: pick your user on SDDM - ReuseSession=true returns you to this
# session (still locked) instead of starting a new one.
pgrep -u "$(id -u)" -x hyprlock >/dev/null || { hyprlock >/dev/null 2>&1 & sleep 1; }
exec busctl --system call org.freedesktop.DisplayManager \
    /org/freedesktop/DisplayManager/Seat0 \
    org.freedesktop.DisplayManager.Seat SwitchToGreeter
