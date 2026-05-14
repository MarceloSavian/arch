#!/usr/bin/env bash
# Waybar click handler: wofi menu for NordVPN.

WOFI=(wofi --dmenu --insensitive --style "$HOME/.config/wofi/style.css" --width=22% --height=50% --prompt)

notify() { notify-send -a NordVPN "$1" "${2:-}"; }

refresh() { pkill -RTMIN+8 waybar 2>/dev/null || true; }

connect() {
  notify "NordVPN" "Connecting to ${1:-fastest server}..."
  out=$(nordvpn connect "$@" 2>&1)
  if echo "$out" | grep -qi "you are connected"; then
    notify "NordVPN" "$(echo "$out" | tail -n 1)"
  else
    notify "NordVPN failed" "$out"
  fi
  refresh
}

state=$(nordvpn status 2>/dev/null | awk -F': *' '/^Status:/ {print $2; exit}')

if [[ "$state" == "Connected" ]]; then
  primary="  Disconnect"
else
  primary="  Quick connect"
fi

choice=$(printf '%s\n' \
  "$primary" \
  "  Connect by country…" \
  "  Connect by city…" \
  "  Status" \
  "  Settings…" \
  | "${WOFI[@]}" "NordVPN")

case "$choice" in
  *"Disconnect")
    nordvpn disconnect >/dev/null 2>&1
    notify "NordVPN" "Disconnected"
    refresh
    ;;
  *"Quick connect")
    connect
    ;;
  *"Connect by country"*)
    country=$(nordvpn countries 2>/dev/null \
      | tr -s ' \t,' '\n' | sed '/^$/d' | sort -u \
      | "${WOFI[@]}" "Country")
    [[ -n "$country" ]] && connect "$country"
    ;;
  *"Connect by city"*)
    country=$(nordvpn countries 2>/dev/null \
      | tr -s ' \t,' '\n' | sed '/^$/d' | sort -u \
      | "${WOFI[@]}" "Country")
    [[ -z "$country" ]] && exit 0
    city=$(nordvpn cities "$country" 2>/dev/null \
      | tr -s ' \t,' '\n' | sed '/^$/d' | sort -u \
      | "${WOFI[@]}" "City in $country")
    [[ -n "$city" ]] && connect "$country" "$city"
    ;;
  *"Status")
    notify "NordVPN status" "$(nordvpn status 2>&1)"
    ;;
  *"Settings"*)
    sub=$(printf '%s\n' \
      "  Toggle killswitch" \
      "  Toggle autoconnect" \
      "  Toggle CyberSec" \
      "  Logout" \
      | "${WOFI[@]}" "Settings")
    case "$sub" in
      *"killswitch")
        cur=$(nordvpn settings 2>/dev/null | awk -F': *' '/Kill Switch/ {print $2; exit}')
        [[ "$cur" == "enabled" ]] && nordvpn set killswitch off || nordvpn set killswitch on
        notify "NordVPN" "Killswitch toggled"
        ;;
      *"autoconnect")
        cur=$(nordvpn settings 2>/dev/null | awk -F': *' '/Auto-connect/ {print $2; exit}')
        [[ "$cur" == "enabled" ]] && nordvpn set autoconnect off || nordvpn set autoconnect on
        notify "NordVPN" "Autoconnect toggled"
        ;;
      *"CyberSec")
        cur=$(nordvpn settings 2>/dev/null | awk -F': *' '/Threat Protection|CyberSec/ {print $2; exit}')
        [[ "$cur" == "enabled" ]] && nordvpn set threatprotectionlite off || nordvpn set threatprotectionlite on
        notify "NordVPN" "Threat Protection toggled"
        ;;
      *"Logout")
        nordvpn logout >/dev/null 2>&1
        notify "NordVPN" "Logged out"
        ;;
    esac
    refresh
    ;;
esac
