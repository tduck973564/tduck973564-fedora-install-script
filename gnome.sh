echo "Patched mutter"
sudo dnf copr enable calcastor/gnome-patched

echo "Installation of GNOME Apps"
sudo dnf remove -y \
gnome-terminal \
rhythmbox

sudo dnf install -y \
gnome-tweaks \
seahorse \
gnome-console \
gnome-backgrounds-extras

flatpak install -y flathub \
com.mattjakeman.ExtensionManager \ 
io.github.realmazharhussain.GdmSettings \
io.bassi.Amberol \
org.gnome.World.Citations \
com.github.huluti.Curtail \
com.belmoussaoui.Decoder \
dev.Cogitri.Health \
com.adrienplazas.Metronome \
io.github.seadve.Mousai \
com.github.alexhuntley.Plots \
org.gnome.SoundRecorder \
org.gnome.Solanum \
com.github.liferooter.textpieces \
com.github.hugolabe.Wike \
io.posidon.Paper \
com.github.d4nj1.tlpui \
com.github.finefindus.eyedropper \
org.gnome.gitlab.YaLTeR.Identity \
com.usebottles.bottles \
app.drey.Dialect \
org.gnome.Geary \
org.gnome.Builder

echo "Fix inconsistent GNOME theming"
sudo dnf copr enable nickavem/adw-gtk3 -y
sudo dnf install adw-gtk3
flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark 

echo "Install shell extensions"
gsettings set org.gnome.shell disable-extension-version-validation true

array=( https://extensions.gnome.org/extension/3193/blur-my-shell/
https://extensions.gnome.org/extension/5237/rounded-window-corners/ )

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

echo "Set theme settings"
gsettings set org.gnome.desktop.interface clock-show-weekday true

gsettings set org.gnome.desktop.interface document-font-name 'Inter 11'
gsettings set org.gnome.desktop.interface font-name 'Inter 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'IBM Plex Mono 11'

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'

gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

gsettings set org.gnome.shell had-bluetooth-devices-setup true
gsettings set org.gnome.software packaging-format-preference "['flatpak:fedora-testing', 'flatpak:fedora', 'flatpak:flathub', 'rpm']"

gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.gnome.Calendar.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Console.desktop']"

gsettings set org.gnome.desktop.notifications.application:/org/gnome/desktop/notifications/application/org-freedesktop-problems-applet/ enable false

echo "Install firefox theme"
cd ~/Repositories
git clone https://github.com/rafaelmardojai/firefox-gnome-theme
cd firefox-gnome-theme
./scripts/auto-install.sh
cd ~
