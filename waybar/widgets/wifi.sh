#!/bin/bash

# Mostrar iconos ethernet
ETH_IFACE=$(nmcli device status | awk '/ethernet/ && $3=="conectado" {print $1; exit}')

if [ -n "$ETH_IFACE" ]; then
    echo "{\"text\": \"\", \"tooltip\": \"Ethernet: $ETH_IFACE\", \"percentage\": 100 }"
    exit 0
fi

# Muestra redes Wi-Fi

# Nivel de señal (0-100)
SIGNAL=$(nmcli -t -f IN-USE,SIGNAL dev wifi | awk -F: '/\*/{print $2}')
[ -z "$SIGNAL" ] && SIGNAL=0

ICON=$(if [ "$SIGNAL" -ge 80 ]; then
    echo "󰤨"
elif [ "$SIGNAL" -ge 60 ]; then
    echo "󰤥"
elif [ "$SIGNAL" -ge 40 ]; then
    echo "󰤢"
elif [ "$SIGNAL" -ge 20 ]; then
    echo "󰤟"
else
    echo "󰤯"
fi)


### ToolTip

# Interfaz wifi (la primera que encuentre)
IFACE=$(nmcli device status | awk '/wifi/ {print $1; exit}')
[ -z "$IFACE" ] && echo "睊" && exit 0  # icono de no wifi

# Señal de la red activa
ACTIVE_SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '$1=="sí"{print $2}')

TOOLTIP="SSID: $ACTIVE_SSID\\nSeñal: $SIGNAL%"

IPv4=$(ip -4 addr show "$IFACE" | awk '/inet /{print $2}')
if [ -n "$IPv4" ]; then
    TOOLTIP="$TOOLTIP\\nIPv4: $IPv4"
fi

IPv6=$(ip -6 addr show "$IFACE" | awk '/inet /{print $2}')
if [ -n "$IPv6" ]; then
    TOOLTIP="$TOOLTIP\\nIPv6: $IPv6"
fi

echo {\"text\": \"$ICON\", \"tooltip\": \"$TOOLTIP\", \"percentage\": $SIGNAL }
