echo "Install bismuth"

sudo dnf5 install bismuth

echo "Remove useless apps"

sudo dnf5 remove pim* akonadi* akregator korganizer kmail ktnef kaddressbook konversation kf5-akonadi-server mariadb mariadb-backup mariadb-common kmahjongg kpat kmines

