#!/bin/bash

echo "Install flatpaks"
flatpak install -y flathub \
com.github.tchx84.Flatseal \
com.github.wwmm.easyeffects

flatpak install -y flathub \
com.mattjakeman.ExtensionManager \
io.github.realmazharhussain.GdmSettings \
io.bassi.Amberol \
com.github.huluti.Curtail \
com.belmoussaoui.Decoder \
com.github.alexhuntley.Plots \
org.gnome.SoundRecorder \
org.gnome.Solanum \
com.github.liferooter.textpieces \
com.github.hugolabe.Wike \
io.posidon.Paper \
com.github.finefindus.eyedropper \
app.drey.Dialect \
org.gnome.Geary \
com.github.maoschanz.drawing \
ca.desrt.dconf-editor \
com.github.unrud.VideoDownloader \
org.gnome.Loupe \
org.gnome.Firmware \
com.usebottles.bottles

echo "Fix inconsistent GNOME theming"
flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark

echo "Installation of Oh My Zsh!"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
chsh -s /usr/bin/zsh
sed -e s/robbyrussell/lukerandall/ ~/.zshrc > ~/.zshrc.tmp && mv ~/.zshrc.tmp ~/.zshrc
echo "setopt NO_NOMATCH" >> ~/.zshrc

echo "Install shell extensions"
gsettings set org.gnome.shell disable-extension-version-validation true

array=( https://extensions.gnome.org/extension/5237/rounded-window-corners/ https://extensions.gnome.org//extension/3733/tiling-assistant/ )

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
gnome-extensions enable tiling-assistant@leleat-on-github

echo "Fractional scaling"
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"

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

echo "Install firefox theme"
git clone https://github.com/rafaelmardojai/firefox-gnome-theme
cd firefox-gnome-theme
./scripts/auto-install.sh
cd ~

echo "Cleanup"
rm -rf firefox-gnome-theme
