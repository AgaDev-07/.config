#!/usr/bin/env bash

# Obtiene info de la ventana activa
active=$(hyprctl activewindow -j | jq -r '.address')

if [[ "$active" == "null" || -z "$active" ]]; then
  # No hay ventana → abrir menú power
  ~/.config/aga/menus/power.sh
else
  # Hay ventana → cerrarla
  hyprctl dispatch killactive
fi
