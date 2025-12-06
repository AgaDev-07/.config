#!/bin/bash
# Widget de música para Waybar
# Requiere: playerctl

# =========================
# Dependencias
# =========================
require() {
  if ! command -v "$1" &>/dev/null; then
    echo "Error: falta '$1'" >&2
    exit 1
  fi
}

require playerctl

# =========================
# Configuración
# =========================
MAX_LENGTH=50

# Obtener lista de reproductores activos
players=$(playerctl -l 2>/dev/null)
[[ -z "$players" ]] && exit 0

# Usar el primer reproductor disponible
player=$(echo "$players" | head -n1)
title=$(playerctl metadata --player="$player" --format '{{ title }}' 2>/dev/null || echo '')
artist=$(playerctl metadata --player="$player" --format '{{ artist }}' 2>/dev/null || echo '')

# =========================
# Elegir icono según reproductor
# =========================
case "$player" in
  *spotify*) icon='' ;;
  *brave*)
    if [[ "$title" == *YouTube* ]] || [[ "$artist" == *YouTube* ]]; then
      icon=''
    else
      icon=''
    fi
    ;;
  *mpv*) icon='' ;;
  *) icon='🎵' ;;
esac

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
echo "$icon  ${artist:+$artist: }$title"
