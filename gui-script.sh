#!/bin/bash

tmpfile=$(mktemp)

if ! grep -q "Fedora" /etc/os-release || ! [[ "$XDG_CURRENT_DESKTOP" == "KDE" ]]; then
  kdialog --error "This is not Fedora with KDE. This script will only run on Fedora KDE Spin." --title "Error"
  exit 1
fi

cat <<EOF > "$tmpfile"
# Set up dialog
dlg=\$(kdialog --title 'Fedora post-installation script' --progressbar 'Optimising DNF...' 46);

# Optimise DNF
dnf install dnf-plugins-core dnf5 qt -y
qdbus \$dlg Set '' value 1
if ! grep -q 'fastestmirror=True' /etc/dnf/dnf.conf ; then
  echo 'fastestmirror=True' | tee -a /etc/dnf/dnf.conf
fi
qdbus \$dlg Set '' value 2
if ! grep -q 'max_parallel_downloads=10' /etc/dnf/dnf.conf ; then
  echo 'max_parallel_downloads=10' | tee -a /etc/dnf/dnf.conf
fi
qdbus \$dlg Set '' value 3
if ! grep -q 'countme=false' /etc/dnf/dnf.conf ; then
  echo 'countme=false' | tee -a /etc/dnf/dnf.conf
fi
qdbus \$dlg Set '' value 4

qdbus \$dlg setLabelText 'Upgrading system...'
dnf --refresh upgrade -y
qdbus \$dlg Set '' value 5
flatpak update
qdbus \$dlg Set '' value 6

qdbus \$dlg setLabelText 'Installing extra repositories...'
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf config-manager --enable fedora-cisco-openh264
qdbus \$dlg Set '' value 7

qdbus \$dlg setLabelText 'Installing multimedia codecs and hardware decode support...'
dnf group upgrade -y core --allowerasing
dnf swap -y ffmpeg-free ffmpeg --allowerasing
qdbus \$dlg Set '' value 8
dnf group upgrade multimedia -y --setopt='install_weak_deps=False' --exclude=PackageKit-gstreamer-plugin --allowerasing --with-optional
dnf group upgrade -y sound-and-video
qdbus \$dlg Set '' value 9
dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
qdbus \$dlg Set '' value 10

qdbus \$dlg setLabelText 'Installing extra firmware support...'
dnf install -y rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted
dnf --repo=rpmfusion-nonfree-tainted install -y '*-firmware'
qdbus \$dlg Set '' value 11

qdbus \$dlg setLabelText 'Adding Flathub...'
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify --enable flathub
qdbus \$dlg Set '' value 12

qdbus \$dlg setLabelText 'Adding and removing extra packages...'
dnf5 remove -y akregator krusader konversation k3b kontact kmail korganizer kaddressbook *akonadi* krdc krfb kmousetool *abrt* mariadb mariadb-backup mariadb-common mariadb-cracklib-password-check mariadb-errmsg mariadb-gssapi-server mariadb-server mariadb-server-utils kmines kmahjongg kpat
qdbus \$dlg Set '' value 13

dnf5 install -y \
firewall-config \
openssl openssl-libs \
python3-pip \
nmap \
p7zip \
p7zip-plugins \
unzip \
unrar \
setroubleshoot \
steam-devices \
steam \
epson-inkjet-printer-escpr2 \
foomatic-db \
gutenprint \
hplip \
cabextract xorg-x11-font-utils fontconfig \
ibm-plex-fonts-all rsms-inter-fonts rsms-inter-vf-fonts jetbrains-mono-fonts-all google-roboto* liberation-fonts \
kleopatra kclock kweather francis kget ktorrent krecorder libreoffice kdenetwork-filesharing kcolorchooser \
samba samba-winbind samba-usershares \
libdvdcss intel-media-driver libva-intel-driver nvidia-vaapi-driver libva-utils vdpauinfo libavcodec-freeworld gstreamer1-plugin-openh264 mozilla-openh264 libheif libheif-tools lame\* \
vlc \
@printing --exclude=lame-devel
qdbus \$dlg Set '' value 14

