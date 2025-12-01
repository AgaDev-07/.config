#!/bin/bash

# =========================
# Hyprlock SDDM-style (Hypr-Ely-Neon)
# =========================

# Configuración
THEME_CONF="/usr/share/sddm/themes/hypr-ely-neon/theme.conf"
WALLPAPER="/usr/share/sddm/themes/hypr-ely-neon/Backgrounds/Hyprland.png"
LOCK_DIR="$HOME/.config/hypr/hyprlock"
OUTPUT="$LOCK_DIR/background.png"
mkdir -p "$LOCK_DIR"

# =========================
# Leer configuración de theme.conf
# =========================
read_conf() {
  grep "^$1=" "$THEME_CONF" | cut -d'=' -f2 | tr -d '"'
}

SCREEN_W=$(read_conf "ScreenWidth")
SCREEN_H=$(read_conf "ScreenHeight")
FORM_POSITION=$(read_conf "FormPosition")
FORM_WIDTH=$(($SCREEN_W / 3))
FORM_HEIGHT=$SCREEN_H
PARTIAL_BLUR=$(read_conf "PartialBlur")
BLUR_RADIUS=$(read_conf "BlurRadius")
OVERLAY_OPACITY=$(read_conf "DimBackgroundImage")
SCALE_IMAGE=$(read_conf "ScaleImageCropped")
BG_ALIGN_H=$(read_conf "BackgroundImageHAlignment")
BG_ALIGN_V=$(read_conf "BackgroundImageVAlignment")

# =========================
# Ajustes de alineación horizontal
# =========================
case "$BG_ALIGN_H" in
  left) GRAVITY_H="West" ;;
  right) GRAVITY_H="East" ;;
  center|*) GRAVITY_H="Center" ;;
esac

# Ajustes de alineación vertical
case "$BG_ALIGN_V" in
  top) GRAVITY_V="North" ;;
  bottom) GRAVITY_V="South" ;;
  center|*) GRAVITY_V="" ;;
esac

GRAVITY="$GRAVITY_H$GRAVITY_V"

# =========================
# 1️⃣ Escalar y recortar proporcionalmente
# =========================
BASE="$LOCK_DIR/background_base.png"
if [ "$SCALE_IMAGE" = "true" ]; then
    magick "$WALLPAPER" -resize ${SCREEN_W}x${SCREEN_H}^ -gravity $GRAVITY -extent ${SCREEN_W}x${SCREEN_H} "$BASE"
else
    magick "$WALLPAPER" -resize ${SCREEN_W}x${SCREEN_H} -gravity $GRAVITY -extent ${SCREEN_W}x${SCREEN_H} "$BASE"
fi

# =========================
# 2️⃣ Crear el blur detrás del formulario
# =========================
BLUR="$LOCK_DIR/background_blur.png"

if [ "$PARTIAL_BLUR" = "true" ]; then
  case "$FORM_POSITION" in
    left) POS_X=0 ;;
    center) POS_X=$(($SCREEN_W/2 - $FORM_WIDTH/2)) ;;
    right) POS_X=$(($SCREEN_W - $FORM_WIDTH)) ;;
    *) POS_X=0 ;;
  esac

  magick "$BASE" -crop ${FORM_WIDTH}x${FORM_HEIGHT}+${POS_X}+0 +repage -blur 0x${BLUR_RADIUS} "$BLUR"

  # Combinar el blur con el fondo
  magick "$BASE" "$BLUR" -geometry +${POS_X}+0 -composite "$OUTPUT"
else
  cp "$BASE" "$OUTPUT"
fi

# =========================
# 3️⃣ Overlay semitransparente
# =========================
if (( $(echo "$OVERLAY_OPACITY > 0" | bc -l) )); then
  magick "$OUTPUT" -fill "rgba(0,0,0,${OVERLAY_OPACITY})" -draw "rectangle 0,0 ${SCREEN_W},${SCREEN_H}" "$OUTPUT"
fi

# =========================
# 4️⃣ Limpiar temporales
# =========================
rm -f "$BASE" "$BLUR"
