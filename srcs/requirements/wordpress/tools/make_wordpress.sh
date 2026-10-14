#!/bin/bash
set -e

# Check if wp-config.php exists
if [ ! -f /var/www/wordpress/wp-config.php ]; then
    mkdir -p /var/www/wordpress
    cd /var/www/wordpress

    # Download WP-CLI
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp

    # Download WordPress
    wp core download --allow-root

    # Read secrets directly from files
    DB_PASS=$(cat /run/secrets/db_password)
    WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
    WP_AUTHOR_PASS="$(cat /run/secrets/wp_author_password)"

    wp config create \
        --dbname="$SQL_DATABASE" \
        --dbuser="$SQL_USER" \
        --dbpass="$DB_PASS" \
        --dbhost="$SQL_HOST" \
        --allow-root

    # Wait until MariaDB accepts authenticated connections.
    echo "Waiting for MariaDB..."

    until MYSQL_PWD="$DB_PASS" mariadb \
        -h "$SQL_HOST" \
        -u "$SQL_USER" \
        "$SQL_DATABASE" \
        -e "SELECT 1" >/dev/null 2>&1; do
        sleep 2
    done
    # Install WordPress
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="Inception" \
        --admin_user="$SQL_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="admin@student.42.fr" \
      	--skip-email \
        --allow-root

    # Create User 2 (Author)
    wp user create author author@42.fr --role=author --user_pass="$WP_AUTHOR_PASS" --allow-root
	echo "[Redis] Configuring Object Cache..."

    # Force WordPress to use direct file access
    wp config set FS_METHOD direct --type=constant --allow-root

    # Configure Redis host and port
    wp config set WP_REDIS_HOST redis --allow-root
    wp config set WP_REDIS_PORT 6379 --raw --allow-root

    # Install and enable plugin
    wp plugin install redis-cache --activate --allow-root
    wp redis enable --allow-root
fi

# Start PHP-FPM
exec /usr/sbin/php-fpm8.2 -F