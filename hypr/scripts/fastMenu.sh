#!/bin/bash

chosen=$(printf "Brave\nDiscord\nCode\nKitty\nDolphin\nOnly Office\nMinecraft" | wofi --show dmenu --hide-search --prompt "" --location=center)

case "$chosen" in
    "Brave") brave ;;
    "Discord") discord ;;
    "Code") code ;;
    "Kitty") kitty ;;
    "Dolphin") dolphin ;;
    "Only Office") onlyoffice-desktopeditors ;;
    "Minecraft") flatpak run com.mcpelauncher.MCPELauncher;;
esac
