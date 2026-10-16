FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx \
    && rm -rf /var/lib/apt/lists/*

# Remove the default Nginx website
RUN rm -f /etc/nginx/sites-enabled/default

# Copy custom configuration and website
COPY conf/nginx.conf /etc/nginx/conf.d/static.conf
COPY tools/index.html /var/www/html/index.html

# Ensure files are readable by Nginx
RUN chmod 644 /var/www/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
