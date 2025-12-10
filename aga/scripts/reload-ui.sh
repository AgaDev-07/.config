#!/bin/bash

source "$HOME/.config/aga/lib/require.sh"
source "$HOME/.config/aga/lib/read_conf.sh"

require pkill
require pgrep
require waybar
require swaync
require hyprctl
require hyprpaper

BACKGROUND="/usr/share/sddm/themes/hypr-ely-neon/$(read_conf "Background")"

echo -e "preload = $BACKGROUND\nwallpaper = ,$BACKGROUND" > "$HOME/.config/hypr/hyprpaper.conf"

# =========================
# Función: matar procesos si existen
# =========================
kill_if_running() {
  local proc="$1"
  if pgrep -f "$proc" &>/dev/null; then
    pkill -f "$proc" 2>/dev/null
    return 0
  fi
  return 1
}

# =========================
# Función: iniciar programa solo si no está corriendo
# =========================
start_if_not_running() {
  local cmd="$1"
  if pgrep -f "$cmd" &>/dev/null; then
    return 0
  fi
  $cmd &
}

# =========================
# Reinicio seguro
# =========================

echo "Reiniciando Waybar y SwayNC…"

kill_if_running "waybar"
kill_if_running "swaync"

# Espera automática basada en carga → menos fallos
sleep 0.3

# Lanzamiento robusto
start_if_not_running "waybar"
start_if_not_running "swaync"

# =========================
# Recargar Hyprland
# =========================
if hyprctl reload &>/dev/null; then
  echo "Hyprland recargado correctamente."
else
  echo "Advertencia: No se pudo recargar Hyprland." >&2
fi