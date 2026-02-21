#!/bin/sh

# Kill any previous switch still running
pkill -f "switch-theme.sh" 2>/dev/null

# Toggle between summer-day and summer-night themes
CURRENT_THEME_FILE="$HOME/.config/hypr/.current-theme"

if [ -f "$CURRENT_THEME_FILE" ] && [ "$(cat "$CURRENT_THEME_FILE")" = "summer-day" ]; then
    NEXT_THEME="summer-night"
else
    NEXT_THEME="summer-day"
fi

echo "$NEXT_THEME" > "$CURRENT_THEME_FILE"

# Source the new theme config in Hyprland
hyprctl keyword source "~/.config/hypr/themes/$NEXT_THEME/$NEXT_THEME.conf"

# Run the theme switch script
sh ~/.config/hypr/scripts/switch-theme.sh "$NEXT_THEME"
