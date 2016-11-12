#!/bin/sh
echo "Initializing setup..."
cd /var/www/html
if [ -f ./app/etc/config.php ] || [ -f ./app/etc/env.php ]; then
    echo "It appears Magento is already installed (app/etc/config.php or app/etc/env.php exist). Exiting setup..."
    exit
fi

echo "Download Magento2 ..."
curl -L http://pubfiles.nexcess.net/magento/ce-packages/magento2-2.1.2.tar.gz | tar xzf - -o -C .
#/usr/bin/php /usr/local/bin/composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.1.2 .
echo "Download Magento2 Complete"

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
  --db-host=localhost \
  --db-name=magento2 \
  --db-user=magento2 \
  --db-password=magento2 \
  --base-url=http://localhost/ \
  --admin-firstname=Admin \
  --admin-lastname=Admin \
  --admin-email=admin@admin.com \
  --admin-user=admin \
  --admin-password=magento2

chmod -R 777 ./var
chown -R www-data. /var/www/html

echo "The setup script has completed execution."
