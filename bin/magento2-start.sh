#!/bin/sh
echo "Initializing setup..."
cd /var/www/html
if [ -f ./app/etc/config.php ] || [ -f ./app/etc/env.php ]; then
    if ! [[ "$MAGENTO_BASE_URL" =~ '/'$ ]]; then
        echo "Found this url $MAGENTO_BASE_URL but it is not valid so we change to $MAGENTO_BASE_URL/"
        MAGENTO_BASE_URL="$MAGENTO_BASE_URL/"
    fi
    echo "Update Magento 2 base url to $MAGENTO_BASE_URL"
    /usr/bin/php ./bin/magento setup:store-config:set --base-url="$MAGENTO_BASE_URL"
    /usr/bin/php ./bin/magento cache:flush
    echo "It appears Magento is already installed (app/etc/config.php or app/etc/env.php exist). Exiting setup..."
    exit
fi

echo "Download Magento2 ..."
if [ -f ./magento2-2.1.2.tar.gz ]; then
    tar xzf ./magento2-2.1.2.tar.gz
else
    curl -L http://pubfiles.nexcess.net/magento/ce-packages/magento2-2.1.2.tar.gz | tar xzf - -o -C .
fi
#curl -L http://pubfiles.nexcess.net/magento/ce-packages/magento2-2.1.2.tar.gz | tar xzf - -o -C .
echo "Download Magento2 Complete"

chmod -R 777 ./var
chown -R www-data. /var/www/html
chmod +x ./bin/magento

echo "Installing composer dependencies..."
/usr/bin/php /usr/local/bin/composer update

echo "Create mysql database and user"

mysql -e "CREATE DATABASE magento2 /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -e "CREATE USER magento2@localhost IDENTIFIED BY 'magento2';"
mysql -e "GRANT ALL PRIVILEGES ON magento2.* TO 'magento2'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo "Running Magento 2 setup script..."
/usr/bin/php ./bin/magento setup:install \
  --backend-frontname=adminlogin \
  --db-host=localhost \
  --db-name=magento2 \
  --db-user=magento2 \
  --db-password=magento2 \
  --base-url=$MAGENTO_BASE_URL \
  --admin-firstname=Admin \
  --admin-lastname=Admin \
  --admin-email=admin@admin.com \
  --admin-user=admin \
  --admin-password=magento2

chmod -R 777 ./var
chown -R www-data. /var/www/html

echo "The setup script has completed execution."
