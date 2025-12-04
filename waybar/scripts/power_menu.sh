#!/bin/bash

chosen=$(printf " Bloquear\n󰍃 Cerrar sesión\n󰑓 Reiniciar\n󰐥 Apagar" | wofi --show dmenu --hide-search --prompt "" --location=center)

case "$chosen" in
    " Bloquear") hyprlock ;;
    "󰍃 Cerrar sesión") hyprctl dispatch exit ;;
    "󰑓 Reiniciar") systemctl reboot ;;
    "󰐥 Apagar") systemctl poweroff ;;
esac
