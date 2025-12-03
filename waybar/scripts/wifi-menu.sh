#!/bin/bash

IFACE=$(nmcli device status | awk '/wifi/ {print $1; exit}')

# Listar redes (SSID único)
NETWORKS=$(nmcli -t -f SSID dev wifi | grep -v '^$' | sort -u)

# Mostrar menú con Wofi
SSID=$(echo "$NETWORKS" | wofi --dmenu --prompt "Wi-Fi:")

# Si no se eligió nada, salir
[ -z "$SSID" ] && exit 0

# Comprobar si la red requiere contraseña
SECURITY=$(nmcli -f SSID,SECURITY dev wifi | grep "$SSID" | awk '{print $2}')

if [[ "$SECURITY" == "WPA"* || "$SECURITY" == "WEP"* ]]; then
    # Pedir contraseña con Wofi (ocultando input)
    PASSWORD=$(wofi --dmenu --password --prompt "Contraseña para $SSID")

    [ -z "$PASSWORD" ] && exit 0

    # Intentar conectar
    nmcli device wifi connect "$SSID" password "$PASSWORD"
else
    # Sin contraseña
    nmcli device wifi connect "$SSID"
fi
