#!/usr/bin/env bash

CLASS=$(hyprctl activewindow | grep "class:" | sed 's/.*class: //')
LOGO=~/.config/hypr/images/logo.webp
APPLICATION="Hyprland"

# Si no se obtuvo nada, salir
if [ -z "$CLASS" ]; then
    notify-send -u critical -a $APPLICATION -i $LOGO $APPLICATION "No se detectó ninguna ventana activa."
    exit 1
fi

if [ "$CLASS" == "brave-browser" ]; then
    CLASS="brave"
fi

# Buscar el PID de un proceso que coincida con la clase
PID=$(pgrep -f "$CLASS" | head -n 1)

if [ -n "$PID" ]; then
    # Obtener el nombre del proceso
    CMD=$(ps -p $PID -o comm= | head -n 1)

    #notify-send "Hyprland" "Reiniciando $CMD..."
    notify-send -u low -a $APPLICATION -i $LOGO $APPLICATION "Reiniciando $CMD… · $(date +'%H:%M:%S')"
    kill $PID
    sleep 0.5
    nohup $CMD >/dev/null 2>&1 &
else
    notify-send -u critical -a $APPLICATION -i $LOGO $APPLICATION "No se pudo reiniciar el programa $CLASS"
fi
