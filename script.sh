#!/usr/bin/sh

# Fedora Install Script by tduck973564
# Makes life a little bit easier

echo Adding Flathub to Flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo Installation of RPMFusion
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate -y core
sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False"

echo Update system before continuing
sudo dnf update -y

echo Installation of Oh My Zsh!
sudo dnf install util-linux-user zsh git
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
chsh -s /usr/bin/zsh
sed -e s/robbyrussell/lukerandall/ ~/.zshrc > ~/.zshrc.tmp && mv ~/.zshrc.tmp ~/.zshrc

echo Installation of GitHub CLI and setup of Git
sudo dnf config-manager -y --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo dnf install -y gh
sh -c "gh auth login"
git config --global user.name "tduck973564"
git config --global user.email "tduck973564@gmail.com"

echo Installation of VSCode
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf install -y code

echo Installation of Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable --profile default -y

echo Installation of Python
sudo dnf install python
pip install --upgrade pip
pip install pylint
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -

echo Installation of TypeScript and JavaScript
sudo dnf install nodejs
sudo npm install -g typescript

echo Installation of Java
sudo dnf install -y java-17-openjdk java-17-openjdk-devel
sudo alternatives --set java /lib/jvm/jdk-17-openjdk/bin/java

echo Installation of build-essential equivalent, clang, Meson and Ninja
sudo dnf install -y make automake gcc gcc-c++ kernel-devel clang meson ninja-build

echo Installation of JetBrains
curl -fsSL https://raw.githubusercontent.com/nagygergo/jetbrains-toolbox-install/master/jetbrains-toolbox.sh | bash
jetbrains-toolbox

echo Installation of VSCode extensions
code --install-extension ms-python.python
code --install-extension VisualStudioExptTeam.vscodeintellicode
code --install-extension vadimcn.vscode-lldb
code --install-extension icrawl.discord-vscode
code --install-extension matklad.rust-analyzer
code --install-extension serayuzgur.crates
code --install-extension bungcip.better-toml
code --install-extension emilast.LogFileHighlighter
code --install-extension CoenraadS.bracket-pair-colorizer-2
code --install-extension wakatime.vscode-wakatime
code --install-extension michelemelluso.code-beautifier
code --install-extension mrmlnc.vscode-scss
code --install-extension ritwickdey.liveserver
code --install-extension ritwickdey.live-sass
code --install-extension github.vscode-pull-request-github
code --install-extension eamodio.gitlens
code --install-extension ms-vscode.cpptools-extension-pack
code --install-extension mesonbuild.mesonbuild

echo Installation of miscellaneous useful apps
sudo dnf install -y discord ffmpeg pavucontrol pulseeffects

echo Log into accounts on web browser
firefox https://accounts.google.com/
firefox https://login.microsoftonline.com/
firefox https://discord.com/app
firefox https://github.com/login

echo Make some folders
mkdir ~/Repositories
mkdir ~/Coding
mkdir ~/Games

echo Set up SSH and enable firewall to block all except on port 22
sudo systemctl enable --now sshd
sudo systemctl enable --now firewalld
for i in $( ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d' ); do
    sudo firewall-cmd --zone=block --change-interface=$i
    echo Added $i to block zone
done
sudo firewall-cmd --permanent --add-service=ssh

echo Install nvidia drivers if nvidia gpu is installed
if [[ $(lspci) = *NVIDIA* ]]; then
  sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
  echo "Wait 5 minutes before restarting to make sure the module is built"
fi

echo Install onedrive
sudo dnf install -y onedrive
onedrive --synchronize

echo Download icon theme and fonts
sudo dnf install -y papirus-icon-theme fira-code-fonts google-roboto-fonts ibm-plex-fonts rsms-inter-fonts materia-kde*

<<comment 
echo Fix font problems in SDDM
sudo sh -c 'echo "<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
<alias>
    <family>sans-serif</family>
    <prefer>
    <family>Roboto</family>
    <family>Noto Sans Symbols</family>
    <family>Noto Sans Symbols2</family>
    <family>Noto Emoji</family>
    </prefer>
</alias>
</fontconfig>" > /etc/fonts/local.conf'
comment

echo -e '\nDone!'
