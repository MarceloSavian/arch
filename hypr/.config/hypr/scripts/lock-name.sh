#!/bin/sh
# Name shown on hyprlock: the account's display name (GECOS), else the username.
# Same rule as the SDDM theme, so both screens show the same name.
name=$(getent passwd "$(id -un)" | cut -d: -f5 | cut -d, -f1)
printf '%s\n' "${name:-$(id -un)}"
