#!/bin/bash
sudo dnf install qemu-user-static qemu-system-x86

# Fedora Install Script by tduck973564

echo "CD into home directory"
cd ~

echo "Speed up DNF"
sudo dnf install dnf-plugins-core -y
sudo echo 'fastestmirror=True' | sudo tee -a /etc/dnf/dnf.conf
sudo echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
sudo echo 'countme=false' | sudo tee -a /etc/dnf/dnf.conf

echo "Update system before continuing"
sudo dnf --refresh upgrade -y
flatpak update

echo "Installation of RPMFusion and codecs"
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate -y core --allowerasing
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
sudo dnf groupupdate multimedia -y --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin --allowerasing --with-optional
sudo dnf groupupdate -y sound-and-video
sudo dnf config-manager --enable -y fedora-cisco-openh264
sudo dnf install -y rpmfusion-free-release-tainted
sudo dnf install -y libdvdcss
sudo dnf install -y rpmfusion-nonfree-release-tainted
sudo dnf --repo=rpmfusion-nonfree-tainted install -y "*-firmware"
sudo dnf install -y intel-media-driver libva-intel-driver nvidia-vaapi-driver libva-utils vdpauinfo libavcodec-freeworld
sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
#sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
#sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
sudo dnf install -y gstreamer1-plugin-openh264 mozilla-openh264
sudo dnf install -y lame\* --exclude=lame-devel
sudo dnf install -y libheif libheif-tools

echo "Install Flathub"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify --enable flathub

echo "Installation of Zim"
sudo dnf install -y util-linux-user zsh git
chsh -s /usr/bin/zsh
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
echo "setopt +o nomatch" >> ~/.zshrc
echo "zmodule bira" >> ~/.zimrc
zimfw install

echo "Use dnf5"
sudo dnf install -y dnf5
echo "PATH=$PATH:$HOME/.local/bin" >> ~/.zshrc
echo "PATH=$PATH:$HOME/.local/bin" >> ~/.bashrc
mkdir ~/.local/bin
ln -sf /usr/bin/dnf5 ~/.local/bin/dnf

echo "Installation of GitHub CLI and setup of Git"
sudo dnf5 install -y gh
sh -c "gh auth login"

echo "Type in your git username: "
read GITUSERNAME
echo "Type in your git email: "
read GITEMAIL

git config --global user.name $GITUSERNAME
git config --global user.email $GITEMAIL
git config --global push.autoSetupRemote true

echo "Installation of apps and drivers"

sudo dnf5 remove -y \
fedora-bookmarks \
mediawriter

sudo dnf5 install -y \
firewall-config \
openssl openssl-libs \
python3-pip \
nmap \
p7zip \
p7zip-plugins \
unzip \
unrar

sudo dnf5 install -y \
epson-inkjet-printer-escpr2 \
foomatic-db \
gutenprint \
hplip

sudo dnf5 install -y @printing

echo "Enable wayland by default in supported electron apps"
echo "ELECTRON_OZONE_PLATFORM_HINT=auto" >> ~/.bashrc
echo "ELECTRON_OZONE_PLATFORM_HINT=auto" >> ~/.zshrc
sudo sh -c "echo 'ELECTRON_OZONE_PLATFORM_HINT=auto' >> /etc/profile.d/electron.sh"

echo "Make some folders"
mkdir ~/Repositories

echo "Increase vm max map count"
sudo sh -c "echo 'vm.max_map_count=2147483642' >> /etc/sysctl.conf"

echo "Install OneDriver"
sudo dnf copr enable jstaf/onedriver
sudo dnf5 install -y onedriver

echo "Download fonts"
sudo dnf5 install -y cabextract xorg-x11-font-utils fontconfig
sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
sudo dnf5 install -y ibm-plex-fonts-all rsms-inter-fonts jetbrains-mono-fonts-all google-roboto* liberation-fonts

echo "Mask hibernate"
sudo systemctl mask hibernate.target

echo "Powertop"
sudo dnf install -y powertop
sudo powertop --auto-tune
sudo systemctl enable --now powertop

echo "KDE"

echo "Remove useless apps"

sudo dnf5 remove akregator krusader konversation k3b kontact kmail korganizer kaddressbook *akonadi* kcalc krdc krfb kmousetool *abrt* mariadb mariadb-backup mariadb-common mariadb-cracklib-password-check mariadb-errmsg mariadb-gssapi-server mariadb-server mariadb-server-utils kmines kmahjongg kpat

echo "Install some apps"
sudo dnf install isoimagewriter \
kalk \
kclock \
kweather \
francis \
kget \
ktorrent \
digikam \
thunderbird

sudo dnf5 install -y libreoffice kdenetwork-filesharing kcolorchooser
sudo sh -c "echo '[super-user-command]
super-user-command=sudo' >> /etc/xdg/kdesurc"

echo "Enlarge swapfile"
sudo swapoff -a
sudo dd if=/dev/zero of=/var/swap/swapfile bs=1M count=16384
sudo chattr +C /var/swap
sudo chattr +C /var/swap/swapfile
sudo mkswap /var/swap/swapfile
sudo chmod 0600 /var/swap/swapfile
sudo swapon /var/swap/swapfile
