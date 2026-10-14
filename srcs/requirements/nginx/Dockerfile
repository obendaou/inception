FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       nginx \
       openssl \
       ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create SSL certificate directory
RUN mkdir -p /etc/nginx/ssl

# Generate a self-signed TLS certificate for local development
RUN openssl req -x509 -nodes \
    -newkey rsa:2048 \
    -days 365 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=MA/ST=Marrakech/L=Marrakech/O=42/OU=1337/CN=obendaou.42.fr" \
    && chmod 600 /etc/nginx/ssl/inception.key

# Copy Nginx configuration
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

# Keep Nginx running as the container's main process
CMD ["nginx", "-g", "daemon off;"]