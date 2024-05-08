echo "Remove useless apps"

sudo dnf5 remove akregator krusader konversation k3b kontact kmail korganizer kaddressbook *akonadi* kcalc krdc krfb kmousetool *abrt* mariadb mariadb-backup mariadb-common mariadb-cracklib-password-check mariadb-errmsg mariadb-gssapi-server mariadb-server mariadb-server-utils kmines kmahjongg kpat

echo "Install some apps"

FLATPAK_FLATHUB=( org.kde.isoimagewriter
org.kde.kclock 
org.kde.kweather
org.kde.francis
org.kde.kalk
org.kde.kget
org.kde.ktorrent
org.kde.digikam )

for app in ${FLATPAK_FLATHUB[@]}; do
	flatpak install -y flathub "$app"
done

sudo dnf5 install -y libreoffice kdenetwork-filesharing kcolorchooser

echo "Set environment variables"
sudo sh -c "touch /etc/profile.d/kde-qml-font-fix.sh && echo 'QT_SCALE_FACTOR_ROUNDING_POLICY=RoundPreferFloor' >> /etc/profile.d/kde-qml-font-fix.sh"

echo "Set configuration options"

# kdesurc
sudo sh -c "touch /etc/xdg/kdesurc && echo '
[super-user-command]
super-user-command=sudo' > /etc/xdg/kdesurc"

# discoverrc - Discover
sudo sh -c "touch /etc/xdg/discoverrc && echo '
[FlatpakSources]
Sources=flathub,fedora-testing,fedora

[ResourcesModel]
currentApplicationBackend=flatpak-backend' >> /etc/xdg/discoverrc"

# konsolerc - Konsole
sudo sh -c "touch /etc/xdg/konsolerc && echo '
[FileLocation]
scrollbackUseCacheLocation=true
scrollbackUseSystemLocation=false

[MainWindow]
MenuBar=Enabled
ToolBarsMovable=Disabled

[TabBar]
NewTabButton=true' > /etc/xdg/konsolerc"

# kdeglobals - fonts and theme
sudo sh -c "touch /etc/xdg/kdeglobals && echo '
[General]
fixed=IBM Plex Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
font=Inter,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
menuFont=Inter,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
smallestReadableFont=Inter,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
toolBarFont=Inter,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

[KDE]
LookAndFeelPackage=org.kde.breezetwilight.desktop
ShowDeleteCommand=false' >> /etc/xdg/kdeglobals"

# kwinrc - Desktop Effects
sudo sh -c "touch /etc/xdg/kwinrc && echo '
[Plugins]
blurEnabled=true
contrastEnabled=true
dimscreenEnabled=true
windowviewEnabled=false' >> /etc/xdg/kwinrc"

# kuriikwsfilterrc - Web Search Keywords
sudo sh -c "touch /etc/xdg/kuriikwsfilterrc && echo '
[General]
DefaultWebShortcut=google
EnableWebShortcuts=true
KeywordDelimiter=:
PreferredWebShortcuts=yahoo,google,youtube,wikipedia,wikit
UsePreferredWebShortcutsOnly=false' >> /etc/xdg/kuriikwsfilterrc"

# kded5rc, device_automounter_kcmrc, kded_device_automounterrc - Drive Automount
sudo sh -c "touch /etc/xdg/kded5rc && echo '
[Module-device_automounter]
autoload=true' > /etc/xdg/kded5rc"
sudo sh -c "touch /etc/xdg/kded_device_automounterrc && echo '
[General]
AutomountEnabled=true
AutomountOnLogin=true
AutomountOnPlugin=true' >> /etc/xdg/kded_device_automounterrc"

# ksplashrc - Splash Screen
sudo sh -c "touch /etc/xdg/ksplashrc && echo '
[KSplash]
Theme=org.kde.breeze.desktop' >> /etc/xdg/ksplashrc"

# sddm.conf.d - SDDM Theming
sudo sh -c "touch /etc/sddm.conf.d/10-custom-defaults.conf && echo '
[Theme]
Current=breeze
Font=Inter,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1' >> /etc/sddm.conf.d/10-custom-defaults.conf"

# krunnerrc - KRunner
sudo sh -c "touch /etc/xdg/krunnerrc && echo '
[General]
FreeFloating=true' >> /etc/xdg/krunnerrc"

# kwriterc - KWrite
sudo sh -c "touch /etc/xdg/kwriterc && echo '
[KTextEditor Renderer]
Text Font=IBM Plex Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

[General]
Show welcome view for new window=false' >> /etc/xdg/kwriterc"

# spectaclerc - Spectacle
sudo sh -c "touch /etc/xdg/spectaclerc && echo '
[General]
clipboardGroup=PostScreenshotCopyImage' >> /etc/xdg/spectaclerc"
