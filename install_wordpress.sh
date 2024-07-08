#!/bin/bash

# User input prompt and default value setting
read -p "WordPress Directory (Default: /srv/www): " WP_DIR
WP_DIR=${WP_DIR:-/srv/www}

read -p "Username of Database (Default: wordpress): " DB_USER
DB_USER=${DB_USER:-wordpress}

read -sp "Password of Database (Randomly generated in the blank): " DB_PASS
DB_PASS=${DB_PASS:-$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 10)}

echo "" # Line break after entering the password

read -p "Do you want to enable HTTPS connection?(y/n): " ENABLE_HTTPS

if [ "$ENABLE_HTTPS" == "y" ]; then
    read -p "HTTPS port (default: 443): " HTTPS_PORT
    HTTPS_PORT=${HTTPS_PORT:-443}
    read -p "Do you also enable HTTP connection? (y/n): " ENABLE_HTTP
    if [ "$ENABLE_HTTP" == "y" ]; then
        read -p "HTTP port (default: 80): " HTTP_PORT
        HTTP_PORT=${HTTP_PORT:-80}
    fi
else
    read -p "HTTP port (default: 80): " HTTP_PORT
    HTTP_PORT=${HTTP_PORT:-80}
fi

# Installation of dependencies
sudo apt update
sudo apt install -y curl zip unzip apache2 ghostscript libapache2-mod-php mysql-server php php-bcmath php-curl \
php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip

# Install WordPress
sudo mkdir -p $WP_DIR
sudo chown www-data: $WP_DIR
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C $WP_DIR

# Configure Apache

# Edit the port number
sudo tee /etc/apache2/ports.conf > /dev/null <<EOL
# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default.conf

Listen $HTTP_PORT

<IfModule ssl_module>
    Listen $HTTPS_PORT
</IfModule>

<IfModule mod_gnutls.c>
    Listen $HTTPS_PORT
</IfModule>
EOL

# Congigure the virtual host
if [ "$ENABLE_HTTPS" == "y" ]; then
    if [ "$ENABLE_HTTP" == "y" ]; then
      sudo tee /etc/apache2/sites-available/wordpress.conf > /dev/null <<EOL
<VirtualHost *:$HTTP_PORT>
    DocumentRoot $WP_DIR/wordpress
    <Directory $WP_DIR/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory $WP_DIR/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:$HTTPS_PORT>
    DocumentRoot $WP_DIR/wordpress
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    <Directory $WP_DIR/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory $WP_DIR/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
EOL
    else
        sudo tee /etc/apache2/sites-available/wordpress.conf > /dev/null <<EOL
<VirtualHost *:$HTTPS_PORT>
    DocumentRoot $WP_DIR/wordpress
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    <Directory $WP_DIR/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory $WP_DIR/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
EOL
    fi
    sudo openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
        -keyout /etc/ssl/private/apache-selfsigned.key \
        -out /etc/ssl/certs/apache-selfsigned.crt \
        -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com"
    sudo a2enmod ssl
elif [ "$ENABLE_HTTP" == "y" ] || [ -z "$ENABLE_HTTPS" ]; then
    sudo tee /etc/apache2/sites-available/wordpress.conf > /dev/null <<EOL
<VirtualHost *:$HTTP_PORT>
    DocumentRoot $WP_DIR/wordpress
    <Directory $WP_DIR/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory $WP_DIR/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
EOL
fi

sudo a2ensite wordpress
sudo a2enmod rewrite
sudo a2dissite 000-default

sudo service apache2 reload

# Configure MySQL
sudo service mysql start

sudo mysql <<MYSQL_SCRIPT
CREATE DATABASE wordpress;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Configure WordPress
sudo -u www-data cp $WP_DIR/wordpress/wp-config-sample.php $WP_DIR/wordpress/wp-config.php
sudo -u www-data sed -i "s/database_name_here/wordpress/" $WP_DIR/wordpress/wp-config.php
sudo -u www-data sed -i "s/username_here/$DB_USER/" $WP_DIR/wordpress/wp-config.php
sudo -u www-data sed -i "s/password_here/$DB_PASS/" $WP_DIR/wordpress/wp-config.php

# Set up the WordPress salt keys
SALT_KEYS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
sudo -u www-data sed -i "/AUTH_KEY/r /dev/stdin" $WP_DIR/wordpress/wp-config.php <<< "$SALT_KEYS"

# Set the correct file permissions
IP_ADDR=$(hostname -I | awk '{print $1}')
HTTP_URL="http://$IP_ADDR:$HTTP_PORT"
HTTPS_URL="https://$IP_ADDR:$HTTPS_PORT"

echo -e "WordPress has been installed successfully!\n"
echo "---------------------------------"
echo "Installation Directory: $WP_DIR/wordpress"
echo "Username of Database: $DB_USER"
echo "Password of Database: $DB_PASS"
if [ "$ENABLE_HTTPS" == "y" ]; then
    echo "WordPress URL: $HTTPS_URL"
else
    echo "WordPress URL: $HTTP_URL"
fi
echo "---------------------------------"

# Save the installation information to a text file
read -p "Do you want to save the installation information as a text file?(y/n): " SAVE_TO_FILE
if [ "$SAVE_TO_FILE" == "y" ]; then
    INFO_FILE="wordpress_install_info.txt"
    echo -e "Installed Directory: $WP_DIR/wordpress\nUsername of Database: $DB_USER\Password of Database: $DB_PASS\n" > $INFO_FILE
    if [ "$ENABLE_HTTPS" == "y" ]; then
        echo "WordPress URL: $HTTPS_URL" >> $INFO_FILE
    else
        echo "WordPress URL: $HTTP_URL" >> $INFO_FILE
    fi
    echo "Installation information has been saved to $INFO_FILE file. Please remove ASAP for security reasons."
fi
