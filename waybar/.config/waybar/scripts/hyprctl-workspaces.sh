#!/bin/bash

# This script outputs the current Hyprland workspace names
# Highlight the active workspace with brackets []

current_ws=$(hyprctl workspaces -j | jq -r '.[] | select(.focused==true) | .name')
all_ws=$(hyprctl workspaces -j | jq -r '.[].name')

output=""

for ws in $all_ws; do
    if [[ "$ws" == "$current_ws" ]]; then
        output+="[$ws] "
    else
        output+="$ws "
    fi
done

echo "$output"

