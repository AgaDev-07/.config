#!/bin/bash

chosen=$(printf "Brave\nDiscord\nCode\nKitty\nThunar\nOnly Office\nMinecraft" | wofi --show dmenu --hide-search --prompt "" --location=center)

case "$chosen" in
    "Brave") brave ;;
    "Discord") discord ;;
    "Code") code ;;
    "Kitty") kitty ;;
    "Thunar") thunar ;;
    "Only Office") onlyoffice-desktopeditors ;;
    "Minecraft") flatpak run io.mrarm.mcpelauncher;;
esac
