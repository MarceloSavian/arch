#!/usr/bin/env bash
# Event-driven: prints the title (max 20 chars) on every change, empty line hides the module.
playerctl --player=spotify --follow metadata --format '{{status}}|{{title}}' 2>/dev/null |
while IFS='|' read -r status song; do
  if [ -z "$status" ] || [ "$status" = "Stopped" ] || [ -z "$song" ]; then echo; continue; fi
  [ "${#song}" -gt 20 ] && song="${song:0:20}..."
  printf '%s\n' "$song"
done
