#!/bin/bash
set -e

# Step 1: Read passwords from the secret files
MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
WP_ADMIN_PASSWORD=$(cat "$WP_ADMIN_PASSWORD_FILE")
WP_USER_PASSWORD=$(cat "$WP_USER_PASSWORD_FILE")

# Step 2: Wait until MariaDB is actually ready to accept connections
until mysqladmin ping -h"mariadb" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent 2>/dev/null; do
    echo "Waiting for database connection..."
    sleep 2
done

# Step 3: Only set up WordPress the FIRST time (if it's not already downloaded)
if [ ! -f "/var/www/html/wp-config.php" ]; then

    # Download WordPress core files into the current directory (/var/www/html)
    wp core download --allow-root

    # Generate wp-config.php, telling WordPress how to reach the database
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="mariadb" \
        --allow-root

    # Actually install WordPress: set site title, create the admin user
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root

    # Create the second required user (a regular, non-admin user)
    wp user create \
        "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root

fi

# Fix ownership so PHP-FPM (running as www-data) can actually read/write these files
chown -R www-data:www-data /var/www/html

# Step 4: Start PHP-FPM in the foreground (keeps the container alive properly)
exec php-fpm8.2 -F