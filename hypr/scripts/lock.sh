#!/bin/bash

source "$HOME/.config/aga/lib/require.sh"
source "$HOME/.config/aga/lib/read_conf.sh"

require grim
require magick

set -e

# =========================
# Configuración
# =========================
IMAGES_DIR="$HOME/.config/hypr/images"
OUTPUT="$IMAGES_DIR/background.png"
STATIC="$IMAGES_DIR/background_static.png"
USE_SCREENSHOT="false"

mkdir -p "$IMAGES_DIR"

# Saltar si está en caché y no se usa captura
if [[ "$USE_SCREENSHOT" != "true" && -e "$STATIC" ]]; then
  hyprlock
  exit 0
fi

[[ -e "$STATIC" ]] && rm "$STATIC"

CMD=""

# =========================
# Leer configuración del tema
# =========================
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
  left)  H="West" ;;
  right) H="East" ;;
  center|*) H="" ;;
esac

case "$BG_ALIGN_V" in
  top) V="North" ;;
  bottom) V="South" ;;
  center|*) V="" ;;
esac

if [[ -n "$H" && -n "$V" ]]; then
  GRAVITY="${V}${H}"   # NorthWest, SouthEast, etc.
elif [[ -n "$H" ]]; then
  GRAVITY="$H"         # West, East
elif [[ -n "$V" ]]; then
  GRAVITY="$V"         # North, South
else
  GRAVITY="Center"
fi

# =========================
# Generar fondo base
# =========================
if [[ "$USE_SCREENSHOT" == "true" ]]; then
  CMD="grim -g \"0,0 ${SCREEN_W}x${SCREEN_H}\" - | magick - -blur 0x10"
else
  BACKGROUND="/usr/share/sddm/themes/hypr-ely-neon/$(read_conf "Background")"

  CMD="magick \"$BACKGROUND\" \( +clone -resize ${SCREEN_W}x${SCREEN_H}^ -gravity \"$GRAVITY\" -extent ${SCREEN_W}x${SCREEN_H} \)"
fi

# =========================
# Crear blur detrás del formulario
# =========================
if [[ "$PARTIAL_BLUR" == "true" ]]; then
  case "$FORM_POSITION" in
    left) POS_X=0 ;;
    center) POS_X=$((SCREEN_W/2 - FORM_WIDTH/2)) ;;
    right) POS_X=$((SCREEN_W - FORM_WIDTH)) ;;
    *) POS_X=0 ;;
  esac

  CMD+=" \( +clone -crop ${FORM_WIDTH}x${FORM_HEIGHT}+${POS_X}+0 -blur 0x${BLUR_RADIUS} -geometry +${POS_X}+0 \) -compose over -composite"
fi

# =========================
# Overlay semitransparente
# =========================
if [[ $(echo "$OVERLAY_OPACITY > 0" | bc -l) ]]; then
  CMD+=" -fill \"rgba(0,0,0,${OVERLAY_OPACITY})\" -draw \"rectangle 0,0 ${SCREEN_W},${SCREEN_H}\""
fi

# =========================
# Ejecutar comando
# =========================

eval "$CMD \"$OUTPUT\""

# =========================
# Crear enlace estático
# =========================
if [[ "$USE_SCREENSHOT" != "true" ]]; then
  ln -sf "$OUTPUT" "$STATIC"
fi

# =========================
# Lanzar Hyprlock
# =========================
hyprlock
