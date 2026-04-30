#!/usr/bin/env bash
# Print FA Solid battery glyph based on capacity, or bolt while charging.
# f240 full, f241 3/4, f242 half, f243 1/4, f244 empty, f0e7 bolt
bat=/sys/class/power_supply/BAT1
[ -d "$bat" ] || bat=/sys/class/power_supply/BAT0
cap=$(cat "$bat/capacity" 2>/dev/null || echo 100)
status=$(cat "$bat/status" 2>/dev/null)

if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
  printf '\xef\x83\xa7'   # bolt
  exit 0
fi

if   [ "$cap" -ge 80 ]; then printf '\xef\x89\x80'   # full
elif [ "$cap" -ge 60 ]; then printf '\xef\x89\x81'   # 3/4
elif [ "$cap" -ge 40 ]; then printf '\xef\x89\x82'   # half
elif [ "$cap" -ge 20 ]; then printf '\xef\x89\x83'   # 1/4
else                          printf '\xef\x89\x84'  # empty
fi
