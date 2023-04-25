# Optimizes battery
sudo dnf remove power-profiles-daemon

sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
sudo systemctl enable --now NetworkManager-dispatcher

sudo dnf install tlp tlp-rdw powertop

sudo systemctl enable --now tlp
sudo tlp-rdw enable

sudo powertop --auto-tune
sudo systemctl enable --now powertop
