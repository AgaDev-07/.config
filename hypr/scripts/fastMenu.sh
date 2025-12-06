#!/bin/bash

ICON_THEME=$(grep "^gtk-icon-theme-name=" /home/Adrian/.config/gtk-3.0/settings.ini | cut -d= -f2)

apps=$(cat <<EOF
Brave
Discord
Visual Studio Code
kitty
Thunar
ONLYOFFICE
Minecraft
EOF
)

get_cmd() {
    local app="$1"

    case "$app" in
        "Minecraft")
            echo "flatpak run io.mrarm.mcpelauncher"
            return
        ;;
    esac

    # Buscar archivo .desktop
    local desktop
    desktop=$(grep -Rl "^Name=${app}$" \
        /usr/share/applications ~/.local/share/applications 2>/dev/null | head -n 1)

    # Si no existe el .desktop → fallback a nombre normal en minúsculas
    if [[ -z "$desktop" ]]; then
        echo "$(echo "$app" | tr 'A-Z' 'a-z')"
        return
    fi

    # Obtener Exec=
    local exec_cmd
    exec_cmd=$(grep "^Exec=" "$desktop" | head -n 1 | cut -d= -f2)

    # Si Exec= esta vacío → fallback
    if [[ -z "$exec_cmd" ]]; then
        echo "$(echo "$app" | tr 'A-Z' 'a-z')"
        return
    fi

    # Quitar argumentos como %U o %F
    exec_cmd=${exec_cmd//%U/}
    exec_cmd=${exec_cmd//%u/}
    exec_cmd=${exec_cmd//%F/}
    exec_cmd=${exec_cmd//%f/}

    echo $exec_cmd | sed 's/[[:space:]]*$//'
}

exists() {
    command -v "$1" >/dev/null 2>&1 && echo 1 || echo 0
}

# Mostrar iconos y nombres en bloques
formatted=""


while IFS= read -r app; do
    desktop=$(grep -Rl "^Name=${app}$" \
        /usr/share/applications ~/.local/share/applications 2>/dev/null | head -n 1)

    if [[ -n "$desktop" && -f "$desktop" ]]; then
        icon=$(grep -m 1 "^Icon=" "$desktop" | cut -d= -f2)
    else
        icon=$(echo "$app" | tr 'A-Z' 'a-z')
    fi

    # Convertir nombre → ejecutable
    exe=$(get_cmd "$app")
    echo "$app -> $exe $(exists "$exe")"
    # Si no se pudo mapear o no existe ese comando, saltar la app
    if [[ -z "$exe" ]] || [[ $(exists "$exe") -eq 0 ]]; then
        continue
    fi

    # Añadir salto de línea si no es  el primer elemento
    if [[ -n "$formatted" ]]; then
        formatted+=$'\n'
    fi

    # Bloque tipo grid: icono encima, nombre debajo
    formatted+=$(echo "img:/usr/share/icons/$ICON_THEME/48x48/apps/$icon.svg:text:$app")
done <<< "$apps"

chosen=$(echo -e "$formatted" | wofi \
    --show dmenu \
    --allow-images \
    --hide-search \
    --prompt "" \
    --location=center)

[ -z "$chosen" ] && exit 0

selected_app=$(echo "$chosen" | awk -F':' '{print $NF}')
$(get_cmd "$selected_app") &
