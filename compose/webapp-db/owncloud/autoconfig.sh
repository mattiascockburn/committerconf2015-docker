#!/bin/bash
BASEDIR=/var/www/html/
TEMPLATE="${BASEDIR}/config/autoconfig.php.template"
DEST="${BASEDIR}/config/autoconfig.php"
CONFIG="${BASEDIR}/config/config.php"
admin=${ADMINUSER:-admin}
adminpass=${ADMINPASSWD:-admin}
dbuser=${DBUSER:-owncloud}
dbpass=${DBPASSWD:-owncloud}
db=${DB:-db}
if [ ! -r $CONFIG ]; then
	/entrypoint.sh
	sed \
		-e "s|__ADMINPASSWD__|$adminpass|" \
		-e "s|__ADMINUSER__|$admin|" \
		-e "s|__DB__|$db|" \
		-e "s|__DBUSER__|$dbuser|" \
		-e "s|__DBPASSWD__|$dbpass|" \
		"$TEMPLATE" > "$DEST"
fi

# hackish way to make data directory volume writable
chmod 770 /data
chown www-data /data

apache2-foreground
