#!/bin/bash

# Glyphs are FontAwesome 7 (covered by InputMono Nerd Font).
SHUTDOWN=$''
REBOOT=$''
SUSPEND=$''
LOGOUT=$''

entries="$SHUTDOWN Shutdown
$REBOOT Reboot
$SUSPEND Suspend
$LOGOUT Logout"

selected=$(echo -e "$entries" | wofi \
    --dmenu \
    --width 240 --height 240 \
    --style ~/.config/wofi/style.css \
    --hide-scroll \
    --cache-file /dev/null \
    --prompt "Power" \
    "$@" | awk '{print tolower($2)}')

case $selected in
  shutdown) exec systemctl poweroff -i ;;
  reboot)   exec systemctl reboot ;;
  suspend)  exec systemctl suspend ;;
  logout)   exec hyprctl dispatch exit NOW ;;
esac
