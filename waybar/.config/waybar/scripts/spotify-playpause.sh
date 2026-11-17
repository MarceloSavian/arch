#!/usr/bin/env bash
# Event-driven: playerctl --follow prints a line on every status change.
# Material Icons codepoints: U+E034 pause, U+E037 play_arrow.
printf '\xee\x80\xb7\n'
playerctl --player=spotify --follow status 2>/dev/null | while read -r status; do
  if [ "$status" = "Playing" ]; then printf '\xee\x80\xb4\n'; else printf '\xee\x80\xb7\n'; fi
done
