#!/usr/bin/bash

# Fedora Install Script by tduck973564

echo "CD into home directory"
cd ~

echo "Adding Flathub to Flatpak"
flatpak remote-delete flathub
flatpak remote-add flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Speed up DNF"
sudo dnf install dnf-plugins-core -y
sudo sh -c "echo 'max_parallel_downloads=10' >> /etc/dnf/dnf.conf"
sudo sh -c "echo 'fastestmirror=True' >> /etc/dnf/dnf.conf"

echo "Installation of RPMFusion"
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate -y core
sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False"

echo "Patch GNOME"
echo "[Settings]\ngtk-hint-font-metrics=1" >> ~/.config/gtk-4.0/settings.ini
sudo dnf copr enable calcastor/gnome-patched -y

echo "Update system before continuing"
sudo dnf --refresh upgrade -y

echo "Xanmod kernel"
sudo dnf copr enable rmnscnce/kernel-xanmod -y
sudo dnf install kernel-xanmod-edge -y

echo "Install wine"
sudo dnf install wine winetricks bottles

echo "Installation of Oh My Zsh!"
sudo dnf install util-linux-user zsh git
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
chsh -s /usr/bin/zsh
sed -e s/robbyrussell/lukerandall/ ~/.zshrc > ~/.zshrc.tmp && mv ~/.zshrc.tmp ~/.zshrc

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
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf install -y code

echo "Installation of Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable --profile default -y

echo "Installation of Python"
sudo dnf install python pip
pip install --upgrade pip
pip install pylint
curl -sSL https://install.python-poetry.org | python3 -

echo "Installation of TypeScript and JavaScript"
sudo dnf install nodejs
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
gnome-terminal \
rhythmbox \
fedora-bookmarks

sudo dnf install -y \
discord \
ffmpeg \
easyeffects \
gnome-tweaks \
firewall-config \
seahorse \
gnome-console \
steam \
dconf-editor \
wine \
bottles \
gnome-builder \
gcolor3 \
dialect \
inkscape \
kdenlive \
musescore \
geary

flatpak install -y \
com.github.tchx84.Flatseal \
org.gnome.Extensions io.github.realmazharhussain.GdmSettings \
io.bassi.Amberol \
org.gnome.World.Citations \
com.github.huluti.Curtail \
com.belmoussaoui.Decoder \
dev.Cogitri.Health \
org.gimp.GIMP \
com.adrienplazas.Metronome \
io.github.seadve.Mousai \
net.pcsx2.PCSX2 \
com.github.alexhuntley.Plots \
org.signal.Signal \
org.gnome.SoundRecorder \
org.gnome.Solanum \
com.github.liferooter.textpieces \
com.github.hugolabe.Wike

echo "Log into accounts on web browser"
firefox https://accounts.google.com/
firefox https://login.microsoftonline.com/
firefox https://discord.com/app
firefox https://github.com/login

echo "Make some folders"
mkdir ~/Repositories
mkdir ~/Coding
mkdir ~/Games

echo "Set up SSH and enable firewall to block all except on port 22"
sudo systemctl enable --now sshd
sudo systemctl enable --now firewalld
for i in $( ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d' ); do
    sudo firewall-cmd --zone=block --change-interface=$i
    echo Added $i to block zone
done
sudo firewall-cmd --permanent --add-service=ssh

echo "Install nvidia drivers if nvidia gpu is installed"
if [[ $(lspci) = *NVIDIA* ]]; then
  sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
  echo "Wait 5 minutes before restarting to make sure the module is built"
fi

echo "Install onedrive"
sudo dnf install -y onedrive
onedrive
systemctl --user enable onedrive
systemctl --user start onedrive

echo "Download icon theme and fonts"
sudo dnf install -y papirus-icon-theme fira-code-fonts google-roboto-fonts ibm-plex-fonts-all rsms-inter-fonts

echo "Dotfiles"
git clone https://github.com/tduck973564/dotfiles ~/.dotfiles
echo ". ~/.dotfiles/.aliases" >> ~/.zshrc

echo "Fix inconsistent GNOME theming"
sudo dnf copr enable nickavem/adw-gtk3 -y
sudo dnf install adw-gtk3
flatpak install -y org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark 

echo "Install shell extensions"
gsettings set org.gnome.shell disable-extension-version-validation true

array=( https://extensions.gnome.org/extension/615/appindicator-support/
https://extensions.gnome.org/extension/3193/blur-my-shell/
https://extensions.gnome.org/extension/4135/espresso/
https://extensions.gnome.org/extension/1723/wintile-windows-10-window-tiling-for-gnome/ )

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
gsettings set org.gnome.desktop.interface clock-format '12h'
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

echo "Install firefox addons"
wget \ 
 https://addons.mozilla.org/firefox/downloads/file/4003969/ublock_origin-1.44.4.xpi \ 
 https://addons.mozilla.org/firefox/downloads/file/3974897/gnome_shell_integration-11.1.xpi \
 https://addons.mozilla.org/firefox/downloads/file/4010387/bypass_paywalls_clean-2.8.7.0.xpi && 
firefox *.xpi && rm *.xpi

echo "Change GRUB settings"
sudo grub2-editenv - set menu_auto_hide=1
sudo grub2-mkconfig -o /etc/grub2-efi.cfg

echo -e '\nDone!'
