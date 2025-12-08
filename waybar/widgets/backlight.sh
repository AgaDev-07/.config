#!/bin/bash
# Widget de brillo para Waybar
# Requiere: brightnessctl

source "$HOME/.config/aga/lib/require.sh"

if [[ ! -d "/sys/class/backlight" ]]; then
  exit 0
fi

require brightnessctl

# =========================
# Obtener brillo actual (0-100)
# =========================
BRIGHT=$(brightnessctl -m 2>/dev/null | awk -F, '{val=substr($4,1,length($4)-1); if(val>100) val=100; else if(val<0) val=0; print val}')

# Si falla, salir
if [[ -z "$BRIGHT" ]]; then
  BRIGHT=0
fi

# =========================
# Iconos según nivel
# =========================
if (( BRIGHT >= 100 )); then ICON=󰛨
elif (( BRIGHT >= 90 )); then ICON=󱩖
elif (( BRIGHT >= 80 )); then ICON=󱩕
elif (( BRIGHT >= 70 )); then ICON=󱩔
elif (( BRIGHT >= 60 )); then ICON=󱩓
elif (( BRIGHT >= 50 )); then ICON=󱩒
elif (( BRIGHT >= 40 )); then ICON=󱩑
elif (( BRIGHT >= 30 )); then ICON=󱩐
elif (( BRIGHT >= 20 )); then ICON=󱩏
elif (( BRIGHT >= 10 )); then ICON=󱩎
else ICON=󰛩
fi

# =========================
# Salida JSON para Waybar
# =========================
echo "{\"text\": \"$ICON\", \"percentage\": $BRIGHT}"
