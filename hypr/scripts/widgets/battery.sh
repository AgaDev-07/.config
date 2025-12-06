#!/bin/bash

# =========================
# Ruta de la batería
# =========================
BAT_PATH="/sys/class/power_supply/BAT0"

if [[ ! -d "$BAT_PATH" ]]; then
  echo "100% 󰂄"
  exit 0
fi

# =========================
# Leer datos
# =========================
CAPACITY=$(cat "$BAT_PATH/capacity" 2>/dev/null)
STATUS=$(cat "$BAT_PATH/status" 2>/dev/null)

# Validar porcentaje
if ! [[ "$CAPACITY" =~ ^[0-9]+$ ]]; then
  CAPACITY=0
fi
(( CAPACITY > 100 )) && CAPACITY=100
(( CAPACITY < 0 )) && CAPACITY=0

# =========================
# Iconos de batería
# =========================
ICON=""

if [[ "$STATUS" == "Discharging" ]]; then
  case $CAPACITY in
    100) ICON=󰁹 ;;
    90|91|92|93|94|95|96|97|98|99) ICON=󰂂 ;;
    80|81|82|83|84|85|86|87|88|89) ICON=󰂁 ;;
    70|71|72|73|74|75|76|77|78|79) ICON=󰂀 ;;
    60|61|62|63|64|65|66|67|68|69) ICON=󰁿 ;;
    50|51|52|53|54|55|56|57|58|59) ICON=󰁾 ;;
    40|41|42|43|44|45|46|47|48|49) ICON=󰁽 ;;
    30|31|32|33|34|35|36|37|38|39) ICON=󰁼 ;;
    20|21|22|23|24|25|26|27|28|29) ICON=󰁻 ;;
    10|11|12|13|14|15|16|17|18|19) ICON=󰁺 ;;
    *) ICON=󰂎 ;;
  esac
elif [[ "$STATUS" == "Charging" ]]; then
  case $CAPACITY in
    100) ICON=󰂅 ;;
    90|91|92|93|94|95|96|97|98|99) ICON=󰂋 ;;
    80|81|82|83|84|85|86|87|88|89) ICON=󰂊 ;;
    70|71|72|73|74|75|76|77|78|79) ICON=󰢞 ;;
    60|61|62|63|64|65|66|67|68|69) ICON=󰂉 ;;
    50|51|52|53|54|55|56|57|58|59) ICON=󰢝 ;;
    40|41|42|43|44|45|46|47|48|49) ICON=󰂈 ;;
    30|31|32|33|34|35|36|37|38|39) ICON=󰂇 ;;
    20|21|22|23|24|25|26|27|28|29) ICON=󰂆 ;;
    10|11|12|13|14|15|16|17|18|19) ICON=󰢜 ;;
    *) ICON=󰢟 ;;
  esac
else ICON=󰂄
fi

# =========================
# Salida JSON para Waybar
# =========================
echo "$CAPACITY% $ICON"
