echo "Uninstall nvidia driver"
sudo dnf remove dnf remove xorg-x11-drv-nvidia\* akmod-nvidia
sudo rm /etc/modprobe.d/blacklist-nouveau.conf
