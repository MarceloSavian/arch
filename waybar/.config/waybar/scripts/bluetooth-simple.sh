#!/bin/bash

# Check if Bluetooth interface exists
if [ ! -d "/sys/class/bluetooth/hci0" ]; then
    echo ""
    exit 0
fi

# Check if Bluetooth is powered on
bt_state=$(cat /sys/class/bluetooth/hci0/rfkill*/state 2>/dev/null)

if [ "$bt_state" != "1" ]; then
    echo "BT OFF"
    exit 0
fi

# Bluetooth is on - check for connected devices
connected_devices=$(timeout 2 bluetoothctl devices Connected 2>/dev/null | wc -l)

if [ "$connected_devices" -gt 0 ]; then
    echo "BT ($connected_devices)"
else
    echo "BT"
fi
