#!/bin/bash
cd ~

echo "Installation of GNOME Apps"
sudo dnf5 remove -y \
gnome-terminal \
rhythmbox

sudo dnf5 install -y \
gnome-tweaks \
seahorse \
gnome-console \
gnome-backgrounds-extras

flatpak install -y flathub \
com.github.tchx84.Flatseal \
com.mattjakeman.ExtensionManager \
io.github.realmazharhussain.GdmSettings \
io.bassi.Amberol \
com.github.huluti.Curtail \
com.belmoussaoui.Decoder \
com.adrienplazas.Metronome \
com.github.alexhuntley.Plots \
org.gnome.SoundRecorder \
org.gnome.Solanum \
com.github.liferooter.textpieces \
com.github.hugolabe.Wike \
io.posidon.Paper \
com.github.finefindus.eyedropper \
com.usebottles.bottles \
app.drey.Dialect \
com.github.maoschanz.drawing \
ca.desrt.dconf-editor \
org.nickvision.tubeconverter \
org.gnome.Firmware \
io.gitlab.adhami3310.Impression \
de.philippun1.turtle \
de.philippun1.Snoop

echo "Install nautilus extensions"
sudo dnf5 install nautilus-extensions python-requests nautilus-python python3-gobject

cd ~/Repositories

git clone https://gitlab.gnome.org/philippun1/turtle.git
cd turtle
sudo python install.py install --flatpak
cd ..
sudo rm -rf turtle

git clone https://gitlab.gnome.org/philippun1/snoop.git
sudo cp snoop/extension/snoop.py /usr/share/nautilus-python/extensions
cd ..
sudo rm -rf snoop

git clone https://github.com/ronen25/nautilus-copypath
sudo cp nautilus-copypath/nautilus-copypath.py /usr/share/nautilus-python/extensions/

cd ~

echo "Fix inconsistent GNOME theming"
sudo dnf5 install -y adw-gtk3-theme
flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark

echo "Install shell extensions"
gsettings set org.gnome.shell disable-extension-version-validation true

array=( https://extensions.gnome.org/extension/5446/quick-settings-tweaker/ https://extensions.gnome.org/extension/4998/legacy-gtk3-theme-scheme-auto-switcher/ https://extensions.gnome.org/extension/3843/just-perfection/ https://extensions.gnome.org/extension/5237/rounded-window-corners/ https://extensions.gnome.org/extension/4481/forge/ )

for i in "${array[@]}"
do
    EXTENSION_ID=$(curl -s $i | grep -oP 'data-uuid="\K[^"]+')
    VERSION_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=$EXTENSION_ID" | jq '.extensions[0] | .shell_version_map | map(.pk) | max')
    wget -O ${EXTENSION_ID}.zip "https://extensions.gnome.org/download-extension/${EXTENSION_ID}.shell-extension.zip?version_tag=$VERSION_TAG"
    gnome-extensions install --force ${EXTENSION_ID}.zip
    if ! gnome-extensions list | grep --quiet ${EXTENSION_ID}; then
        busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s ${EXTENSION_ID}
    fi
    gnome-extensions enable ${EXTENSION_ID}
    rm ${EXTENSION_ID}.zip
done

gnome-extensions disable background-logo@fedorahosted.org
gnome-extensions enable rounded-window-corners@yilozt

echo "Fractional scaling"
gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

echo "Set theme settings"
gsettings set org.gnome.desktop.interface clock-show-weekday true

gsettings set org.gnome.desktop.interface document-font-name 'Inter 11'
gsettings set org.gnome.desktop.interface font-name 'Inter 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'IBM Plex Mono 11'

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'

gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

gsettings set org.gnome.shell had-bluetooth-devices-setup true

gsettings set org.gnome.software packaging-format-preference "['flatpak:flathub', 'rpm', 'flatpak:fedora-testing', 'flatpak:fedora']"

gsettings set org.gnome.desktop.notifications.application:/org/gnome/desktop/notifications/application/org-freedesktop-problems-applet/ enable false

echo "Install morewaita"
sudo dnf5 copr enable dusansimic/themes
sudo dnf5 install morewaita-icon-theme
gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita'

echo "Install firefox and thunderbird theme"
cd ~/Repositories
git clone https://github.com/rafaelmardojai/firefox-gnome-theme
cd firefox-gnome-theme
./scripts/auto-install.sh
cd ~/Repositories
git clone https://github.com/rafaelmardojai/thunderbird-gnome-theme 
cd thunderbird-gnome-theme
./scripts/auto-install.sh
cd ~
