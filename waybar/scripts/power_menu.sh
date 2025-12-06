#!/bin/bash

options=$(cat <<EOF
󰍁  Bloquear
󰗽  Cerrar sesión
󰑓  Reiniciar
󰐥  Apagar
EOF
)
chosen=$(printf "%s" "$options" | wofi \
  --show dmenu \
  --allow-images \
  --hide-search \
  -l 1 -L 4 -x 10 -y 10 -W 20%)

case "$chosen" in
  *Bloquear*) ~/.config/hypr/scripts/lock.sh ;;
  *Cerrar\ sesión*) hyprctl dispatch exit ;;
  *Reiniciar*) systemctl reboot ;;
  *Apagar*) systemctl poweroff ;;
esac
