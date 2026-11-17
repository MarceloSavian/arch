#!/bin/bash

# Glyphs are FontAwesome 7 (covered by InputMono Nerd Font).
SHUTDOWN=$''
REBOOT=$''
SUSPEND=$''
LOGOUT=$''
SWITCH=$''

entries="$SHUTDOWN Shutdown
$REBOOT Reboot
$SUSPEND Suspend
$SWITCH Switch user
$LOGOUT Logout"

selected=$(echo -e "$entries" | wofi \
    --dmenu \
    --width 240 --height 290 \
    --style ~/.config/wofi/style.css \
    --hide-scroll \
    --cache-file /dev/null \
    --prompt "Power" \
    "$@" | awk '{print tolower($2)}')

case $selected in
  shutdown) exec systemctl poweroff -i ;;
  reboot)   exec systemctl reboot ;;
  suspend)  exec systemctl suspend ;;
  switch)   exec ~/.config/hypr/scripts/switch-user.sh ;;
  logout)   command -v hyprshutdown >/dev/null && exec hyprshutdown || exec hyprctl dispatch 'hl.dsp.exit()' ;;
esac
