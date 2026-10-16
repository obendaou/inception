#!/bin/bash
set -Eeuo pipefail

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"

SQL_PASSWORD="$(cat /run/secrets/db_password)"
SQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

: "${SQL_DATABASE:?SQL_DATABASE is required}"
: "${SQL_USER:?SQL_USER is required}"

if [[ ! "$SQL_DATABASE" =~ ^[a-zA-Z0-9_]+$ ]] ||
   [[ ! "$SQL_USER" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Error: Invalid database or username" >&2
    exit 1
fi

if [[ -z "$SQL_PASSWORD" || -z "$SQL_ROOT_PASSWORD" ]]; then
    echo "Error: Database passwords cannot be empty" >&2
    exit 1
fi

escape_sql_string() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\'/\'\'}"
    printf '%s' "$value"
}

DB_PASSWORD_SQL="$(escape_sql_string "$SQL_PASSWORD")"
ROOT_PASSWORD_SQL="$(escape_sql_string "$SQL_ROOT_PASSWORD")"

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# An existing database must be started without reinitialization.
if [[ -d "$DATADIR/mysql" ]]; then
    echo "Existing MariaDB database found."
    echo "Starting MariaDB..."

    exec mysqld \
        --user=mysql \
        --datadir="$DATADIR" \
        --socket="$SOCKET"
fi

echo "Initializing MariaDB for the first time..."

mariadb-install-db \
    --user=mysql \
    --datadir="$DATADIR"

BOOTSTRAP_PID=""

cleanup() {
    if [[ -n "$BOOTSTRAP_PID" ]] &&
       kill -0 "$BOOTSTRAP_PID" 2>/dev/null; then
        mysqladmin --protocol=socket \
            --socket="$SOCKET" \
            -u root shutdown 2>/dev/null || true

        kill "$BOOTSTRAP_PID" 2>/dev/null || true
        wait "$BOOTSTRAP_PID" 2>/dev/null || true
    fi
}

trap cleanup EXIT

echo "Starting temporary MariaDB server..."

mysqld \
    --user=mysql \
    --datadir="$DATADIR" \
    --socket="$SOCKET" \
    --skip-networking &

BOOTSTRAP_PID=$!

READY=0

for i in $(seq 1 60); do
    if mysql --protocol=socket \
        --socket="$SOCKET" \
        -u root \
        -e "SELECT 1" >/dev/null 2>&1; then
        READY=1
        break
    fi

    if ! kill -0 "$BOOTSTRAP_PID" 2>/dev/null; then
        echo "Error: MariaDB stopped during initialization" >&2
        exit 1
    fi

    sleep 1
done

if [[ "$READY" -ne 1 ]]; then
    echo "Error: MariaDB did not become ready" >&2
    exit 1
fi

echo "Creating application database and users..."

mysql --protocol=socket --socket="$SOCKET" -u root <<EOSQL
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${SQL_USER}'@'%'
IDENTIFIED BY '${DB_PASSWORD_SQL}';

ALTER USER '${SQL_USER}'@'%'
IDENTIFIED BY '${DB_PASSWORD_SQL}';

GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.*
TO '${SQL_USER}'@'%';

ALTER USER 'root'@'localhost'
IDENTIFIED BY '${ROOT_PASSWORD_SQL}';

FLUSH PRIVILEGES;
EOSQL

echo "Stopping temporary MariaDB server..."

MYSQL_PWD="$SQL_ROOT_PASSWORD" \
mysqladmin --protocol=socket \
    --socket="$SOCKET" \
    -u root shutdown

wait "$BOOTSTRAP_PID" || true
BOOTSTRAP_PID=""
trap - EXIT

echo "Starting MariaDB..."

exec mysqld \
    --user=mysql \
    --datadir="$DATADIR" \
    --socket="$SOCKET"
