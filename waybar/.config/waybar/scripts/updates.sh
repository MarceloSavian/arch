#!/usr/bin/env bash
# Print count of pending updates (official + AUR via yay), or 0 on failure.
if command -v checkupdates >/dev/null 2>&1; then
  pacman_count=$(checkupdates 2>/dev/null | wc -l)
else
  pacman_count=0
fi
if command -v yay >/dev/null 2>&1; then
  total=$(yay -Qu 2>/dev/null | wc -l)
  if [ "$total" -gt 0 ]; then
    echo "$total"
    exit 0
  fi
fi
echo "$pacman_count"
