#!/usr/bin/bash

# Fedora Install Script by the real fesdonomist
# for the greatest californian

echo "CD into home directory"
cd ~

pkexec bash -c "
echo \"Speed up DNF\"
dnf install dnf-plugins-core -y
echo 'fastestmirror=True' | tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' | tee -a /etc/dnf/dnf.conf
echo 'countme=false' | tee -a /etc/dnf/dnf.conf

echo \"Install RPMFusion\"
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf groupupdate -y core
dnf groupupdate -y multimedia --setop=\"install_weak_deps=False\"
dnf install -y ffmpeg --allowerasing

echo \"Update system before continuing\"
dnf --refresh upgrade -y

echo \"Installation of zsh\"
dnf install -y util-linux-user zsh git

echo \"Installation of apps\"
dnf remove -y \
fedora-bookmarks \
mediawriter

dnf install -y \
firewall-config \
discord \
pavucontrol \
openssl

echo \"[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=/usr/bin/Discord --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto
Icon=discord
Type=Application
Categories=Network;InstantMessaging;
Path=/usr/bin
X-Desktop-File-Install-Version=0.26\" > /usr/share/applications/discord.desktop

echo \"Installation of GNOME Apps\"
dnf remove -y \
gnome-terminal \
rhythmbox \
eog

dnf install -y \
gnome-tweaks \
seahorse \
gnome-console \
gnome-backgrounds-extras

echo \"Download icon theme and fonts\"
dnf install -y ibm-plex-fonts-all rsms-inter-fonts

echo \"Install AppImageLauncher\"
dnf install -y https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher-2.2.0-travis995.0f91801.x86_64.rpm

echo \"Fix inconsistent GNOME theming\"
dnf copr enable nickavem/adw-gtk3 -y
dnf install -y adw-gtk3

echo \"Battery optimisation\"
dnf remove power-profiles-daemon

systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket
systemctl enable --now NetworkManager-dispatcher

dnf install tlp tlp-rdw powertop

echo 'PCIE_ASPM_ON_BAT=powersupersave
PLATFORM_PROFILE_ON_BAT=low-power
NMI_WATCHDOG=0
CPU_PERF_POLICY_ON_BAT=power
DEVICES_TO_DISABLE_ON_STARTUP=\"bluetooth nfc wwan\"
DEVICES_TO_ENABLE_ON_STARTUP=\"wifi\"
CPU_SCALING_GOVERNOR_ON_BAT=schedutil
CPU_BOOST_ON_BAT=0
' >> /etc/tlp.conf

systemctl enable --now tlp
tlp-rdw enable

powertop --auto-tune
systemctl enable --now powertop

echo \"Raise vm.max_map_count\"
echo 'vm.max_map_count=2147483642' >> /etc/sysctl.conf
"

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
org.nickvision.tubeconverter \
org.gnome.Loupe \
org.gnome.Firmware \
com.usebottles.bottles

echo "Fix inconsistent GNOME theming"
flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark

echo "Installation of Zim"
chsh -s /usr/bin/zsh
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
echo "setopt +o nomatch" >> ~/.zshrc
echo "zmodule bira" >> ~/.zimrc
zimfw install

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
