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
sudo dnf groupupdate -y core
sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False"

echo "Update system before continuing"
sudo dnf --refresh upgrade -y

echo "Install wine"
sudo dnf install -y wine winetricks

echo "Installation of Oh My Zsh!"
sudo dnf install -y util-linux-user zsh git
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
chsh -s /usr/bin/zsh
sed -e s/robbyrussell/lukerandall/ ~/.zshrc > ~/.zshrc.tmp && mv ~/.zshrc.tmp ~/.zshrc
echo "setopt NO_NOMATCH" >> ~/.zshrc

echo "Installation of GitHub CLI and setup of Git"
sudo dnf config-manager -y --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo dnf install -y gh
sh -c "gh auth login"

echo "Type in your git username: "
read GITUSERNAME
echo "Type in your git email: "
read GITEMAIL

git config --global user.name $GITUSERNAME
git config --global user.email  $GITEMAIL

echo "Installation of VSCode"
flatpak install -y flathub com.visualstudio.code

echo "Installation of Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable --profile default -y

echo "Installation of Python"
sudo dnf install -y python pip
pip install --upgrade pip
pip install pylint
curl -sSL https://install.python-poetry.org | python3 -

echo "Installation of TypeScript and JavaScript"
sudo dnf install -y nodejs
sudo npm install -g typescript npm

echo "Installation of Java"
sudo dnf install -y java-17-openjdk java-17-openjdk-devel

echo "Installation of build-essential equivalent, clang, Meson and Ninja"
sudo dnf install -y make automake gcc gcc-c++ kernel-devel clang clang-tools-extra meson ninja-build

echo "Installation of JetBrains"
curl -fsSL https://raw.githubusercontent.com/nagygergo/jetbrains-toolbox-install/master/jetbrains-toolbox.sh | bash
jetbrains-toolbox

echo "Installation of VSCode extensions"
code --install-extension ms-python.python
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-labs
code --install-extension vadimcn.vscode-lldb
code --install-extension icrawl.discord-vscode
code --install-extension rust-lang.rust-analyzer
code --install-extension serayuzgur.crates
code --install-extension bungcip.better-toml
code --install-extension emilast.LogFileHighlighter
code --install-extension wakatime.vscode-wakatime
code --install-extension michelemelluso.code-beautifier
code --install-extension mrmlnc.vscode-scss
code --install-extension ritwickdey.liveserver
code --install-extension ritwickdey.live-sass
code --install-extension github.vscode-pull-request-github
code --install-extension eamodio.gitlens
code --install-extension ms-vscode.cpptools-extension-pack
code --install-extension ms-vscode.makefile-tools
code --install-extension mesonbuild.mesonbuild
code --uninstall-extension ms-vscode.cpptools
code --install-extension llvm-vs-code-extensions.vscode-clangd

echo "Installation of apps"

sudo dnf remove -y \
fedora-bookmarks \
mediawriter

sudo dnf install -y \
ffmpeg \
firewall-config \
discord \
pavucontrol \
openssl

flatpak install -y flathub \
com.github.tchx84.Flatseal \
org.gimp.GIMP \
org.signal.Signal \
org.musescore.MuseScore \
org.kde.kdenlive \
org.inkscape.Inkscape \
com.github.wwmm.easyeffects

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
sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
sudo akmods
cat <<EOF | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
options nouveau modeset=0
EOF
sudo dracut --regenerate-all --force
flatpak update
fi

echo "Install OneDrive"
sudo dnf install -y onedrive
onedrive
systemctl --user enable onedrive
systemctl --user start onedrive

echo "Download icon theme and fonts"
sudo dnf install -y ibm-plex-fonts-all rsms-inter-fonts

echo "Install AppImageLauncher"
sudo dnf install -y https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher-2.2.0-travis995.0f91801.x86_64.rpm

echo -e '\nDone!'
