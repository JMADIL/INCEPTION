#!/bin/bash
set -e

# Read the passwords from the secret files (mounted by Docker Compose)
MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")

# Step 1: install MariaDB's own system tables, if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Step 2: create OUR database/user, if not already done (separate check)
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    mysqld_safe --datadir=/var/lib/mysql --skip-networking &
    pid=$!

    until mysqladmin ping --silent 2>/dev/null; do
        sleep 1
    done

    mysql -u root <<-EOSQL
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
EOSQL

    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait $pid
fi

# Step 3: start MariaDB "for real" — in the foreground, so the container stays alive properly
exec mysqld_safe --datadir=/var/lib/mysql