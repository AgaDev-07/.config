#!/bin/bash
# Widget de música para Hyprlock
# Requiere: playerctl

source "$HOME/.config/aga/lib/require.sh"

require playerctl

# =========================
# Configuración
# =========================
MAX_LENGTH=30

# Obtener lista de reproductores activos
players=$(playerctl -l 2>/dev/null)
[[ -z "$players" ]] && exit 0

# Usar el primer reproductor disponible
player=$(echo "$players" | head -n1)
title=$(playerctl metadata --player="$player" --format '{{ title }}' 2>/dev/null || echo '')
artist=$(playerctl metadata --player="$player" --format '{{ artist }}' 2>/dev/null || echo '')

# =========================
# Recortar título largo sin cortar palabras
# =========================
if (( ${#title} > MAX_LENGTH )); then
  cut="${title:0:MAX_LENGTH}"
  cut="${cut% *}"             # retrocede al último espacio
  [[ -z "$cut" ]] && cut="${title:0:MAX_LENGTH}" # fallback si primera palabra muy larga
  title="$cut..."
fi

# Salir si no hay título
[[ -z "$title" ]] && exit 0

# =========================
# Mostrar resultado
# =========================
echo "${artist:+$artist: }"
echo "$title"