dnf install -y https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher-2.2.0-travis995.0f91801.x86_64.rpm
qdbus \$dlg Set '' value 15
rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
qdbus \$dlg Set '' value 16

flatpak install -y flathub org.mozilla.Thunderbird
qdbus \$dlg Set '' value 17
flatpak override --socket=wayland org.mozilla.Thunderbird
qdbus \$dlg Set '' value 18
flatpak override --env=MOZ_ENABLE_WAYLAND=1 org.mozilla.Thunderbird
qdbus \$dlg Set '' value 19


qdbus \$dlg setLabelText 'Disabling hibernate...'
systemctl mask hibernate.target
qdbus \$dlg Set '' value 20

qdbus \$dlg setLabelText 'Configuring samba...'
systemctl enable smb
qdbus \$dlg Set '' value 21
firewall-cmd --permanent --add-service samba
qdbus \$dlg Set '' value 22
setsebool -P samba_enable_home_dirs=1
setsebool -P samba_export_all_ro=1
setsebool -P samba_export_all_rw=1
qdbus \$dlg Set '' value 23
if [ -f /etc/samba/smb.conf.bak ]; then
   echo 'Not overwriting Samba config...'
else
   cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
   sed '/^\[homes\]/,/^\[/{/^\[homes\]/d;/^\[/!d}' /etc/samba/smb.conf.bak > /etc/samba/smb.conf
fi
qdbus \$dlg Set '' value 24

if lspci | grep -i "NVIDIA" > /dev/null; then
    dnf install -y akmod-nvidia-open xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-power
    qdbus \$dlg setLabelText 'Setting up NVIDIA support...'
    systemctl enable nvidia-{suspend,resume,hibernate}
    qdbus \$dlg Set '' value 25
    grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'
    qdbus \$dlg Set '' value 26
    akmods --force
    qdbus \$dlg Set '' value 27
    dracut -f --regenerate-all
fi
qdbus \$dlg Set '' value 28

qdbus \$dlg setLabelText 'Configuring KDE and other system components...'
echo '[zram0]
zram-size = max(ram * 1.5, 8192)
compression-algorithm = zstd
vm.swappiness = 180
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.page-cluster = 0' > /etc/systemd/zram-generator.conf
qdbus \$dlg Set '' value 29

echo 'vm.max_map_count=2147483642' > /etc/sysctl.d/10-max-map-count.conf
qdbus \$dlg Set '' value 30

echo 'if lsmod | grep -wq nvidia; then
    export LIBVA_DRIVER_NAME=nvidia
    export MOZ_DISABLE_RDD_SANDBOX=1
    export EGL_PLATFORM=$XDG_SESSION_TYPE
fi' > /etc/profile.d/nvidia.sh
qdbus \$dlg Set '' value 31

echo 'export QT_SCALE_FACTOR_ROUNDING_POLICY=RoundPreferFloor' > /etc/profile.d/kde-font-fix.sh
qdbus \$dlg Set '' value 32

echo '<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
<fontconfig>
  <alias>
    <family>serif</family>
    <prefer>
      <family>IBM Plex Serif</family>
      <family>Noto Serif</family>
    </prefer>
  </alias>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Inter Variable</family>
      <family>Noto Sans</family>
    </prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>IBM Plex Mono</family>
      <family>Source Code Pro</family>
    </prefer>
  </alias>
</fontconfig>' > /etc/fonts/conf.d/00-default-font.conf
qdbus \$dlg Set '' value 33

echo '[Software]
UseOfflineUpdates=true

[FlatpakSources]
Sources=flathub,fedora,fedora-testing

[ResourcesModel]
currentApplicationBackend=packagekit-backend' > /etc/xdg/discoverrc
qdbus \$dlg Set '' value 34

echo '[General]
AutomountEnabled=true
AutomountOnLogin=true
AutomountOnPlugin=true' > /etc/xdg/kded_device_automounterrc
qdbus \$dlg Set '' value 35

