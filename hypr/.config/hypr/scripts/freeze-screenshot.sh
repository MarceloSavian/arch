#!/bin/sh
# Freeze the screen, select an area, then:
#   $1 = 0  save to ~/Pictures/screenshots/
#   $1 = 1  copy to clipboard
# Needs: hyprpicker (freeze), grim, slurp, wl-clipboard

hyprpicker -r -z & picker_proc=$!
sleep 0.2  # let the freeze overlay map before slurp starts

geom=$(slurp)
if [ -n "$geom" ]; then
    if [ "$1" -eq 0 ]; then
        dir="$HOME/Pictures/screenshots"
        mkdir -p "$dir"
        grim -g "$geom" "$dir/$(date +'%s_grim.png')"
    elif [ "$1" -eq 1 ]; then
        grim -g "$geom" - | wl-copy -t image/png
    fi
fi

hyprctl dispatch 'hl.dsp.cursor.move({ x = 0, y = 0 })'

kill $picker_proc 2>/dev/null
