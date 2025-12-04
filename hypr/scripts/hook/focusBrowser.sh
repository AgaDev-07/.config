#!/bin/bash
if [[ "$2" =~ (firefox|Chromium|Google-chrome|Brave-browser) ]]; then
    hyprctl dispatch focuswindow address:$1
    ws=$(hyprctl -j clients | jq -r ".[] | select(.address==\"$1\") | .workspace.id")
    hyprctl dispatch workspace "$ws"
fi
