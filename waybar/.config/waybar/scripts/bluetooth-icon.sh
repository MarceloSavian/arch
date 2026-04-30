#!/usr/bin/env bash
# MDI codepoints (in InputMono Nerd Font):
#   bluetooth     U+F00AF
#   bluetooth-off U+F00B0  (icon with slash)
ICON_ON=$'\xf3\xb0\x82\xaf'
ICON_OFF=$'\xf3\xb0\x82\xb0'

if [ ! -d /sys/class/bluetooth/hci0 ]; then
  printf '%s' "$ICON_OFF"
  exit 0
fi

state=$(cat /sys/class/bluetooth/hci0/rfkill*/state 2>/dev/null)
if [ "$state" != "1" ]; then
  printf '%s' "$ICON_OFF"
  exit 0
fi

count=$(timeout 2 bluetoothctl devices Connected 2>/dev/null | wc -l | tr -d ' ')
if [ "$count" -gt 0 ]; then
  printf '%s %s' "$ICON_ON" "$count"
else
  printf '%s' "$ICON_ON"
fi
