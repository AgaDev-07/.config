#!/bin/bash

STATE=$(bluetoothctl show | awk '/Powered/ {print $2}')

if [[ -z "$STATE" ]]; then
    echo ""
    exit 0
fi

if [[ "$STATE" == "no" ]]; then
    echo "{\"text\":\"󰂲\",\"tooltip\":\"Bluetooth apagado\"}"
    exit 0
fi


# ------------------------------
# LISTAR TODOS LOS DISPOSITIVOS CONECTADOS
# ------------------------------
CONNECTED=$(bluetoothctl devices Connected | awk '{print $2}')

if [[ -z "$CONNECTED" ]]; then
    echo "{\"text\":\"󰂯\",\"tooltip\":\"Ningún dispositivo conectado\"}"
    exit 0
fi


TOOLTIP=""
COUNT=0


# Detectar icono por tipo
device_icon() {
    local MAC=$1
    local CLASS=$(bluetoothctl info "$MAC" | awk -F' ' '/Class:/ {print $2}')
    case "$CLASS" in
        0x00240404) echo "🎧" ;; # Auriculares
        0x00240408) echo "🔊" ;; # Bocina
        0x005*)     echo "📱" ;; # Teléfono
        0x002580*)  echo "🖱" ;; # Mouse
        0x002508*)  echo "⌨️" ;; # Teclado
        *)          echo "󰂯" ;;
    esac
}


# ------------------------------
# PROCESAR CADA DISPOSITIVO
# ------------------------------
for MAC in $CONNECTED; do
    NAME=$(bluetoothctl info "$MAC" | awk -F': ' '/Name/ {print $2; exit}')
    ICON=$(device_icon "$MAC")
    BATTPERC=$(bluetoothctl info "$MAC" | awk -F'[()]' '/Battery Percentage/ {print $2}')

    if [[ -n "$BATTPERC" ]]; then
        BAT="🔋 $BATTPERC%"
    else
        BAT="🔌 Sin batería"
    fi

    TOOLTIP+="$ICON $NAME\n   $BAT\n\n"
    ((COUNT++))
done


TEXT="󰂯 $COUNT"

echo "{\"text\":\"$TEXT\",\"tooltip\":\"${TOOLTIP%\\n\\n}\"}"
