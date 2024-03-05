sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo rpm-ostree install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo rpm-ostree install plasma-firewall openssl libreoffice

sudo rpm-ostree install zsh gh

sudo rpm-ostree kargs --append='nouveau.config=NvGspRm=1 acpi_osi=Linux'

sudo rpm-ostree install ibm-plex-fonts-all rsms-inter-fonts onedrive epson-inkjet-printer-escpr2
sudo rpm-ostree install https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher-2.2.0-travis995.0f91801.x86_64.rpm

FLATPAK_FLATHUB=( org.kde.kalgebra
org.kde.isoimagewriter
org.kde.kclock 
org.kde.kweather
org.kde.kcolorchooser
org.kde.francis 
com.github.wwmm.easyeffects )

for app in ${FLATPAK_FLATHUB[@]}; do
	flatpak install -y flathub "$app"
done

kwriteconfig5 --file kdesurc --group super-user-command --key super-user-command sudo
