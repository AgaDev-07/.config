#!/bin/bash
# Widget de red para Waybar
# Requiere: nmcli, awk, ip

source "$HOME/.config/aga/lib/require.sh"

if [[ ! -d "/sys/class/net/wlp1s0" && ! -d "/sys/class/net/enp0s31f6" ]]; then
  exit 0
fi
require nmcli

# =========================
# Comprobar Ethernet
# =========================
ETH_IFACE=$(nmcli device status | awk '/ethernet/ && $3=="conectado" {print $1; exit}')
if [ -n "$ETH_IFACE" ]; then
  echo "{\"text\": \"\", \"tooltip\": \"Ethernet: $ETH_IFACE\", \"percentage\": 100}"
  exit 0
fi

# =========================
# Comprobar Wi-Fi
# =========================
IFACE=$(nmcli device status | awk '/wifi/ {print $1; exit}')
[ -z "$IFACE" ] && echo '{"text":"睊","tooltip":"Sin Wi-Fi","percentage":0}' && exit 0

ACTIVE_SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '$1=="sí"{print $2}')
SIGNAL=$(nmcli -t -f IN-USE,SIGNAL dev wifi | awk -F: '/\*/{print $2}')
[ -z "$SIGNAL" ] && SIGNAL=0

# =========================
# Iconos según señal
# =========================
if (( SIGNAL >= 80 )); then
  ICON="󰤨"
elif (( SIGNAL >= 60 )); then
  ICON="󰤥"
elif (( SIGNAL >= 40 )); then
  ICON="󰤢"
elif (( SIGNAL >= 20 )); then
  ICON="󰤟"
else
  ICON="󰤯"
fi

# =========================
# Tooltip con información
# =========================
TOOLTIP="SSID: ${ACTIVE_SSID:-Desconocido}\\nSeñal: $SIGNAL%"

IPv4=$(ip -4 addr show "$IFACE" | awk '/inet /{print $2}')
[ -n "$IPv4" ] && TOOLTIP="$TOOLTIP\\nIPv4: $IPv4"

IPv6=$(ip -6 addr show "$IFACE" | awk '/inet /{print $2}')
[ -n "$IPv6" ] && TOOLTIP="$TOOLTIP\\nIPv6: $IPv6"

# =========================
# Salida JSON
# =========================
echo "{\"text\": \"$ICON\", \"tooltip\": \"$TOOLTIP\", \"percentage\": $SIGNAL}"
