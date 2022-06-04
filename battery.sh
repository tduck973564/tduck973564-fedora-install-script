# Optimizes battery
sudo dnf install tlp tlp-rdw powertop

sudo powertop --auto-tune
sudo systemctl enable --now powertop

sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
sudo systemctl enable --now NetworkManager-dispatcher

sudo systemctl enable --now tlp
sudo tlp-rdw enable

