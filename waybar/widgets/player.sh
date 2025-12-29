#!/bin/bash
# Widget de música para Waybar
# Requiere: playerctl

source "$HOME/.config/aga/lib/require.sh"

require playerctl

# =========================
# Configuración
# =========================
MAX_LENGTH=50

parse_anime() {
  if echo "$title" | grep -qiE '\|[[:space:]]*veranime\.top$'; then
    # Quitar símbolo inicial
    CLEAN=$(echo "$title" | sed 's/^▷[[:space:]]*//')

    # Serie (sin Cap ni Season)
    title=$(echo "$CLEAN" | sed -E 's/(Cap[[:space:]]+[0-9]+).*//; s/[0-9]+(st|nd|rd|th)[[:space:]]+Season//I' | xargs)

    # Capítulo
    CAP=$(echo "$CLEAN" | grep -oE 'Cap[[:space:]]+[0-9]+' | grep -oE '[0-9]+')

    # Temporada (opcional)
    SEASON=$(echo "$CLEAN" | grep -oiE '[0-9]+(st|nd|rd|th)[[:space:]]+Season' \
      | sed -E 's/[^0-9]//g')

    icon=⛩
    if [[ -n "$SEASON" ]]; then
      artist=$(echo "T$SEASON EP $CAP")
      tooltip=$(echo "$title\\nTemporada $SEASON\\nEpisodio $CAP")
    else
      artist=$(echo "EP $CAP")
      tooltip=$(echo "$title\\nEpisodio $CAP")
    fi
  fi
  if echo "$title" | grep -qiE '\-[[:space:]]*animeflv$'; then
    # Quitar símbolo inicial
    CLEAN=$title

    # Serie (sin Cap ni Season)
    title=$(echo "$CLEAN" | sed -E 's/(Episodio[[:space:]]+[0-9]+).*//; s/[0-9]+(st|nd|rd|th)[[:space:]]+Season//I' | xargs)

    # Capítulo
    CAP=$(echo "$CLEAN" | grep -oE 'Episodio[[:space:]]+[0-9]+' | grep -oE '[0-9]+')

    # Temporada (opcional)
    SEASON=$(echo "$CLEAN" | grep -oiE '[0-9]+(st|nd|rd|th)[[:space:]]+Season' \
      | sed -E 's/[^0-9]//g')

    icon=⛩
    if [[ -n "$SEASON" ]]; then
      artist=$(echo "T$SEASON EP $CAP")
      tooltip=$(echo "$title\\nTemporada $SEASON\\nEpisodio $CAP")
    else
      artist=$(echo "EP $CAP")
      tooltip=$(echo "$title\\nEpisodio $CAP")
    fi
  fi
}

# Obtener lista de reproductores activos
players=$(playerctl -l 2>/dev/null)
[[ -z "$players" ]] && exit 0

# Usar el primer reproductor disponible
player=$(echo "$players" | head -n1)
title=$(playerctl metadata --player="$player" --format '{{ title }}' 2>/dev/null || echo '')
tooltip=$title
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

parse_anime

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
echo "{\"text\": \"$icon  ${artist:+$artist: }$title\", \"tooltip\": \"$tooltip\"}"
