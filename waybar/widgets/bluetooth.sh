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
# Buscar batería usando upower
UP_PATH=$(upower -e | grep -i "$MAC_FORMAT")

if [[ -n "$UP_PATH" ]]; then
    CAPACITY=$(upower -i "$UP_PATH" | awk '/percentage/ {print $2}')
    CAPACITY=${CAPACITY%\%}
fi

if [[ -n "$BATTERY" ]]; then
    CAPACITY=$(echo "$BATTERY" | tr -d '%')

    if [[ "$CAPACITY" =~ ^[0-9]+$ ]]; then
        if [ "$CAPACITY" -ge 100 ]; then ICON="󰥈"
        elif [ "$CAPACITY" -ge 90 ]; then ICON="󰥆"
        elif [ "$CAPACITY" -ge 80 ]; then ICON="󰥅"
        elif [ "$CAPACITY" -ge 70 ]; then ICON="󰥄"
        elif [ "$CAPACITY" -ge 60 ]; then ICON="󰥃"
        elif [ "$CAPACITY" -ge 50 ]; then ICON="󰥂"
        elif [ "$CAPACITY" -ge 40 ]; then ICON="󰥁"
        elif [ "$CAPACITY" -ge 30 ]; then ICON="󰥀"
        elif [ "$CAPACITY" -ge 20 ]; then ICON="󰤿"
        elif [ "$CAPACITY" -ge 10 ]; then ICON="󰤾"
        else ICON="󰥇"
        fi
    fi
fi
if [[ "$CAPACITY" =~ ^[0-9]+$ ]]; then
    if [ "$CAPACITY" -ge 100 ]; then
        ICON="󰥈"
    elif [ "$CAPACITY" -ge 90 ]; then
        ICON="󰥆"
    elif [ "$CAPACITY" -ge 80 ]; then
        ICON="󰥅"
    elif [ "$CAPACITY" -ge 70 ]; then
        ICON="󰥄"
    elif [ "$CAPACITY" -ge 60 ]; then
        ICON="󰥃"
    elif [ "$CAPACITY" -ge 50 ]; then
        ICON="󰥂"
    elif [ "$CAPACITY" -ge 40 ]; then
        ICON="󰥁"
    elif [ "$CAPACITY" -ge 30 ]; then
        ICON="󰥀"
    elif [ "$CAPACITY" -ge 20 ]; then
        ICON="󰤿"
    elif [ "$CAPACITY" -ge 10 ]; then
        ICON="󰤾"
    else
        ICON="󰥇"
    fi
    TOOLTIP=",\"tooltip\":\"Nombre: $NAME\nBateria: $CAPACITY%\""
    ICON="$CAPACITY% $ICON"
else
    ICON="󰂯"
    TOOLTIP=",\"tooltip\":\"Ningun dispositivo conectado\""
fi


echo {\"text\":\"$ICON\"$TOOLTIP }
