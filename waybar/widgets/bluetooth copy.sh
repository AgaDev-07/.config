#!/bin/bash

STATE=$(bluetoothctl show | awk '/Powered/ {print $2}')

# Si no hay adaptador → mostrar nada
if [[ -z "$STATE" ]]; then
    echo ""
    exit 0
fi

# Si Bluetooth está apagado
if [[ "$STATE" == "no" ]]; then
    echo {\"text\":\"󰂲\",\"tooltip\":\"Bluetooth Apagado\" }
    exit 0
fi

# Obtener MAC del dispositivo conectado
MAC=$(bluetoothctl info | awk -F' ' '/Device/ {print $2; exit}')

# Nombre del dispositivo
NAME=$(bluetoothctl info "$MAC" | awk -F': ' '/Name/ {print $2; exit}')

MAC_FORMAT=$(echo "$MAC" | tr ':' '_')
CAPACITY=$(bluetoothctl info "$MAC" | awk -F'[()]' '/Battery Percentage/ {print $2}')

BATTERY=$(if [[ -n "$CAPACITY" ]]; then
    if [[ "$CAPACITY" =~ ^[0-9]+$ ]]; then
        if [ "$CAPACITY" -ge 100 ]; then echo "󰥈"
        elif [ "$CAPACITY" -ge 90 ]; then echo "󰥆"
        elif [ "$CAPACITY" -ge 80 ]; then echo "󰥅"
        elif [ "$CAPACITY" -ge 70 ]; then echo "󰥄"
        elif [ "$CAPACITY" -ge 60 ]; then echo "󰥃"
        elif [ "$CAPACITY" -ge 50 ]; then echo "󰥂"
        elif [ "$CAPACITY" -ge 40 ]; then echo "󰥁"
        elif [ "$CAPACITY" -ge 30 ]; then echo "󰥀"
        elif [ "$CAPACITY" -ge 20 ]; then echo "󰤿"
        elif [ "$CAPACITY" -ge 10 ]; then echo "󰤾"
        else echo "󰥇"
        fi
    fi
fi)


echo "{\"text\":\"$TEXT\",\"tooltip\":\"${TOOLTIP%\\n\\n}\"}"

