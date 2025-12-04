pkill -f waybar 2>/dev/null
pkill -f swaync 2>/dev/null
sleep 0.5
waybar &
hyprctl reload