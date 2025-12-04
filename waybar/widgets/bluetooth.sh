#!/bin/bash
# ~/.config/waybar/scripts/bluetooth.sh
# Muestra estado de Bluetooth con iconos Adwaita para Waybar

# Estado general del adaptador
STATE=$(bluetoothctl show | awk '/Powered/{print $2}')

DEVICE=$(bluetoothctl devices Connected | awk '{for(i=2;i<=NF;i++) printf $i" "; print ""}' | sed 's/ $//')

if [[ -n STATE ]]; then
    exit 1
fi
# Mostrar en Waybar
if [[ "$STATE" == "yes" ]]; then
    if [[ -n "$DEVICE" ]]; then
        echo "󰂯 $DEVICE"
    else
        echo 󰂯
    fi
else
    echo 󰂲
fi
