#!/usr/bin/sh

# Fedora Install Script by tduck973564
# Makes life a little bit easier

echo CD into home directory
cd ~

echo Adding Flathub to Flatpak
flatpak remote-delete flathub
flatpak remote-add flathub https://flathub.org/repo/flathub.flatpakrepo

echo Installation of RPMFusion
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate -y core
sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False"

echo Patch GNOME
echo "[Settings]\ngtk-hint-font-metrics=1" >> ~/.config/gtk-4.0/settings.ini
sudo dnf copr enable calcastor/gnome-patched

echo Update system before continuing
sudo dnf --refresh upgrade -y

echo Installation of Oh My Zsh!
sudo dnf install util-linux-user zsh git
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
chsh -s /usr/bin/zsh
sed -e s/robbyrussell/lukerandall/ ~/.zshrc > ~/.zshrc.tmp && mv ~/.zshrc.tmp ~/.zshrc

echo Installation of GitHub CLI and setup of Git
sudo dnf config-manager -y --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo dnf install -y gh
sh -c "gh auth login"

echo "Type in your git username: "
read GITUSERNAME
echo "Type in your git email: "
read GITEMAIL

git config --global user.name $GITUSERNAME
git config --global user.email  $GITEMAIL

echo Installation of VSCode
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf install -y code

echo Installation of Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable --profile default -y

echo Installation of Python
sudo dnf install python pip
pip install --upgrade pip
pip install pylint
curl -sSL https://install.python-poetry.org | python3 -

echo Installation of TypeScript and JavaScript
sudo dnf install nodejs
sudo npm install -g typescript npm

echo Installation of Java
sudo dnf install -y java-17-openjdk java-17-openjdk-devel

echo Installation of build-essential equivalent, clang, Meson and Ninja
sudo dnf install -y make automake gcc gcc-c++ kernel-devel clang clang-tools-extra meson ninja-build

echo Installation of JetBrains
curl -fsSL https://raw.githubusercontent.com/nagygergo/jetbrains-toolbox-install/master/jetbrains-toolbox.sh | bash
jetbrains-toolbox

echo Installation of VSCode extensions
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

echo Set VSCode settings

echo Installation of miscellaneous useful apps
sudo dnf remove -y gnome-terminal
sudo dnf install -y discord ffmpeg pavucontrol pulseeffects gnome-tweaks firewall-config seahorse gnome-console
flatpak install -y com.github.tchx84.Flatseal org.gnome.Extensions io.github.realmazharhussain.GdmSettings

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
onedrive
systemctl --user enable onedrive
systemctl --user start onedrive

echo Download icon theme and fonts
sudo dnf install -y papirus-icon-theme fira-code-fonts google-roboto-fonts ibm-plex-fonts-all rsms-inter-fonts materia-gtk-theme

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

echo Dotfiles
git clone https://github.com/tduck973564/dotfiles ~/.dotfiles
echo ". ~/.dotfiles/.aliases" >> ~/.zshrc

echo "Fix inconsistent GNOME 42 theming; you will need to enable the theme in tweaks"
sudo dnf copr enable nickavem/adw-gtk3 -y
sudo dnf install adw-gtk3
flatpak install -y org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark 

echo Install firefox theme
cd ~/Repositories
git clone https://github.com/rafaelmardojai/firefox-gnome-theme
cd firefox-gnome-theme
./scripts/auto-install.sh
cd ~

echo -e '\nDone!'
