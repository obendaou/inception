FROM debian:bullseye

RUN apt update && apt install -y \
    php7.4-cli \
    php7.4-mysql \
    wget 

WORKDIR /var/www/html

RUN wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O index.php

EXPOSE 8080

# Start PHP's built-in lightweight development server
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]