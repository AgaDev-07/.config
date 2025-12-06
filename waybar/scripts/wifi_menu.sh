#!/bin/bash

# =========================
# Dependencias
# =========================
require() {
  if ! command -v "$1" &>/dev/null; then
    echo "Error: falta '$1'" >&2
    exit 1
  fi
}

if [[ ! -d "/sys/class/net/wlp1s0" ]]; then
  exit 0
fi

require nmcli
require wofi
require zenity

# =========================
# Configuración
# =========================
MAX_SSID=10

# Detectar interfaz Wi-Fi
IFACE=$(nmcli device status | awk '/wifi/ {print $1; exit}')
if [[ -z "$IFACE" ]]; then
  echo "No se detecta interfaz Wi-Fi"
  exit 1
fi

CURRENT_SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes:' | cut -d: -f2)

# =========================
# Función para asignar icono según intensidad y seguridad
# =========================
signal_icon() {
  local SSID="$1"
  local SIGNAL="$2"
  local SECURITY="$3"
  local ICON=""

  # Red actualmente conectada
  if [[ "$SSID" == "$CURRENT_SSID" ]]; then
    ICON="🔗"
  else
    if [[ "$SECURITY" == WPA* || "$SECURITY" == WEP* ]]; then
      if ((SIGNAL >= 80)); then ICON="󰤪"
      elif ((SIGNAL >= 60)); then ICON="󰤧"
      elif ((SIGNAL >= 40)); then ICON="󰤤"
      elif ((SIGNAL >= 20)); then ICON="󰤡"
      else ICON="󰤬"; fi
    else
      if ((SIGNAL >= 80)); then ICON="󰤨"
      elif ((SIGNAL >= 60)); then ICON="󰤥"
      elif ((SIGNAL >= 40)); then ICON="󰤢"
      elif ((SIGNAL >= 20)); then ICON="󰤟"
      else ICON="󰤯"; fi
    fi
  fi
  echo "$ICON"
}

# =========================
# Listar redes y asignar icono
# =========================
NETWORKS=$(nmcli -t -f SSID,SIGNAL,SECURITY dev wifi | grep -v '^:$' \
  | sort -t: -k2 -nr \
  | head -n $MAX_SSID \
  | while IFS=: read -r SSID SIGNAL SECURITY; do
    [[ -z "$SSID" ]] && continue
    ICON=$(signal_icon "$SSID" "$SIGNAL" "$SECURITY")
    echo "$ICON $SSID"
  done
)

# =========================
# Mostrar menú con Wofi
# =========================
CHOICE=$(echo "$NETWORKS" | wofi \
  --show dmenu \
  --allow-images \
  --hide-search \
  --prompt "Wi-Fi:" \
  -l 3 -L $(echo "$NETWORKS" | wc -l) \
  -x "-10" -y 10 -W 25%)

[[ -z "$CHOICE" ]] && exit 0

# =========================
# Extraer SSID
# =========================
SSID=$(echo "$CHOICE" | sed 's/^.\{2\} //') # ajusta número de chars si iconos cambian

# =========================
# Conexión segura
# =========================
EXISTING_CONN=$(nmcli -t -f NAME connection show | grep -xF "$SSID")
if [[ -n "$EXISTING_CONN" ]]; then
  nmcli connection up "$SSID"
  exit 0
fi

SECURITY=$(nmcli -t -f SSID,SECURITY dev wifi | grep -F "$SSID" | cut -d: -f2)

if [[ "$SECURITY" == WPA* || "$SECURITY" == WEP* ]]; then
  PASSWORD=$(zenity --password --title="Contraseña para $SSID")
  [[ -z "$PASSWORD" ]] && exit 0
  nmcli device wifi connect "$SSID" password "$PASSWORD"
else
  nmcli device wifi connect "$SSID"
fi
