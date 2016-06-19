#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PROJECTFOLDER='myfolder'

# create project folder
sudo mkdir "/srv/www/${PROJECTFOLDER}"
sudo mkdir "/srv/www/logs"

export DEBIAN_FRONTEND=noninteractive

echo -e "\n--- Updating Ubuntu ---\n"
# update / upgrade
sudo apt-get update > /dev/null
sudo apt-get -y upgrade > /dev/null

echo -e "\n--- Installing apache and php7  ---\n"
# install apache 2 and php 
sudo apt-get install -y apache2 > /dev/null
#sudo apt-get install -y php > /dev/null

echo -e "\n--- Installing mysql client and php ---\n"
sudo apt-get -y install mysql-client  > /dev/null
sudo apt-get -y install php7.0-fpm php7.0-mysql php7.0-common php7.0-gd php7.0-json php7.0-cli php7.0-curl libapache2-mod-php7.0 > /dev/null


echo -e "\n--- Configuring php  ---\n"
# Enable short tags in php.ini and show PHP errors
sudo sed -i -r -e 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/7.0/apache2/php.ini
sudo sed -i -r -e 's/error_reporting = E_ALL & ~E_DEPRECATED/error_reporting = E_ALL | E_STRICT/g' /etc/php/7.0/apache2/php.ini
#sudo sed -i -r -e 's/display_errors = Off/display_errors = On/g' /etc/php/7.0/apache2/php.ini
# install php curl
sudo apt-get -y install -y php-curl > /dev/null
sudo apt-get -y install -y php-mcrypt > /dev/null
sudo apt-get -y install -y php7.0-mbstring > /dev/null
sudo apt-get -y install php-xdebug > /dev/null

echo -e "\n--- Setting up apache vhosts  ---\n"

VHOST=$(cat << "EOF"
<VirtualHost *:80>
    ServerAdmin my@example.com
    DocumentRoot /srv/www/myfolder 
    ServerName www.example.com
    RewriteEngine On
    RewriteRule ^/assets/css/(.*\.css)$ /assets/css/processor.php?file=$1 [QSA,L]

    <Directory /srv/www/myfolder>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /srv/www/logs/my-error_log

    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" proxy
    SetEnvIf X-Forwarded-For "^.*\..*\..*\..*" forwarded
    CustomLog "/srv/www/logs/my-access_log" combined env=!forwarded
    CustomLog "/srv/www/logs/my-access_log" proxy env=forwarded
    
    php_value include_path ".:/usr/share/php:/srv/www/myfolder"

</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/my-site.conf

# xdebug Config
cat << EOF | sudo tee -a /etc/php/7.0/mods-available/xdebug.ini
xdebug.remote_enable = 1
xdebug.remote_connect_back=1
xdebug.idekey=PHPSTORM
EOF

echo -e "\n--- Setting up apache modules  ---\n"
# enable/disable sites
sudo a2dissite 000-default.conf >/dev/null
sudo a2ensite my-site.conf > /dev/null

# enable nexcessary modules
sudo a2enmod php7.0 > /dev/null
sudo a2enmod rewrite > /dev/null
sudo a2enmod file_cache > /dev/null
sudo a2enmod headers > /dev/null
sudo a2enmod ssl > /dev/null
sudo a2enmod speling > /dev/null
sudo a2enmod expires > /dev/null

echo -e "\n--- setting Apache2 permissions  ---\n"
sudo chown -R www-data:www-data /srv/www > /dev/null
sudo chmod -R g+rwX /srv/www > /dev/null

echo -e "\n--- Restart Apache  ---\n"
# restart apache
sudo service php7.0-fpm restart > /dev/null
sudo service apache2 restart > /dev/null

echo -e "\n--- Install git  ---\n"
# install git
sudo apt-get -y install git > /dev/null

echo -e "\n--- Install Composer  ---\n"
# install Composer
curl -s https://getcomposer.org/installer | php > /dev/null
mv composer.phar /usr/local/bin/composer > /dev/null
