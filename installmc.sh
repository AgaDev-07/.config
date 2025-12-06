
curl -o MCPELauncher.flatpak https://download2269.mediafire.com/wdgpmzgakkfgWqrZ20gGYmy-ftE4A7o9VPeXascMSAngRQcGNcWHqH8Z5LkDqdVHVYIbP5XMartZvwotRzIJeiD2_x5ill8AatxtX1cTgxBXTrvdpZkMEbTFMP1VGDIPkMxYgNqJenkmFrGxxsbeTqqP3P-aExTBwvt4OFANFyxJp84/7ng8hziyywsfya3/MCPELauncher.flatpak

sudo pacman -S flatpak
flatpak install flathub org.kde.Platform//5.15-23.08 org.kde.Sdk//5.15-23.08 io.qt.qtwebengine.BaseApp//5.15-23.08

flatpak install MCPELauncher.flatpak