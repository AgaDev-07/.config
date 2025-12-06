#!/bin/bash

# =========================
# Dependencias obligatorias
# =========================
require() {
  if ! command -v "$1" &>/dev/null; then
    echo "Error: falta '$1'" >&2
    exit 1
  fi
}

require grim
require magick

# =========================
# Hyprlock SDDM-style (Hypr-Ely-Neon)
# Fondo dinámico con captura, blur y overlay
# =========================

set -e

# Configuración
IMAGES_DIR="$HOME/.config/hypr/images"
OUTPUT="$IMAGES_DIR/background.png"
THEME_CONF="/usr/share/sddm/themes/hypr-ely-neon/theme.conf"
USE_SCREENSHOT="true"
CLEAN_TEMP="true"

mkdir -p "$IMAGES_DIR"

# =========================
# Funciones auxiliares
# =========================

# Lectura de valores en theme.conf con fallback si no existe o está vacío
read_conf() {
  local val
  val=$(grep -E "^$1=" "$THEME_CONF" 2>/dev/null | cut -d= -f2 | tr -d '"')
  echo "${val:-0}"    # fallback a 0 si está vacío
}

# =========================
# Captura o usa imagen del tema
# =========================

get_base() {
  local outfile="$IMAGES_DIR/background_base.png"

  # Intentar captura
  grim -g "0,0 ${SCREEN_W}x${SCREEN_H}" "$outfile" || true

  # Si no hay archivo válido → usar fondo del tema
  if [[ ! -s "$outfile" || "$USE_SCREENSHOT" == "false" ]]; then
    local BACKGROUND="/usr/share/sddm/themes/hypr-ely-neon/$(read_conf "Background")"

    local resize_flag="-resize ${SCREEN_W}x${SCREEN_H}^"
    [[ "$SCALE_IMAGE" != "true" ]] && resize_flag="-resize ${SCREEN_W}x${SCREEN_H}"

    magick "$BACKGROUND" \
      $resize_flag \
      -gravity "$GRAVITY" \
      -extent ${SCREEN_W}x${SCREEN_H} \
      "$outfile"
  fi

  echo "$outfile"
}

# =========================
# Leer configuración del tema
# =========================

# Obtener resolución real del monitor activo
RES=$(hyprctl monitors | grep -Eo '[0-9]+x[0-9]+' | head -n1)
SCREEN_W=${RES%x*}
SCREEN_H=${RES#*x}
FORM_POSITION=$(read_conf "FormPosition")
FORM_WIDTH=$((SCREEN_W / 3))
FORM_HEIGHT=$SCREEN_H
PARTIAL_BLUR=$(read_conf "PartialBlur")
BLUR_RADIUS=$(read_conf "BlurRadius")
OVERLAY_OPACITY=$(read_conf "DimBackgroundImage")
SCALE_IMAGE=$(read_conf "ScaleImageCropped")
BG_ALIGN_H=$(read_conf "BackgroundImageHAlignment")
BG_ALIGN_V=$(read_conf "BackgroundImageVAlignment")

# =========================
# Alineación de fondo
# =========================

case "$BG_ALIGN_H" in
  left) GRAVITY_H="West" ;;
  right) GRAVITY_H="East" ;;
  *) GRAVITY_H="Center" ;;
esac

case "$BG_ALIGN_V" in
  top) GRAVITY_V="North" ;;
  bottom) GRAVITY_V="South" ;;
  center|*) GRAVITY_V="" ;;
esac

GRAVITY="$GRAVITY_H$GRAVITY_V"

# =========================
# Generar fondo base
# =========================

BASE=$(get_base)
BLUR="$IMAGES_DIR/background_blur.png"

# =========================
# Crear blur detrás del formulario
# =========================

if [[ "$PARTIAL_BLUR" == "true" ]]; then

  case "$FORM_POSITION" in
    left)   POS_X=0 ;;
    center) POS_X=$((SCREEN_W/2 - FORM_WIDTH/2)) ;;
    right)  POS_X=$((SCREEN_W - FORM_WIDTH)) ;;
    *)    POS_X=0 ;;
  esac

  # Crop + blur
  magick "$BASE" \
    -crop ${FORM_WIDTH}x${FORM_HEIGHT}+${POS_X}+0 +repage \
    -blur 0x${BLUR_RADIUS} \
    "$BLUR"

  # Mezclar blur con fondo base
  magick "$BASE" "$BLUR" \
    -geometry +${POS_X}+0 -composite \
    "$OUTPUT"

else
  cp "$BASE" "$OUTPUT"
fi

# =========================
# Overlay semitransparente
# =========================

if (( $(echo "$OVERLAY_OPACITY > 0" | bc -l) )); then
  magick "$OUTPUT" \
    -fill "rgba(0,0,0,${OVERLAY_OPACITY})" \
    -draw "rectangle 0,0 ${SCREEN_W},${SCREEN_H}" \
    "$OUTPUT"
fi

# =========================
# Limpieza
# =========================
if [[ "$CLEAN_TEMP" == "true" ]]; then
  rm -f "$BASE" "$BLUR"
fi

# =========================
# Lanzar Hyprlock
# =========================
hyprlock
