# Optimizes battery
sudo dnf remove power-profiles-daemon

sudo dnf install tlp tlp-rdw powertop

sudo powertop --auto-tune
sudo systemctl enable --now powertop

sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
sudo systemctl enable --now NetworkManager-dispatcher

sudo sh -c "echo 'PCIE_ASPM_ON_BAT=powersupersave
CPU_SCALER_GOVERNOR_ON_BAT=powersave
PLATFORM_PROFILE_ON_BAT=low-power' >> /etc/tlp.conf"

sudo systemctl enable --now tlp
sudo tlp-rdw enable



