#!/usr/bin/env bash
# Print FA Solid volume glyph based on pactl state.
# f028 high, f027 low, f026 off, f6a9 mute, f025 headphones
mute=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')
vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oE '[0-9]+%' | head -1 | tr -d '%')
[ -z "$vol" ] && vol=0

# detect headphones via active port description
port=$(pactl list sinks 2>/dev/null | awk '/Active Port/{print tolower($0)}' | head -1)
case "$port" in *headphone*|*headset*) printf '\xef\x80\xa5'; exit 0 ;; esac

if [ "$mute" = "yes" ]; then
  printf '\xef\x9a\xa9'        # mute
elif [ "$vol" -ge 50 ]; then
  printf '\xef\x80\xa8'        # high
elif [ "$vol" -ge 1 ]; then
  printf '\xef\x80\xa7'        # low
else
  printf '\xef\x80\xa6'        # off
fi
