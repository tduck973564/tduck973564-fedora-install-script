echo "Remove useless apps"

sudo dnf5 remove akregator krusader konversation k3b kontact kmail korganizer kaddressbook *akonadi* kcalc krdc krfb kmousetool *abrt* mariadb mariadb-backup mariadb-common mariadb-cracklib-password-check mariadb-errmsg mariadb-gssapi-server mariadb-server mariadb-server-utils kmines kmahjongg kpat

echo "Install some apps"

FLATPAK_FLATHUB=( org.kde.isoimagewriter
org.kde.kclock 
org.kde.kweather
org.kde.francis
org.kde.kalk
org.kde.kget
org.kde.ktorrent
org.kde.digikam )

for app in "${FLATPAK_FLATHUB[@]}"; do
	flatpak install -y flathub "$app"
done

sudo dnf5 install -y libreoffice kdenetwork-filesharing kcolorchooser

echo "Settings overrides"
sudo dnf5 install -y filotimo-kde-overrides
