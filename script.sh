#!/bin/bash

# Fedora Install Script by tduck973564

echo "CD into home directory"
cd ~

echo "Speed up DNF"
sudo dnf install dnf-plugins-core -y
sudo echo 'fastestmirror=True' | sudo tee -a /etc/dnf/dnf.conf
sudo echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
sudo echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf
sudo echo 'countme=false' | sudo tee -a /etc/dnf/dnf.conf

echo "Installation of RPMFusion"
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate -y core --allowerasing
sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False" --allowerasing
sudo dnf install -y ffmpeg --allowerasing

echo "Install Flathub"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Update system before continuing"
sudo dnf --refresh upgrade -y

echo "Installation of Zim"
sudo dnf install -y util-linux-user zsh git
chsh -s /usr/bin/zsh
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
echo "setopt +o nomatch" >> ~/.zshrc
echo "zmodule bira" >> ~/.zimrc
zimfw install

echo "Use dnf5"
sudo dnf install -y dnf5
echo "alias dnf5='dnf'" >> ~/.zshrc

echo "Installation of GitHub CLI and setup of Git"
sudo dnf5 install -y gh
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
pavucontrol \
openssl

flatpak install -y flathub \
com.github.wwmm.easyeffects

arch=`uname -m`
if [ "$arch" == "x86_64" ]
then
  flatpak install -y flathub org.mozilla.Thunderbird

  sudo flatpak override --socket=wayland org.mozilla.Thunderbird
  flatpak override --user --env=MOZ_ENABLE_WAYLAND=1 org.mozilla.

  sudo dnf5 install -y discord
  
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
fi

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
