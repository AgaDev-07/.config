#!/bin/bash

IFACE=$(nmcli device status | awk '/wifi/ {print $1; exit}')
CURRENT_SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^sí' | cut -d: -f2)

# Función para asignar icono según intensidad de señal
signal_icon() {
    local SIGNAL=$1

    if [[ "$SSID" == "$CURRENT_SSID" ]]; then
        # Red actualmente conectada
        echo -n "🔗"
    fi
    if [[ "$SECURITY" == WPA* || "$SECURITY" == WEP* ]]; then
        local EXISTING_CONN=$(nmcli -t -f NAME connection show | grep -x "$SSID")
        if [ -n "$EXISTING_CONN" ]; then
            if [ "$SIGNAL" -ge 80 ]; then
                echo "󱛎 "
            elif [ "$SIGNAL" -ge 60 ]; then
                echo "󱛍 "
            elif [ "$SIGNAL" -ge 40 ]; then
                echo "󱛌 "
            elif [ "$SIGNAL" -ge 20 ]; then
                echo "󱛋 "
            else
                echo "󱛏 "
            fi
        else
            if [ "$SIGNAL" -ge 80 ]; then
                echo "󰤪 "
            elif [ "$SIGNAL" -ge 60 ]; then
                echo "󰤧 "
            elif [ "$SIGNAL" -ge 40 ]; then
                echo "󰤤 "
            elif [ "$SIGNAL" -ge 20 ]; then
                echo "󰤡 "
            else
                echo "󰤬 "
            fi
        fi
    else
        if [ "$SIGNAL" -ge 80 ]; then
            echo "󰤨 "
        elif [ "$SIGNAL" -ge 60 ]; then
            echo "󰤥 "
        elif [ "$SIGNAL" -ge 40 ]; then
            echo "󰤢 "
        elif [ "$SIGNAL" -ge 20 ]; then
            echo "󰤟 "
        else
            echo "󰤯 "
        fi
    fi
}

# Listar redes con su potencia y asignar icono
NETWORKS=$(nmcli -t -f SSID,SIGNAL,SECURITY dev wifi | grep -v '^:$' | sort -t: -k2 -nr | while IFS=: read -r SSID SIGNAL SECURITY; do
    ICON=$(signal_icon "$SIGNAL")
    if [ -n "$SSID" ]; then
        echo "$ICON $SSID"
    fi
done)

# Mostrar menú con Wofi
CHOICE=$(echo "$NETWORKS" | wofi --dmenu --prompt "Wi-Fi:")

# Si no se eligió nada, salir
[ -z "$CHOICE" ] && exit 0

if [[ "$CHOICE" == *"$CURRENT_SSID" ]]; then
    ICONS=3
else
    ICONS=2
fi

# Quitar icono para obtener solo el SSID
SSID=$(echo "$CHOICE" | sed "s/^.\{$ICONS\} //")

# Comprobar si ya existe conexión guardada
EXISTING_CONN=$(nmcli -t -f NAME connection show | grep -x "$SSID")

if [ -n "$EXISTING_CONN" ]; then
    nmcli connection up "$SSID"
    exit 0
fi


# Comprobar si la red requiere contraseña
SECURITY=$(nmcli -f SSID,SECURITY dev wifi | grep "$SSID" | awk '{print $2}')

if [[ "$SECURITY" == "WPA"* || "$SECURITY" == "WEP"* ]]; then
    # Pedir contraseña con Wofi (ocultando input)
    PASSWORD=$(zenity --password --title="Contraseña para $SSID")

    [ -z "$PASSWORD" ] && exit 0

    # Intentar conectar
    nmcli device wifi connect "$SSID" password "$PASSWORD"
else
    # Sin contraseña
    nmcli device wifi connect "$SSID"
fi
