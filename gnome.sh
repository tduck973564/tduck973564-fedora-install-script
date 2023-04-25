echo "Patch GNOME"
echo "[Settings]\ngtk-hint-font-metrics=1" >> ~/.config/gtk-4.0/settings.ini
sudo dnf copr enable calcastor/gnome-patched -y

echo "Installation of GNOME Apps"
sudo dnf remove -y \
gnome-terminal \
rhythmbox

sudo dnf install -y \
gnome-tweaks \
seahorse \
gnome-console \

flatpak install -y \
org.gnome.Extensions io.github.realmazharhussain.GdmSettings \
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
flatpak install -y org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark 

echo "Install shell extensions"
gsettings set org.gnome.shell disable-extension-version-validation true

array=( https://extensions.gnome.org/extension/615/appindicator-support/
https://extensions.gnome.org/extension/3193/blur-my-shell/
https://extensions.gnome.org/extension/4135/espresso/
https://extensions.gnome.org/extension/1723/wintile-windows-10-window-tiling-for-gnome/ 
https://extensions.gnome.org/extension/1401/bluetooth-quick-connect/ )

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

gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.gnome.Calendar.desktop', 'org.gnome.Nautilus.desktop']"
gsettings set org.gnome.shell app-picker-layout "[{'discord.desktop': <{'position': <0>}>, 'org.signal.Signal.desktop': <{'position': <1>}>, 'org.gnome.Geary.desktop': <{'position': <2>}>, 'org.gnome.Console.desktop': <{'position': <3>}>, 'io.bassi.Amberol.desktop': <{'position': <4>}>, 'org.gnome.TextEditor.desktop': <{'position': <5>}>, 'org.gnome.Contacts.desktop': <{'position': <6>}>, 'org.gnome.Weather.desktop': <{'position': <7>}>, 'org.gnome.clocks.desktop': <{'position': <8>}>, 'org.gnome.Maps.desktop': <{'position': <9>}>, 'org.gnome.Photos.desktop': <{'position': <10>}>, 'org.gnome.Totem.desktop': <{'position': <11>}>, 'org.gnome.Calculator.desktop': <{'position': <12>}>, 'org.gnome.Cheese.desktop': <{'position': <13>}>, 'app.drey.Dialect.desktop': <{'position': <14>}>, 'org.gnome.SoundRecorder.desktop': <{'position': <15>}>, '151ac8a7-14a6-431f-8e41-6c3a621957c3': <{'position': <16>}>, '4a525d00-5640-4141-af90-14b785c02b2c': <{'position': <17>}>, '746bd76a-c391-41e9-b41e-ea91cd833481': <{'position': <18>}>, '054e367e-7f3f-4682-a7cd-3f8140c11b6c': <{'position': <19>}>, '5aee2c61-06cd-4754-943e-4f876f3a7277': <{'position': <20>}>, 'Utilities': <{'position': <21>}>, 'org.gnome.Software.desktop': <{'position': <22>}>, 'org.gnome.Settings.desktop': <{'position': <23>}>}]"

gsettings set org.gnome.desktop.notifications.application:/org/gnome/desktop/notifications/application/org-freedesktop-problems-applet/ enable false

echo "Install firefox theme"
cd ~/Repositories
git clone https://github.com/rafaelmardojai/firefox-gnome-theme
cd firefox-gnome-theme
./scripts/auto-install.sh
cd ~
