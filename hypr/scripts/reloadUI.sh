pkill -f waybar 2>/dev/null
pkill -f swaync 2>/dev/null
sleep 0.5
GTK_THEME="" swaync > /dev/null 2>&1 &
waybar &
hyprctl reload