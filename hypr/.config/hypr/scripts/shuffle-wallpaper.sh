#!/bin/bash

WALLPAPER_DIR="$HOME/wallpapers"

mapfile -t FILES < <(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \
    \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.gif" \) 2>/dev/null)

[ ${#FILES[@]} -eq 0 ] && exit 0

CURRENT=$(awww query 2>/dev/null | head -1 | sed -n 's/.*image: //p')

NEXT="${FILES[RANDOM % ${#FILES[@]}]}"
if [ ${#FILES[@]} -gt 1 ]; then
    while [ "$NEXT" = "$CURRENT" ]; do
        NEXT="${FILES[RANDOM % ${#FILES[@]}]}"
    done
fi

awww img "$NEXT" --transition-type any --transition-duration 1
