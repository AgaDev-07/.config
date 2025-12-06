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

require wofi

# =========================
# Configuración
# =========================
SETTINGS="$HOME/.config/gtk-3.0/settings.ini"
ICON_THEME=$(grep "^gtk-icon-theme-name=" "$SETTINGS" 2>/dev/null | cut -d= -f2)

# fallback si no encuentra tema
ICON_THEME="${ICON_THEME:-Papirus}"

APPS=$(cat <<EOF
Brave
Discord
Visual Studio Code
kitty
Thunar
ONLYOFFICE
Minecraft
EOF
)

# =========================
# Función: limpiar Exec=
# =========================
sanitize_exec() {
  local cmd="$1"
  # remover flags de archivos
  cmd="${cmd//%U/}"
  cmd="${cmd//%u/}"
  cmd="${cmd//%F/}"
  cmd="${cmd//%f/}"
  # limpiar espacios
  echo "$cmd" | sed 's/[[:space:]]*$//'
}

# =========================
# Función: obtener comando ejecutable
# =========================
get_cmd() {
  local app="$1"

  case "$app" in
    "Minecraft")
      echo "flatpak run com.mcpelauncher.MCPELauncher"
      return
    ;;
  esac

  # Buscar archivo .desktop
  local desktop
  desktop=$(grep -Rl "^Name=${app}$" \
    /usr/share/applications \
    ~/.local/share/applications \
    2>/dev/null | head -n 1)

  # Fallback a nombre en minúsculas
  if [[ -z "$desktop" || ! -f "$desktop" ]]; then
    echo "$(echo "$app" | tr 'A-Z' 'a-z')"
    return
  fi

  # Extraer Exec=
  local exec_cmd
  exec_cmd=$(grep -m1 "^Exec=" "$desktop" | cut -d= -f2-)

  # Fallback
  if [[ -z "$exec_cmd" ]]; then
    echo "$(echo "$app" | tr 'A-Z' 'a-z')"
    return
  fi

  sanitize_exec "$exec_cmd"
}

# =========================
# Función: comprobar si existe comando ejecutable
# =========================
exists() {
  local cmd="$1"
  # tomar primera palabra, ej: "brave --incognito"
  local bin=${cmd%% *}
  command -v "$bin" >/dev/null 2>&1 && echo 1 || echo 0
}

# =========================
# Función: obtener icono
# =========================
get_icon() {
  local app="$1"

  local desktop
  desktop=$(grep -Rl "^Name=${app}$" \
    /usr/share/applications \
    ~/.local/share/applications \
    2>/dev/null | head -n 1)

  if [[ -n "$desktop" ]]; then
    local icon=$(grep -m1 "^Icon=" "$desktop" | cut -d= -f2)
    [[ -n "$icon" ]] && echo "$icon" && return
  fi

  echo "$(echo "$app" | tr 'A-Z' 'a-z')"  # fallback icon
}

# =========================
# Construcción del menú
# =========================
formatted=""

while IFS= read -r app; do
  exe=$(get_cmd "$app")

  # Verificación robusta
  if [[ -z "$exe" ]] || [[ $(exists "$exe") -eq 0 ]]; then
    echo "[SKIP] $app → comando inválido ($exe)"
    continue
  fi

  icon=$(get_icon "$app")

  # Comprobar que realmente exista el icono
  ICON_PATH=""
  for size in scalable 256 128 64 48 32 24 22 16; do
    try="/usr/share/icons/$ICON_THEME/${size}x${size}/apps/$icon.svg"
    if [[ -f "$try" ]]; then
      ICON_PATH="$try"
      break
    fi
  done

  # fallback ultrafuerte a tema hicolor
  if [[ -z "$ICON_PATH" ]]; then
    ICON_PATH="/usr/share/icons/hicolor/48x48/apps/$icon.svg"
  fi

  # fallback final a ícono default
  if [[ ! -f "$ICON_PATH" ]]; then
    ICON_PATH="/usr/share/pixmaps/$icon.png"
  fi

  # fallback extremo: si no existe nada, no pone imagen
  if [[ ! -f "$ICON_PATH" ]]; then
    ICON_PATH=""
  fi

  [[ -n "$formatted" ]] && formatted+=$'\n'

  if [[ -n "$ICON_PATH" ]]; then
    formatted+="img:$ICON_PATH:text:$app"
  else
    formatted+="text:$app"
  fi

done <<< "$APPS"

# =========================
# Mostrar menú
# =========================
chosen=$(echo -e "$formatted" | wofi \
  --show dmenu \
  --allow-images \
  --hide-search \
  --prompt "" \
  --location=center)

[ -z "$chosen" ] && exit 0

selected_app=$(echo "$chosen" | awk -F':' '{print $NF}')

# Ejecutar en background
$(get_cmd "$selected_app") &
