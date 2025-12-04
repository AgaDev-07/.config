#!/bin/bash
# Widget de brillo para Waybar

# Requiere: brightnessctl

# Obtener brillo actual (0-100)
BRIGHT=$(brightnessctl -m | awk -F, '{print substr($4,1,length($4)-1)}')

# Iconos según nivel
if [ "$BRIGHT" == 100 ]; then
    ICON="󰛨"
elif [ "$BRIGHT" -ge 90 ]; then
    ICON="󱩖"
elif [ "$BRIGHT" -ge 80 ]; then
    ICON="󱩕"
elif [ "$BRIGHT" -ge 70 ]; then
    ICON="󱩔"
elif [ "$BRIGHT" -ge 60 ]; then
    ICON="󱩓"
elif [ "$BRIGHT" -ge 50 ]; then
    ICON="󱩒"
elif [ "$BRIGHT" -ge 40 ]; then
    ICON="󱩑"
elif [ "$BRIGHT" -ge 30 ]; then
    ICON="󱩐"
elif [ "$BRIGHT" -ge 20 ]; then
    ICON="󱩏"
elif [ "$BRIGHT" -ge 10 ]; then
    ICON="󱩎"
else
    ICON="󰛩"
fi

echo {\"text\": \"$ICON\", \"percentage\": $BRIGHT }
