#!/bin/bash
echo "$(cat <<EOF
[Desktop Entry]
Name=Intercept Link
Exec=$HOME/.config/aga/scripts/intercept-link.sh %u
Type=Application
Terminal=false
MimeType=x-scheme-handler/http;x-scheme-handler/https;
EOF
)" > "$HOME/.local/share/applications/intercept-link.desktop"

xdg-mime default intercept-link.desktop x-scheme-handler/http
xdg-mime default intercept-link.desktop x-scheme-handler/https;