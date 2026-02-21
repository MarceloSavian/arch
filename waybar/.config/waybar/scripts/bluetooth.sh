#!/bin/bash

# Check if Bluetooth is blocked via rfkill
if rfkill list bluetooth | grep -q "Soft blocked: yes"; then
    echo '{"text": "󰂲", "class": "bluetooth-off", "tooltip": "Bluetooth Blocked"}'
    exit 0
fi

# Check if Bluetooth controller exists and is powered
bt_state=$(cat /sys/class/bluetooth/hci0/rfkill*/state 2>/dev/null)
if [ -z "$bt_state" ] || [ "$bt_state" != "1" ]; then
    echo '{"text": "󰂲", "class": "bluetooth-off", "tooltip": "Bluetooth Off"}'
    exit 0
fi

# Bluetooth is on - check for connected devices
# Use timeout to prevent bluetoothctl from hanging
connected_devices=$(timeout 2 bluetoothctl devices Connected 2>/dev/null | wc -l)

if [ "$connected_devices" -gt 0 ]; then
    # Get device names for tooltip
    device_list=$(timeout 2 bluetoothctl devices Connected 2>/dev/null | cut -d' ' -f3- | tr '\n' ',' | sed 's/,$//')
    echo "{\"text\": \" $connected_devices\", \"class\": \"bluetooth-connected\", \"tooltip\": \"Connected: $device_list\"}"
else
    # Bluetooth on but no devices connected
    echo '{"text": "", "class": "bluetooth-on", "tooltip": "Bluetooth On - No devices"}'
fi
