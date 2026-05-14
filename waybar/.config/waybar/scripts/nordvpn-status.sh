#!/usr/bin/env bash
# Waybar custom module: NordVPN status as JSON.

status_out=$(nordvpn status 2>/dev/null)
state=$(echo "$status_out" | awk -F': *' '/^Status:/ {print $2; exit}')

icon_on=$'\xef\x80\xa3'   # fa-lock (U+F023)
icon_off=$'\xef\x84\x9b'  # fa-unlock-alt (U+F13E)

if [[ "$state" == "Connected" ]]; then
  country=$(echo "$status_out" | awk -F': *' '/^Country:/ {print $2; exit}')
  city=$(echo "$status_out"    | awk -F': *' '/^City:/    {print $2; exit}')
  server=$(echo "$status_out"  | awk -F': *' '/^Hostname:/{print $2; exit}')
  ip=$(echo "$status_out"      | awk -F': *' '/^IP:/      {print $2; exit}')
  tech=$(echo "$status_out"    | awk -F': *' '/^Current technology:/ {print $2; exit}')

  text="$icon_on $country"
  tooltip="Connected\nServer: ${server:-?}\nCity: ${city:-?}\nIP: ${ip:-?}\nTech: ${tech:-?}"
  class="connected"
elif [[ -z "$state" ]]; then
  text="$icon_off"
  tooltip="NordVPN: daemon not reachable"
  class="error"
else
  text="$icon_off"
  tooltip="NordVPN: $state"
  class="disconnected"
fi

printf '{"text":"%s","tooltip":"%s","class":"%s","alt":"%s"}\n' \
  "$text" "$tooltip" "$class" "$class"
