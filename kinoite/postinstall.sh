#!/usr/bin/env bash

# Install codecs
rpm-ostree update --install libavcodec-freeworld *-openh264
rpm-ostree override remove noopenh264 --install openh264 --install mozilla-openh264
rpm-ostree install gstreamer1-plugins-bad-free-extras gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly gstreamer1-vaapi x265 libheif

# Install Zim, set zsh as login shell
chsh -s /usr/bin/zsh
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
echo "setopt +o nomatch" >> ~/.zshrc
echo "zmodule bira" >> ~/.zimrc

# Configure git and GitHub CLI
sh -c "gh auth login"

echo "Type in your git username: "
read GITUSERNAME
echo "Type in your git email: "
read GITEMAIL

git config --global user.name $GITUSERNAME
git config --global user.email $GITEMAIL

echo "\n\nRun systemctl reboot to apply changes"
