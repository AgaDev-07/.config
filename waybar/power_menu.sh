#!/bin/bash

chosen=$(printf "🔒 Bloquear\n💤 Suspender\n🔁 Reiniciar\n⏻ Apagar" | wofi --show dmenu --hide-search --prompt "" --location=center)

case "$chosen" in
    "🔒 Bloquear") hyprlock ;;
    "💤 Suspender") systemctl suspend ;;
    "🔁 Reiniciar") systemctl reboot ;;
    "⏻ Apagar") systemctl poweroff ;;
esac
