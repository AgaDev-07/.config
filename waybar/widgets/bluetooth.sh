#!/bin/bash
# Widget Bluetooth para Waybar

source "$HOME/.config/aga/lib/require.sh"
if [[ ! -d "/sys/class/bluetooth/hci0" ]]; then
  exit 0
fi

require bluetoothctl

# =========================
# Estado de Bluetooth
# =========================
STATE=$(bluetoothctl show | awk '/Powered/ {print $2}')
if [[ -z "$STATE" ]]; then
  echo ""
  exit 0
fi

if [[ "$STATE" == "no" ]]; then
  echo '{"text":"󰂲","tooltip":"Bluetooth apagado"}'
  exit 0
fi

# =========================
# Listar dispositivos conectados
# =========================
CONNECTED=$(bluetoothctl devices Connected | awk '{print $2}')
if [[ -z "$CONNECTED" ]]; then
  echo '{"text":"󰂯","tooltip":"Ningún dispositivo conectado"}'
  exit 0
fi

# =========================
# Función para iconos según tipo
# =========================
device_icon() {
  local MAC="$1"
  local CLASS
  CLASS=$(bluetoothctl info "$MAC" | awk '/Class:/ {print $2}')
  case "$CLASS" in
    0x00240404) echo "🎧" ;; # Auriculares
    0x00240408) echo "🔊" ;; # Bocina
    0x005*)   echo "📱" ;; # Teléfono
    0x002580*)  echo "🖱" ;; # Mouse
    0x002508*)  echo "⌨️" ;; # Teclado
    *)      echo "󰂯" ;; # Default
  esac
}

# =========================
# Función obtener icono de batería
# =========================
battery_icon() {
  local CAPACITY="$1"
  local ICON
  if [[ "$CAPACITY" =~ ^[0-9]+$ ]]; then
    if [ "$CAPACITY" -ge 100 ]; then ICON="󰥈"
    elif [ "$CAPACITY" -ge 90 ]; then ICON="󰥆"
    elif [ "$CAPACITY" -ge 80 ]; then ICON="󰥅"
    elif [ "$CAPACITY" -ge 70 ]; then ICON="󰥄"
    elif [ "$CAPACITY" -ge 60 ]; then ICON="󰥃"
    elif [ "$CAPACITY" -ge 50 ]; then ICON="󰥂"
    elif [ "$CAPACITY" -ge 40 ]; then ICON="󰥁"
    elif [ "$CAPACITY" -ge 30 ]; then ICON="󰥀"
    elif [ "$CAPACITY" -ge 20 ]; then ICON="󰤿"
    elif [ "$CAPACITY" -ge 10 ]; then ICON="󰤾"
    else ICON="󰥇"
    fi
  else
    ICON="🔌"
  fi
  echo "$ICON $CAPACITY%"
}

# =========================
# Procesar cada dispositivo
# =========================
TOOLTIP=""
COUNT=0

for MAC in $CONNECTED; do
  INFO=$(bluetoothctl info "$MAC")
  NAME=$(echo "$INFO" | awk -F': ' '/Name/ {print $2; exit}')
  ICON=$(device_icon "$MAC")
  BATTPERC=$(echo "$INFO" | awk -F'[()]' '/Battery Percentage/ {print $2}')

  if [[ -n "$BATTPERC" ]]; then
    BAT=$(battery_icon "$BATTPERC")
  else
    BAT="🔌 Sin batería"
  fi

  TOOLTIP+="$ICON $NAME\n   $BAT\n\n"
  ((COUNT++))
done

TEXT="󰂯 $COUNT"

# =========================
# Salida JSON para Waybar
# =========================
echo "{\"text\":\"$TEXT\",\"tooltip\":\"${TOOLTIP%\\n\\n}\"}"
