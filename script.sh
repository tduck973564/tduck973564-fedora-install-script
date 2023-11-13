#!/bin/bash

# Fedora Install Script by tduck973564

cd ~
sh -c "gh auth login"

echo "Type in your git username: "
read GITUSERNAME
echo "Type in your git email: "
read GITEMAIL

git config --global user.name $GITUSERNAME
git config --global user.email $GITEMAIL

echo "Installation of VSCode"
flatpak install -y flathub com.visualstudio.code

echo "Installation of Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable --profile default -y

echo "Installation of Python"
sudo dnf5 install -y python pip
pip install --upgrade pip
pip install pylint
curl -sSL https://install.python-poetry.org | python3 -

echo "Installation of build-essential equivalent, clang, Meson and Ninja"
sudo dnf5 install -y make automake gcc gcc-c++ kernel-devel clang clang-tools-extra meson ninja-build

echo "Installation of apps"

sudo dnf5 remove -y \
fedora-bookmarks \
mediawriter \

sudo dnf5 install -y \
firewall-config \
discord \
pavucontrol \
openssl

flatpak install -y flathub \
com.github.wwmm.easyeffects \
org.mozilla.Thunderbird

sudo flatpak override --socket=wayland org.mozilla.Thunderbird
flatpak override --user --env=MOZ_ENABLE_WAYLAND=1 org.mozilla.Thunderbird

sudo sh -c "echo \"[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=/usr/bin/Discord --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto
Icon=discord
Type=Application
Categories=Network;InstantMessaging;
Path=/usr/bin
X-Desktop-File-Install-Version=0.26\" > /usr/share/applications/discord.desktop"

echo "Make some folders"
mkdir ~/Repositories
mkdir ~/Coding

echo "Install nvidia drivers if nvidia gpu is installed"
if [[ $(lspci) = *NVIDIA* ]]; then
sudo dnf5 install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
sudo akmods
cat <<EOF | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
options nouveau modeset=0
EOF
sudo dracut --regenerate-all --force
flatpak update
fi

echo "Install OneDrive"
sudo dnf5 install -y onedrive
onedrive
systemctl --user enable onedrive
systemctl --user start onedrive

echo "Download fonts"
sudo dnf5 install -y ibm-plex-fonts-all rsms-inter-fonts

echo "Install AppImageLauncher"
sudo dnf5 install -y https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher-2.2.0-travis995.0f91801.x86_64.rpm

echo -e '\nDone!'
