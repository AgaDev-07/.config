#!/bin/bash

# =========================
# Configuración
# =========================
THEME_CONF="/usr/share/sddm/themes/hypr-ely-neon/theme.conf"

# =========================
# Cargar theme.conf en memoria (diccionario)
# =========================
declare -A THEME_MAP

while IFS='=' read -r key val; do
    # Ignorar líneas vacías o comentarios
    [[ -z "$key" || "$key" =~ ^# ]] && continue

    # Limpiar espacios
    key="${key%% }"
    val="${val%% }"

    # Quitar comillas si existen
    val="${val%\"}"
    val="${val#\"}"

    THEME_MAP["$key"]="$val"
done < "$THEME_CONF"

# =========================
# Función para leer valores
# =========================
read_conf() {
    printf "%s" "${THEME_MAP[$1]}"
}
