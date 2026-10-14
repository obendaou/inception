FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       php8.2-cli \
       php8.2-mysql \
       php8.2-mbstring \
       wget \
       ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN wget -q \
    https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
    -O index.php \
    && test -s index.php

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]