echo '[General]
fixed=IBM Plex Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
font=Inter Variable,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
menuFont=Inter Variable,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
smallestReadableFont=Inter Variable,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
toolBarFont=Inter Variable,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

[WM]
activeFont=Inter Variable,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1' > /etc/xdg/kdeglobals
qdbus \$dlg Set '' value 36

echo '[super-user-command]
super-user-command=sudo' > /etc/xdg/kdesurc
qdbus \$dlg Set '' value 37

echo '[General]s
FreeFloating=true' > /etc/xdg/krunnerrc
qdbus \$dlg Set '' value 38

echo '[Plugins]
blurEnabled=true
contrastEnabled=true
dimscreenEnabled=true
windowviewEnabled=false

[Xwayland]
XwaylandEavesdrops=Combinations
XwaylandEavesdropsMouse=true' > /etc/xdg/kwinrc
qdbus \$dlg Set '' value 39

echo '[Module-device_automounter]
autoload=true' > /etc/xdg/kded5rc
qdbus \$dlg Set '' value 40

echo '[General]
clipboardGroup=PostScreenshotCopyImage' > /etc/xdg/spectaclerc
qdbus \$dlg Set '' value 41

echo '[General]
loginMode=emptySession' > /etc/xdg/ksmserverrc
qdbus \$dlg Set '' value 42

echo '[KTextEditor Renderer]
Text Font=IBM Plex Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

[General]
Show welcome view for new window=false' > /etc/xdg/kwriterc
qdbus \$dlg Set '' value 43

echo '[Theme]
Current=01-breeze-fedora
Font=Inter Variable,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1' > /etc/sddm.conf.d/10-font.conf
qdbus \$dlg Set '' value 44

echo "// KDE Automounter is broken with this and passwords for mounting disks is bad UX
polkit.addRule(function(action, subject) {
    if ((action.id == 'org.freedesktop.udisks2.filesystem-mount' || action.id == 'org.freedesktop.udisks2.filesystem-mount-system') && subject.active) {
        return polkit.Result.YES;
    }
});" > /usr/share/polkit-1/rules.d/11-kde-automounter.rules
qdbus \$dlg Set '' value 45

# Change AppImageLauncher icon to appimage application icon
mkdir -p /usr/share/icons/breeze/mimetypes/16
mkdir -p /usr/share/icons/breeze/mimetypes/22
mkdir -p /usr/share/icons/breeze/mimetypes/24
mkdir -p /usr/share/icons/breeze/mimetypes/32
mkdir -p /usr/share/icons/breeze/mimetypes/64
ln -sf /usr/share/icons/breeze/mimetypes/16/application-vnd.appimage.svg /usr/share/icons/breeze/apps/16/AppImageLauncher.svg
ln -sf /usr/share/icons/breeze/mimetypes/22/application-vnd.appimage.svg /usr/share/icons/breeze/apps/22/AppImageLauncher.svg
ln -sf /usr/share/icons/breeze/mimetypes/24/application-vnd.appimage.svg /usr/share/icons/breeze/apps/24/AppImageLauncher.svg
ln -sf /usr/share/icons/breeze/mimetypes/32/application-vnd.appimage.svg /usr/share/icons/breeze/apps/32/AppImageLauncher.svg
ln -sf /usr/share/icons/breeze/mimetypes/64/application-vnd.appimage.svg /usr/share/icons/breeze/apps/48/AppImageLauncher.svg
ln -sf /usr/share/icons/breeze/mimetypes/64/application-vnd.appimage.svg /usr/share/icons/breeze/apps/64/AppImageLauncher.svg
qdbus \$dlg Set '' value 46

for i in {10..1}
do
  qdbus \$dlg setLabelText "Installation complete, the system will reboot in \$i seconds..."
  sleep 1
done
systemctl reboot

EOF

kwriteconfig6 --file kdesurc --group super-user-command --key super-user-command sudo
killall kdesud
systemd-inhibit --what=sleep --who="Fedora post-installation script" --why="Downloading and installing packages" kdesu --noignorebutton -t bash "$tmpfile"
