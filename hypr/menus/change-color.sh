#!/usr/bin/env bash

exec > /tmp/theme-bind.log 2>&1
set -e
set -x

source "$HOME/.config/aga/lib/color.sh"

THEMES_DIR="$HOME/.config/aga/themes"

# =========================
# Change VSCode color
# =========================
change-code-color(){
  sed -i -E \
    -e "s|(\"activityBar\.$1\"[[:space:]]*:[[:space:]]*\")[^\"]*(\".*)|\1$2\2|" \
    -e "s|(\"activityBarTop\.$1\"[[:space:]]*:[[:space:]]*\")[^\"]*(\".*)|\1$2\2|" \
    "$HOME/.config/Code/User/settings.json"
}

# =========================
# Extract base color
# =========================
get_color() {
  local file="$1"
  local color="$2"
  [[ -z color ]] && color=base
  grep "@define-color $color" "$file/main.css" \
    | sed -E "s/.*$color[[:space:]]+([^;]+);/\1/" \
    | head -n 1
}

# =========================
# Make list "theme (color)"
# =========================
list_themes() {
  for f in "$THEMES_DIR"/*; do
    base="$(basename "$f")"
    [[ "$base" == "_.css" ]] && continue
    [[ "$base" == "main.css" ]] && continue

    color=$(get_color "$f")
    echo "$base ($color)"
  done
}

# =========================
# Set the colors in theme
# =========================
set_theme() {
  THEME_NAME=$(echo "$1" | sed -E 's/^(.*) \(.+\)$/\1/')
  THEME_DIR="$THEMES_DIR/$THEME_NAME"
  color=$(get_color "$THEME_DIR")
  color_rgb=$(to_rgb "$color")
  color_hex=$(to_hex "$color")

  ln -sf "$THEME_DIR/kitty.conf" "$HOME/.config/kitty/colors.conf"
  killall -SIGUSR1 kitty || true

  change-code-color "border" "$color_hex"
  change-code-color "foreground" "$color_hex"
  change-code-color "activeBorder" "$color_hex"
  change-code-color "activeFocusBorder" "$color_hex"
  change-code-color "activeBackground" "$(hex_add_alpha "$color_hex" "4" | to_hex)"
  change-code-color "inactiveForeground" "$(get_color "$THEME_DIR" "hover" | to_hex)"
  
  echo -e "@import '_.css';\n@import '$THEME_NAME/main.css';" > "$HOME/.config/aga/themes/main.css"
  echo -e "general {\ncol.active_border = $color_rgb\n}" > "$HOME/.config/hypr/modules/ui/color.conf"
  "$HOME/.config/aga/scripts/reload-ui.sh" &
  swww img "$THEME_DIR/wallpaper" --transition-type outer --transition-duration 0.7
}

# =========================
#  Lógica principal
# =========================
items=$(list_themes)
lines=$(echo "$items" | wc -l)

if [[ $lines -ge 8 ]]; then lines=8
fi

SELECTED=$(echo "$items" | wofi --dmenu --hide-search --prompt "" -L $lines -W 20%)
[[ -z "$SELECTED" ]] && exit 0

set_theme "$SELECTED"
