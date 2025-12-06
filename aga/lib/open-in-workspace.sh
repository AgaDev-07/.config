#!/bin/bash
# Script genérico: open-in-workspace <workspace> <comando> [args]

open-in-ws() {
    WORKSPACE="$1"
    shift

    PID=$(hyprctl clients | grep -A4 "[c]lass: $1" | grep "pid" | cut -d':' -f2 | tr -d ' ')
    if [[ -n "$PID" ]]; then exit 0; fi

    # Abrir la aplicación en background
    "$@" &

    # Esperar dinámicamente a que la ventana aparezca
    for i in {1..50}; do   # máximo 50 intentos
        PID=$(hyprctl clients | grep -A4 "[c]lass: $1" | grep "pid" | cut -d':' -f2 | tr -d ' ')
        if [[ -n "$PID" ]]; then break; fi
        sleep 0.5
    done

    # Mover la ventana al workspace si se encontró
    if [[ -n "$PID" ]]; then
        hyprctl dispatch movetoworkspace $WORKSPACE,pid:$PID
    else
        echo "No se encontró la ventana de la aplicación para PID $PID."
    fi
}