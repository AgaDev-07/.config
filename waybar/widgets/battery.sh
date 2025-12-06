#!/bin/bash
# Widget de batería para Waybar

# =========================
# Ruta de la batería
# =========================
BAT_PATH="/sys/class/power_supply/BAT0"

if [[ ! -d "$BAT_PATH" ]]; then
  echo "{\"text\": \"󰚥\", \"tooltip\": \"Energia por cable\"}"
  exit 0
fi

# =========================
# Leer datos
# =========================
STATUS=$(cat "$BAT_PATH/status" 2>/dev/null)
INFO=$("$HOME/.config/hypr/scripts/widgets/battery.sh")

# =========================
# Iconos de batería
# =========================
TOOLTIP=""

if [[ "$STATUS" == "Discharging" ]]; then TOOLTIP="En uso"
elif [[ "$STATUS" == "Full" ]]; then TOOLTIP="Carga completa"
elif [[ "$STATUS" == "Charging" ]]; then TOOLTIP="Cargando"
else TOOLTIP="Sin información"
fi

# =========================
# Salida JSON para Waybar
# =========================
echo "{\"text\": \"$INFO\", \"tooltip\": \"$TOOLTIP\"}"
