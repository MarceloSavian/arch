#!/usr/bin/env bash
status=$(playerctl --player=spotify status 2>/dev/null)
if [ -z "$status" ] || [ "$status" = "Stopped" ]; then
  exit 0
fi
song=$(playerctl --player=spotify metadata title 2>/dev/null)
[ -z "$song" ] && exit 0
if [ "${#song}" -gt 20 ]; then
  song="${song:0:20}..."
fi
printf '%s\n' "$song"
