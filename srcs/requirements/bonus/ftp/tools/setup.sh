#!/bin/bash
set -Eeuo pipefail

: "${FTP_USER:?FTP_USER is required}"

FTP_PASSWORD="$(cat /run/secrets/ftp_password)"

if [[ -z "$FTP_PASSWORD" ]]; then
    echo "FTP password is empty"
    exit 1
fi

if ! id -u "$FTP_USER" >/dev/null 2>&1; then
    echo "Creating FTP user..."

    useradd \
        -d /var/www/html \
        -s /bin/bash \
        -G www-data \
        "$FTP_USER"
fi

echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

# Keep WordPress ownership intact.
# Do not recursively change file permissions here.

echo "Starting vsftpd..."
exec vsftpd /etc/vsftpd.conf
