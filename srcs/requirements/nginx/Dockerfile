FROM debian:bullseye

# Install NGINX and OpenSSL
RUN apt-get update && apt-get install -y nginx openssl

# Create SSL directory
RUN mkdir -p /etc/nginx/ssl

# Generate Self-Signed Certificate
# req -x509: Create self-signed cert
# -nodes: No password for the key
# -days 365: Valid for a year
# -newkey rsa:2048: Generate a new 2048-bit RSA key
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=obendaou.42.fr/UID=obendaou"

# Copy custom configuration
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# Permissions
RUN chmod 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html

# Start NGINX in foreground
CMD ["nginx", "-g", "daemon off;"]