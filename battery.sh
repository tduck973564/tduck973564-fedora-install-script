#!/bin/bash
# Optimizes battery
#sudo dnf remove power-profiles-daemon

#sudo systemctl mask systemd-rfkill.service
#sudo systemctl mask systemd-rfkill.socket
#sudo systemctl enable --now NetworkManager-dispatcher

#sudo dnf install tlp tlp-rdw powertop
sudo dnf install -y powertop

sudo sh -c "echo 'PCIE_ASPM_ON_BAT=powersupersave
PLATFORM_PROFILE_ON_BAT=low-power
NMI_WATCHDOG=0
CPU_PERF_POLICY_ON_BAT=power
DEVICES_TO_DISABLE_ON_STARTUP=\"bluetooth nfc wwan\"
DEVICES_TO_ENABLE_ON_STARTUP=\"wifi\"
RADEON_DPM_PERF_LEVEL_ON_BAT=auto
RADEON_DPM_STATE_ON_BAT=battery
CPU_SCALING_GOVERNOR_ON_BAT=schedutil
CPU_BOOST_ON_BAT=0
' >> /etc/tlp.conf"

#sudo systemctl enable --now tlp
#sudo tlp-rdw enable

sudo powertop --auto-tune
sudo systemctl enable --now powertop
