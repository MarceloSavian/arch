#!/bin/sh
# Detect the main/focused monitor for waybar
MAIN_DISPLAY=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name')
if [ -z "$MAIN_DISPLAY" ]; then
    MAIN_DISPLAY="eDP-1"
fi
export MAIN_DISPLAY
