#!/bin/bash
set -e

# Read the passwords from the secret files (mounted by Docker Compose)
MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")

# Only run setup if this is the FIRST time (database folder doesn't exist yet)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start MariaDB quietly in the background, just to run setup commands
    mysqld_safe --datadir=/var/lib/mysql --skip-networking &

    # Wait until it's actually ready to accept commands
    until mysqladmin ping --silent 2>/dev/null; do
        sleep 1
    done

    # Create the database, a regular user, and set the root password
    mysql -u root <<-EOSQL
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
EOSQL

    # Shut down the temporary instance we used just for setup
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

# Start MariaDB "for real" — in the foreground, so the container stays alive properly
exec mysqld_safe --datadir=/var/lib/mysql