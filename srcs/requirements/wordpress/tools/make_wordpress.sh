#!/bin/bash
set -Eeuo pipefail

cd /var/www/wordpress

# 1. Ensure WP-CLI exists
if ! command -v wp >/dev/null 2>&1; then
    curl -fsSL \
        https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        -o /usr/local/bin/wp
    chmod +x /usr/local/bin/wp
fi

# 2. Download WordPress only if missing
if ! wp core version --allow-root >/dev/null 2>&1; then
    wp core download --allow-root
fi

# 3. Read passwords securely
DB_PASS="$(cat /run/secrets/db_password)"
WP_ADMIN_PASS="$(cat /run/secrets/wp_admin_password)"
WP_AUTHOR_PASS="$(cat /run/secrets/wp_author_password)"

# 4. Create wp-config.php only if missing
if [ ! -f wp-config.php ]; then
    wp config create \
        --dbname="$SQL_DATABASE" \
        --dbuser="$SQL_USER" \
        --dbpass="$DB_PASS" \
        --dbhost="$SQL_HOST" \
        --allow-root
fi

# 5. Wait for the database, with a bounded timeout
echo "Waiting for MariaDB..."

ready=0
for attempt in $(seq 1 60); do
    if MYSQL_PWD="$DB_PASS" mariadb \
        -h "$SQL_HOST" \
        -u "$SQL_USER" \
        "$SQL_DATABASE" \
        -e "SELECT 1" >/dev/null 2>&1; then
        ready=1
        break
    fi

    sleep 2
done

if [ "$ready" -ne 1 ]; then
    echo "MariaDB unavailable after 120 seconds" >&2
    exit 1
fi

# 6. Install WordPress only if not installed
if ! wp core is-installed --allow-root; then
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="Inception" \
        --admin_user="$SQL_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="admin@student.42.fr" \
        --skip-email \
        --allow-root
fi

# 7. Create author only if missing
if ! wp user get author --allow-root >/dev/null 2>&1; then
    wp user create author author@42.fr \
        --role=author \
        --user_pass="$WP_AUTHOR_PASS" \
        --allow-root
fi

# 8. Configure Redis
wp config set FS_METHOD direct --type=constant --allow-root
wp config set WP_REDIS_HOST redis --allow-root
wp config set WP_REDIS_PORT 6379 --raw --allow-root

if ! wp plugin is-installed redis-cache --allow-root; then
    wp plugin install redis-cache --allow-root
fi

if ! wp plugin is-active redis-cache --allow-root; then
    wp plugin activate redis-cache --allow-root
fi

wp redis enable --allow-root

# 9. Start PHP-FPM
exec /usr/sbin/php-fpm8.2 -F