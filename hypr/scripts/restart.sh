#!/bin/bash

source "$HOME/.config/aga/lib/require.sh"
source "$HOME/.config/aga/lib/notification.sh"

require hyprctl
require notify-send
require pgrep
require nohup

# ======================================
# Configuración
# ======================================
LOGO="$HOME/.config/hypr/images/logo.webp"
APPLICATION="Hyprland"

# ======================================
# Obtener CLASE de la ventana activa
# ======================================
CLASS=$(hyprctl activewindow 2>/dev/null | grep -m1 "class:" | sed 's/.*class: //')

if [[ -z "$CLASS" ]]; then
  send_notification critical "$APPLICATION" "$LOGO" "No se detectó ninguna ventana activa."
  exit 1
fi

# Normalización de clases especiales
case "$CLASS" in
  brave-browser) CLASS="brave" ;;
esac

# ======================================
# Buscar PID del proceso
# ======================================
PID=$(pgrep -f "$CLASS" | head -n 1)

if [[ -z "$PID" ]]; then
  send_notification critical "$APPLICATION" "$LOGO" "No se encontró ningún proceso asociado a '$CLASS'."
  exit 1
fi

# ======================================
# Obtener nombre del comando real
# ======================================
CMD=$(ps -p "$PID" -o comm= | head -n 1)

if [[ -z "$CMD" ]]; then
  send_notification critical "$APPLICATION" "$LOGO" "No se pudo obtener el comando del proceso '$CLASS'."
  exit 1
fi

# Evitar reiniciar Hyprland o procesos críticos
if [[ "$CMD" == "Hyprland" ]] || [[ "$CMD" == "systemd" ]] || [[ "$CMD" == "init" ]]; then
  send_notification critical "$APPLICATION" "$LOGO" "Por seguridad no se reiniciará el proceso '$CMD'."
  exit 1
fi

# Verificar si el comando existe antes de reiniciar
if ! command -v "$CMD" &>/dev/null; then
  echo "$CMD"
  send_notification critical "$APPLICATION" "$LOGO" "El comando '$CMD' no es ejecutable o no existe en PATH."
  exit 1
fi

# ======================================
# Reinicio seguro
# ======================================
send_notification low "$APPLICATION" "$LOGO" "Reiniciando $CMD… · $(date +'%H:%M:%S')"
kill "$PID" 2>/dev/null

sleep 0.4

# Reiniciar con nohup, preservando rutas con espacios
nohup "$CMD" >/dev/null 2>&1 & disown

exit 0
