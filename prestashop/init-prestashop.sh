#!/bin/bash
set -e

PS_LANGUAGE=${PS_LANGUAGE:-fr}
PS_THEME_NAME=${PS_THEME_NAME:-classic}

echo "Waiting for MySQL..."
for i in {1..30}; do
    if mysqladmin ping -h"$DB_SERVER" -u"$DB_USER" -p"$DB_PASSWD" --silent; then
        echo "MySQL is ready!"
        break
    fi
    echo "Waiting for MySQL... $i/30"
    sleep 2
done

if [ ! -f /var/www/html/config/settings.inc.php ]; then
    echo "First PrestaShop installation..."
    
    if [ "$PS_LANGUAGE" != "en" ]; then
        echo "Setting language: $PS_LANGUAGE"
        sed -i "s/'en'/'$PS_LANGUAGE'/" /var/www/html/install-prod/fixtures/fashion/data/configuration.xml
    fi
    
    if [ "$PS_THEME_NAME" != "classic" ]; then
        echo "Installing custom theme: $PS_THEME_NAME"
    fi
else
    echo "PrestaShop already installed, starting normally..."
fi

exec apache2-foreground