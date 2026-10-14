
FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       vsftpd \
       ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

RUN openssl req -x509 -nodes \
    -newkey rsa:2048 \
    -days 365 \
    -keyout /etc/ssl/private/vsftpd.key \
    -out /etc/ssl/private/vsftpd.crt \
    -subj "/CN=obendaou.42.fr" \
    && chmod 600 /etc/ssl/private/vsftpd.key

EXPOSE 21 21000-21010

CMD ["/usr/local/bin/setup.sh"]
