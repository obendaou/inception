FROM debian:bullseye

RUN apt-get update && apt-get install -y php7.4 php-fpm php-mysql mariadb-client curl

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/make_wordpress.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/make_wordpress.sh
RUN mkdir -p /run/php

WORKDIR /var/www/wordpress

ENTRYPOINT ["/usr/local/bin/make_wordpress.sh"]