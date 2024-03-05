#!/usr/bin/env bash

# Add software repositories
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
rpm-ostree install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install useful software
rpm-ostree install plasma-firewall openssl libreoffice dragon zsh gh \
  ibm-plex-fonts-all rsms-inter-fonts onedrive epson-inkjet-printer-escpr2
rpm-ostree override remove kcalc
rpm-ostree install https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher-2.2.0-travis995.0f91801.x86_64.rpm

# Install power-profiles-daemon
rpm-ostree install power-profiles-daemon

# Compatibility kernel arguments, should not be required
#rpm-ostree kargs --append='nouveau.config=NvGspRm=1'
#rpm-ostree kargs --append='acpi_osi=Linux'

# Install KDE flatpaks
FLATPAK_FLATHUB=( org.kde.isoimagewriter
org.kde.kclock 
org.kde.kweather
org.kde.kcolorchooser
org.kde.francis 
com.github.wwmm.easyeffects
org.kde.okular
org.kde.gwenview
org.kde.skanpage
org.kde.kamoso
org.kde.elisa
org.kde.kolourpaint
org.kde.digikam
org.kde.kalk )

for app in ${FLATPAK_FLATHUB[@]}; do
	flatpak install -y flathub "$app"
done

# Use sudo for kdesu, since root is locked in Fedora
kwriteconfig5 --file kdesurc --group super-user-command --key super-user-command sudo

echo "\n\nRun systemctl reboot to apply changes, then run postinstall.sh"
