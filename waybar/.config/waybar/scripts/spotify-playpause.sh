#!/usr/bin/env bash
# Material Icons codepoints: U+E034 pause, U+E037 play_arrow.
status=$(playerctl --player=spotify status 2>/dev/null)
if [ "$status" = "Playing" ]; then
  printf '\xee\x80\xb4'
else
  printf '\xee\x80\xb7'
fi
