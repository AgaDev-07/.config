#!/usr/bin/env bash

CLASS=$(hyprctl activewindow | grep "class:" | sed 's/.*class: //')

# Si no se obtuvo nada, salir
[ -z "$CLASS" ] && notify-send -u critical -a "Hyprland" "Hyprland" "No se detectó ninguna ventana activa." && exit 1

if [ "$CLASS" == "brave-browser" ]; then
    CLASS="brave"
elif [ "$CLASS" == "org.kde.dolphin" ]; then
    CLASS="dolphin"
fi

# Buscar el PID de un proceso que coincida con la clase
PID=$(pgrep -f "$CLASS" | head -n 1)

if [ -n "$PID" ]; then
    # Obtener el nombre del proceso
    CMD=$(ps -p $PID -o comm= | head -n 1)

    #notify-send "Hyprland" "Reiniciando $CMD..."
    notify-send -a "Hyprland" -i ~/.config/hypr/logo.webp "Hyprland" "Reiniciando $CMD… · $(date +'%H:%M:%S')"
    kill $PID
    sleep 0.5
    nohup $CMD >/dev/null 2>&1 &
else
    notify-send -u critical -a "Hyprland" -i ~/.config/hypr/logo.webp "Hyprland" "No se pudo reiniciar el programa $CLASS"
fi
