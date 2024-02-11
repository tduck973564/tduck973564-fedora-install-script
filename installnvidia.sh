sudo dnf install "kernel-devel-uname-r >= $(uname -r)"
sudo dnf update -y
sudo dnf copr enable kwizart/nvidia-driver-rawhide -y
sudo dnf install rpmfusion-nonfree-release-rawhide -y
sudo dnf --enablerepo=rpmfusion-nonfree-rawhide install -y akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda --nogpgcheck
sudo akmods
cat <<EOF | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
options nouveau modeset=0
EOF
sudo dracut --regenerate-all --force
flatpak update
