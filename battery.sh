# Optimizes battery
sudo dnf remove power-profiles-daemon

sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
sudo systemctl enable --now NetworkManager-dispatcher

sudo dnf install tlp tlp-rdw powertop

sudo sh -c "echo 'PCIE_ASPM_ON_BAT=powersupersave
CPU_SCALER_GOVERNOR_ON_BAT=schedutil
PLATFORM_PROFILE_ON_BAT=low-power
RADEON_DPM_STATE_ON_BAT=battery
RADEON_DPM_PERF_LEVEL_ON_BAT=low
NMI_WATCHDOG=0
CPU_BOOST_ON_BAT=0
' >> /etc/tlp.conf"

sudo systemctl enable --now tlp
sudo tlp-rdw enable

sudo powertop --auto-tune
sudo systemctl enable --now powertop
