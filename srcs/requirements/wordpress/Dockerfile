
FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       php8.2-fpm \
       php8.2-mysql \
       php8.2-cli \
       php8.2-curl \
       php8.2-xml \
       php8.2-mbstring \
       php8.2-zip \
       mariadb-client \
       curl \
       ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/make_wordpress.sh /usr/local/bin/make_wordpress.sh

RUN chmod +x /usr/local/bin/make_wordpress.sh \
    && mkdir -p /run/php

WORKDIR /var/www/wordpress

ENTRYPOINT ["/usr/local/bin/make_wordpress.sh"]