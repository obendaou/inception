FROM debian:bullseye

RUN apt update && apt install nginx -y

# Create directory and set permissions
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

# DELETE the default Debian configuration to avoid port 80 conflicts
RUN rm /etc/nginx/sites-enabled/default

# Now copy your custom server block in
COPY conf/nginx.conf /etc/nginx/conf.d/test.conf
COPY tools/index.html /var/www/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]