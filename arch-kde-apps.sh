sudo pacman -S noto-fonts-emoji noto-fonts inter-font ttf-ibm-plex plasma-meta kde-system-meta libreoffice-fresh kweather kdeconnect kdegraphics-thumbnailers baloo-widgets dolphin-plugins ffmpegthumbs kio-admin kio-extras kio-fuse kio-gdrive libappindicator-gtk3 phonon-qt5-vlc xwaylandvideobridge maliit-keyboard xsettingsd xdg-desktop-portal-gtk kpipewire dolphin ark dragon elisa filelight gwenview kcalc sddm-kcm xdg-desktop-portal-kde kde-gtk-config bluedevil breeze-plymouth flatpak-kcm drkonqi plymouth-kcm kolourpaint spectacle okular kamera kcolorchooser colord-kde kwrite kclock konsole firefox kwalletmanager kweather print-manager skanpage kalgebra

FLATPAK_FLATHUB=( org.kde.isoimagewriter
org.kde.francis )
for app in ${FLATPAK_FLATHUB[@]}; do
	flatpak install -y flathub "$app"
done

sudo pacman -S kaddressbook kdepim-addons kmail kmail-account-wizard kontact korganiszer merkuro
