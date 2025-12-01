#!/usr/bin/env bash

# --- Rutas donde buscar temas ---
ICON_DIRS=("$HOME/.icons" "/usr/share/icons")

# --- Buscar temas que contengan cursors/ ---
themes=()
for dir in "${ICON_DIRS[@]}"; do
    [ -d "$dir" ] || continue
    while IFS= read -r -d '' theme; do
        themes+=("$(basename "$(dirname "$theme")")")
    done < <(find "$dir" -type d -name "cursors" -print0)
done

# --- Eliminar duplicados ---
themes=($(printf "%s\n" "${themes[@]}" | sort -u))

# --- Mostrar menú con wofi ---
chosen=$(printf "%s\n" "${themes[@]}" | wofi --show dmenu --prompt "Cursor:" --hide-search --location=center)

# --- Salir si no se eligió nada ---
[ -z "$chosen" ] && exit

# --- Aplicar el cursor temporalmente ---
export XCURSOR_THEME="$chosen"
export XCURSOR_SIZE=24

# --- Aplicar al entorno GTK también ---
gsettings set org.gnome.desktop.interface cursor-theme "$chosen" >/dev/null 2>&1
gsettings set org.gnome.desktop.interface cursor-size 24 >/dev/null 2>&1

# --- Guardar como configuración persistente ---
mkdir -p ~/.icons/default
cat > ~/.icons/default/index.theme <<EOF
[Icon Theme]
Inherits=$chosen
EOF

# --- Recargar Hyprland ---
hyprctl reload

# --- Notificar el cambio ---
notify-send "Cursor cambiado" "Tema actual: $chosen"
