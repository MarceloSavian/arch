#!/usr/bin/env bash
# Show a volume OSD on XF86Audio key presses. Replaces previous notifications
# so rapid key presses don't stack.

sink="@DEFAULT_SINK@"
vol=$(pactl get-sink-volume "$sink" 2>/dev/null | grep -oP '\d+%' | head -1)
muted=$(pactl get-sink-mute "$sink" 2>/dev/null | awk '{print $2}')
num=${vol%\%}
num=${num:-0}

if [ "$muted" = "yes" ]; then
  icon="audio-volume-muted"
  body="Muted"
else
  if   [ "$num" -eq 0  ]; then icon="audio-volume-muted"
  elif [ "$num" -lt 33 ]; then icon="audio-volume-low"
  elif [ "$num" -lt 66 ]; then icon="audio-volume-medium"
  else                         icon="audio-volume-high"
  fi
  body="$vol"
fi

notify-send \
  -t 1200 \
  -h string:x-canonical-private-synchronous:volume \
  -h "int:value:$num" \
  -i "$icon" \
  "Volume" "$body"
