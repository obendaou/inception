#!/usr/bin/env bash
set -Eeuo pipefail

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"
MARKER="$DATADIR/.inception-init-complete"

SQL_PASSWORD="$(cat /run/secrets/db_password)"
SQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

: "${SQL_DATABASE:?SQL_DATABASE is required}"
: "${SQL_USER:?SQL_USER is required}"

if [[ ! "$SQL_DATABASE" =~ ^[a-zA-Z0-9_]+$ ]] ||
   [[ ! "$SQL_USER" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Invalid database name or username" >&2
    exit 1
fi

if [[ -z "$SQL_PASSWORD" || -z "$SQL_ROOT_PASSWORD" ]]; then
    echo "Database passwords cannot be empty" >&2
    exit 1
fi

escape_sql() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\'/\'\'}"
    printf '%s' "$value"
}

DB_PASS_SQL="$(escape_sql "$SQL_PASSWORD")"
ROOT_PASS_SQL="$(escape_sql "$SQL_ROOT_PASSWORD")"

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Initialize MariaDB system tables only when missing.
if [[ ! -d "$DATADIR/mysql" ]]; then
    echo "Initializing MariaDB system tables..."

    mariadb-install-db \
        --user=mysql \
        --datadir="$DATADIR"
fi

# Only skip application setup when it completed previously.
if [[ -f "$MARKER" ]]; then
    echo "MariaDB initialization already completed."

    exec mysqld \
        --user=mysql \
        --datadir="$DATADIR" \
        --socket="$SOCKET"
fi

echo "Starting temporary MariaDB server..."

mysqld \
    --user=mysql \
    --datadir="$DATADIR" \
    --socket="$SOCKET" \
    --skip-networking &

BOOTSTRAP_PID=$!

cleanup() {
    if kill -0 "$BOOTSTRAP_PID" 2>/dev/null; then
        kill "$BOOTSTRAP_PID" 2>/dev/null || true
        wait "$BOOTSTRAP_PID" 2>/dev/null || true
    fi
}

trap cleanup EXIT

# Support both existing password-protected root accounts
# and first-time installations with socket authentication.
ROOT_MODE=""

for attempt in $(seq 1 60); do
    if MYSQL_PWD="$SQL_ROOT_PASSWORD" \
       mariadb --protocol=socket --socket="$SOCKET" \
       -u root -e "SELECT 1" >/dev/null 2>&1; then
        ROOT_MODE="password"
        break
    fi

    if mariadb --protocol=socket --socket="$SOCKET" \
       -u root -e "SELECT 1" >/dev/null 2>&1; then
        ROOT_MODE="socket"
        break
    fi

    if ! kill -0 "$BOOTSTRAP_PID" 2>/dev/null; then
        echo "MariaDB stopped during initialization" >&2
        exit 1
    fi

    sleep 1
done

if [[ -z "$ROOT_MODE" ]]; then
    echo "Could not authenticate as MariaDB root" >&2
    exit 1
fi

echo "Configuring application database and user..."

if [[ "$ROOT_MODE" == "password" ]]; then
    export MYSQL_PWD="$SQL_ROOT_PASSWORD"
fi

mariadb --protocol=socket --socket="$SOCKET" -u root <<EOSQL
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${SQL_USER}'@'%'
IDENTIFIED BY '${DB_PASS_SQL}';

ALTER USER '${SQL_USER}'@'%'
IDENTIFIED BY '${DB_PASS_SQL}';

GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.*
TO '${SQL_USER}'@'%';

ALTER USER 'root'@'localhost'
IDENTIFIED BY '${ROOT_PASS_SQL}';

FLUSH PRIVILEGES;
EOSQL

unset MYSQL_PWD || true

echo "Application database initialization succeeded."

MYSQL_PWD="$SQL_ROOT_PASSWORD" \
mariadb-admin --protocol=socket --socket="$SOCKET" \
    -u root shutdown

wait "$BOOTSTRAP_PID"
trap - EXIT

# Create marker only after successful initialization and shutdown.
touch "$MARKER"

echo "Starting MariaDB normally..."

exec mysqld \
    --user=mysql \
    --datadir="$DATADIR" \
    --socket="$SOCKET"