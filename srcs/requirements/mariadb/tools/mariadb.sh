#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DIR="/var/lib/mysql/${SQL_DATABASE}"
DATADIR="/var/lib/mysql"

if [ -d "$DIR" ]; then
    echo -e "${GREEN}Database already initialized!${NC}"
else
    echo -e "${RED}Database not initialized. Initializing now...${NC}"

    echo -e "${GREEN}Installing MariaDB system tables...${NC}"
    mariadb-install-db --user=mysql --datadir="${DATADIR}" > /dev/null

    # Start mysqld with auth checks disabled, network closed —
    # this is what lets root log in with no password errors.
    mysqld_safe --skip-networking --skip-grant-tables --user=mysql &

    # Wait until the server actually accepts connections
    until mysqladmin ping --silent 2>/dev/null; do
        echo -e "${YELLOW}Waiting for MariaDB to start...${NC}"
        sleep 1
    done
    echo -e "${GREEN}Database server is ready!${NC}"

    # All setup SQL inline — no .sql file needed
    mysql -u root <<-EOSQL
        FLUSH PRIVILEGES;
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    echo -e "${GREEN}Shutting down bootstrap instance...${NC}"
    mysqladmin -u root -p"${SQL_ROOT_PASSWORD}" shutdown
fi

# Use exec so mysqld_safe/mysqld becomes PID 1
exec mysqld_safe --user=mysql