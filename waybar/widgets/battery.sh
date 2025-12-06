#!/bin/bash
# Widget de batería para Waybar

# Ruta de la batería (ajusta si tu sistema es diferente)
BAT_PATH="/sys/class/power_supply/BAT0"

# Verificar que la batería exista
if [ ! -d "$BAT_PATH" ]; then
    exit 1
fi

# Leer información de la batería
CAPACITY=$(cat "$BAT_PATH/capacity")      # Porcentaje
STATUS=$(cat "$BAT_PATH/status")          # Charging / Discharging / Full
TOOLTIP=""

# Cambiar icono si está cargando
if [ "$STATUS" = "Discharging" ]; then
    TOOLTIP="En uso"
    if [ "$CAPACITY" = 100 ]; then
        ICON=󰁹
    elif [ "$CAPACITY" -ge 90 ]; then
        ICON=󰂂
    elif [ "$CAPACITY" -ge 80 ]; then
        ICON=󰂁
    elif [ "$CAPACITY" -ge 70 ]; then
        ICON=󰂀
    elif [ "$CAPACITY" -ge 60 ]; then
        ICON=󰁿
    elif [ "$CAPACITY" -ge 50 ]; then
        ICON=󰁾
    elif [ "$CAPACITY" -ge 40 ]; then
        ICON=󰁽
    elif [ "$CAPACITY" -ge 30 ]; then
        ICON=󰁼
    elif [ "$CAPACITY" -ge 20 ]; then
        ICON=󰁻
    elif [ "$CAPACITY" -ge 10 ]; then
        ICON=󰁺
    else
        ICON=󰂎
    fi
    TEXT="$CAPACITY% $ICON"
elif [ "$STATUS" = "Full" ]; then
    ICON=󰂄
    TOOLTIP="Carga Completa"
elif [ "$STATUS" = "Charging" ]; then
    TOOLTIP=Cargando
    if [ "$CAPACITY" -ge 95 ]; then
        ICON=󰂅
    elif [ "$CAPACITY" -ge 90 ]; then
        ICON=󰂋
    elif [ "$CAPACITY" -ge 80 ]; then
        ICON=󰂊
    elif [ "$CAPACITY" -ge 70 ]; then
        ICON=󰢞
    elif [ "$CAPACITY" -ge 60 ]; then
        ICON=󰂉
    elif [ "$CAPACITY" -ge 50 ]; then
        ICON=󰢝
    elif [ "$CAPACITY" -ge 40 ]; then
        ICON=󰂈
    elif [ "$CAPACITY" -ge 30 ]; then
        ICON=󰂇
    elif [ "$CAPACITY" -ge 20 ]; then
        ICON=󰂆
    elif [ "$CAPACITY" -ge 10 ]; then
        ICON=󰢜
    else
        ICON=󰢟
    fi
fi

if [ "$TOOLTIP" = "" ]; then
    echo {\"text\": \"󰚥\", \"tooltip\": \"Energia por cable\" }
else
    echo {\"text\": \"$CAPACITY% $ICON\", \"tooltip\": \"$TOOLTIP\" }
fi