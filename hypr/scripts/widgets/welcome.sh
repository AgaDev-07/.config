#!/bin/bash

# Configuración
THEME_CONF="/usr/share/sddm/themes/hypr-ely-neon/theme.conf"

# =========================
# Leer configuración de theme.conf
# =========================
read_conf() {
  grep "^$1=" "$THEME_CONF" | cut -d'=' -f2 | tr -d '"'
}

echo $(read_conf "HeaderText")