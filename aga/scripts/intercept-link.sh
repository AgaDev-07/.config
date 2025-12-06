#!/bin/bash
# intercept-link.sh
URL="$1"
TARGET_CLASS="brave-browser"

# Buscar el bloque de la ventana que coincida con todos los criterios
WORKSPACE=$(hyprctl clients | awk -v cls="$TARGET_CLASS" '
BEGIN { found=0 }
/workspace: [0-9]+ \([0-9]+\)/ { ws=$2 }
/floating: 0/ { f=1 }
/pseudo: 0/ { p=1 }
/monitor: 0/ { m=1 }
/class: / {
    if ($2==cls && f && p && m) {
        print ws
        exit
    }
}' )

# Si encontramos workspace, mover el foco
if [ -n "$WORKSPACE" ]; then
    hyprctl dispatch workspace "$WORKSPACE"
fi

# Abrir el enlace en Brave
brave "$URL" &
