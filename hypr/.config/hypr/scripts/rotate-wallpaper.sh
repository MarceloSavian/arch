#!/bin/bash

WALLPAPER_DIR="$HOME/wallpapers"
INTERVAL=600

sleep 2

PREV=""
while true; do
    mapfile -t FILES < <(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.gif" \) 2>/dev/null)

    if [ ${#FILES[@]} -eq 0 ]; then
        sleep "$INTERVAL"
        continue
    fi

    NEXT="${FILES[RANDOM % ${#FILES[@]}]}"
    if [ ${#FILES[@]} -gt 1 ]; then
        while [ "$NEXT" = "$PREV" ]; do
            NEXT="${FILES[RANDOM % ${#FILES[@]}]}"
        done
    fi

    awww img "$NEXT" --transition-type any --transition-duration 1 >/dev/null 2>&1

    PREV="$NEXT"
    sleep "$INTERVAL"
done
