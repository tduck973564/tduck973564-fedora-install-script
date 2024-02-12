echo "Remove Akonadi and useless apps"

sudo dnf5 remove pim* akonadi* akregator krusader korganizer kmail ktnef kaddressbook konversation kf5-akonadi-server mariadb mariadb-backup mariadb-common kmahjongg kpat kmines k3b

echo "Install some apps"

FLATPAK_FLATHUB=( org.kde.kalgebra
org.kde.isoimagewriter
org.kde.kclock 
org.kde.kweather
org.kde.kcolorchooser
org.kde.francis )
for app in ${FLATPAK_FLATHUB[@]}; do
	flatpak install -y flathub "$app"
done

sudo dnf5 install -y libreoffice dnfdragora
kwriteconfig5 --file kdesurc --group super-user-command --key super-user-command sudo

echo "Install konsave"

python -m pip install konsave
echo "PATH=$PATH:$HOME/.local/bin" >> ~/.zshrc
source ~/.zshrc
konsave --help
echo '---
# This is the configuration file for konsave.
# This file is pre-configured for KDE Plasma users.
# This will backup all the important files for your Plasma customizations.
# Please make sure it follows the correct format for proper working of Konsave.
# The format should be:
# ---
# save:
#     name:
#         location: "path/to/parent/directory"
#         entries:
#         # these are files which will be backed up.
#         # They should be present in the specified location.
#             - file1
#             - file2
# export:
#     # This includes files which will be exported with your profile.
#     # They will not be saved but only be exported and imported.
#     # These may include files like complete icon packs and themes..
#     name:
#         location: "path/to/parent/directory"
#         entries:
#             - file1
#             - file2
# ...
# You can use these placeholders in the "location" of each item:
# $HOME: the home directory
# $CONFIG_DIR: refers to "$HOME/.config/"
# $SHARE_DIR: refers to "$HOME/.local/share"
# $BIN_DIR: refers to "$HOME/.local/bin"
# ${ENDS_WITH="text"}: for folders with different names on different computers whose names end with the same thing.
# The best example for this is the "*.default-release" folder of firefox.
# ${BEGINS_WITH="text"}: for folders with different names on different computers whose names start with the same thing.

save:
    configs:
        location: "$CONFIG_DIR"
        entries:
            - gtk-2.0
            - gtk-3.0
            - gtk-4.0
            - kate
            - Kvantum
            - latte
            - dolphinrc
            - katerc
            - konsolerc
            - kcminputrc
            - kdeglobals
            - kglobalshortcutsrc
            - klipperrc
            - krunnerrc
            - kscreenlockerrc
            - ksmserverrc
            - kwinrc
            - kwinrulesrc
            - plasma-org.kde.plasma.desktop-appletsrc
            - plasmarc
            - plasmashellrc
            - gtkrc
            - gtkrc-2.0
            - lattedockrc
            - breezerc
            - oxygenrc
            - lightlyrc
            - ksplashrc
            - khotkeysrc

    app_layouts:
        location: "$HOME/.local/share/kxmlgui5"
        entries:
            - dolphin
            - konsole

    # Here are a few examples of how you can add more stuff to back up.
    # Uncomment these lines if you want.
    # firefox:
    #     location: "$HOME/.mozilla/firefox/${ENDS_WITH='.default-release'}"
    #     entries:
    #         - chrome # for firefox customizations

    # code oss:
    #     location: "$CONFIG_DIR/Code - OSS/User/"
    #     entries:
    #         - settings.json


# The following files will only be used for exporting and importing.
export:
    share_folder:
        location: "$SHARE_DIR"
        entries:
            - plasma
            - kwin
            - konsole
            - fonts
            - color-schemes
            - aurorae
            - icons
            - wallpapers

    home_folder:
        location: "$HOME/"
        entries:
            - .fonts
            - .themes
            - .icons


    # You can add more files to export like this
    # name:
    #     location: "path/to/parent/directory"
    #     entries:
    #         - file1
    #         - file2
    #         - folder1
    #         - folder2
...' > ~/.config/konsave/conf.yaml

echo "Import konsave config"
konsave --import-profile plasmaprofile.knsv
