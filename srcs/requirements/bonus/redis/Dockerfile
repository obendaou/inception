FROM debian:bullseye

RUN apt update && apt install redis-server -y

COPY ./conf/redis.conf /etc/redis/redis.conf

EXPOSE 6379

CMD ["redis-server", "/etc/redis/redis.conf"]